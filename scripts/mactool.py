#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK

import os.path
import re
import sys
import logging
from os import getenv
from random import randrange, seed

if sys.version_info.major > 2:
    from urllib.request import urlopen
else:
    from urllib import urlopen  # pragma: no cover


class ColorFormatter(logging.Formatter):
    COLORS = {
        logging.DEBUG: "\033[94m",  # Blue
        logging.INFO: "\033[92m",  # Green
        logging.WARNING: "\033[93m",  # Yellow
        logging.ERROR: "\033[91m",  # Red
        logging.CRITICAL: "\033[95m",  # Magenta
    }
    RESET = "\033[0m"

    def __init__(self, use_color: bool = True, fmt: str | None = None):
        super().__init__(fmt=fmt)
        self.use_color = use_color

    def format(self, record: logging.LogRecord) -> str:
        levelname = record.levelname
        if self.use_color and record.levelno in self.COLORS:
            record.levelname = (
                f"{self.COLORS[record.levelno]}{record.levelname}{self.RESET}"
            )
        result = super().format(record)
        record.levelname = levelname  # Restore original value to avoid side-effects
        return result


def setup_logging(options) -> None:
    level = logging.DEBUG
    if hasattr(options, "verbose") and options.verbose:
        level = logging.DEBUG
    elif hasattr(options, "quiet") and options.quiet:
        level = logging.ERROR
    if hasattr(options, "loglevel") and options.loglevel:
        try:
            level = int(options.loglevel)
        except ValueError:
            level = getattr(logging, options.loglevel.upper(), level)

    use_color = getattr(options, "color", "auto") != "no"
    logger = logging.getLogger()
    logger.setLevel(level)
    logger.handlers = []
    handler = logging.StreamHandler(sys.stderr)
    handler.setFormatter(
        ColorFormatter(use_color=use_color, fmt="%(levelname)s: %(message)s")
    )
    logger.addHandler(handler)


class Config:
    def __init__(
        self,
        oui_url: str | None = None,
        macfile: str | None = None,
    ):
        self.oui_url = oui_url or "https://standards-oui.ieee.org/oui/oui.txt"
        self.macfile = macfile or ("%s/.macvendors" % getenv("HOME"))


def rand_hex(num: int) -> list[str]:
    """Generate a list of random two-character hex strings of length `num:int`"""
    return [hex(randrange(0, 255)).split("x")[1].zfill(2) for n in range(0, num)]


def rand_vmware(config: "Config | None" = None) -> str:
    """Generate a random VMware MAC address."""
    v_vmware = "00:0C:29"
    octets = v_vmware.split(":")
    octets.extend(rand_hex(3))
    if len(octets) != 6:  # pragma: no cover
        raise ValueError("len(octets) != 6", len(octets))
    return ":".join(octets)


def rand_global() -> str:
    """Generate a random global MAC address."""
    return ":".join(rand_hex(6))


def format_line(line: str) -> tuple[str, str]:
    """Parse a line from the OUI file and return (mac_prefix:str, vendor_name:str)."""
    s = line.split()
    return (s[0], " ".join(x.lower().capitalize() for x in s[2:]))


def download_oui(config: "Config | None" = None) -> None:
    """Download the latest IEEE OUI MAC list and save it to the local cache file."""
    config = config or Config()
    logging.info("Downloading OUI from %s", config.oui_url)

    f = urlopen(config.oui_url)
    logging.debug("URL opened, parsing lines and writing to %s...", config.macfile)

    with open(config.macfile, "w+") as o:
        lines = (
            format_line(line.decode("utf-8"))
            for line in f.readlines()
            if b"(hex)" in line
        )
        o.writelines(",".join(x) + "\n" for x in lines)
        o.close()
    logging.info("OUI File downloaded to %r from %r", config.macfile, config.oui_url)


def mac_to_vendor(mac: str, config: "Config | None" = None) -> str:
    """Look up the vendor string for a given MAC address or prefix."""
    config = config or Config()
    if not os.path.exists(config.macfile):
        raise FileNotFoundError(
            "OUI database not found at %s. Please run 'mactool.py --download' to download it."
            % config.macfile
        )

    with open(config.macfile, "r") as f:
        mac = mac.replace(":", "-")[:8].upper()
        matches = [x for x in f if x.startswith(mac)]

    if not matches:
        raise ValueError("There were no matches for mac=%s" % mac)

    return "\n".join(",".join(x.split(",")[1:]).strip() for x in matches)


def find_vendor(vendor: str, config: "Config | None" = None) -> str:
    """Search the local OUI cache for MAC prefixes associated with a vendor name."""
    config = config or Config()
    if not os.path.exists(config.macfile):
        raise FileNotFoundError(
            "OUI database not found at %s. Please run 'mactool.py --download' to download it."
            % config.macfile
        )
    vendor = vendor.lower()
    with open(config.macfile, "r") as f:
        matches = [m for m in f if re.search(vendor, m, re.IGNORECASE)]
    return "\n".join(x.replace("-", ":").strip() for x in matches)


def mac_from_prefix(prefix: str) -> str:
    """Generate a valid MAC address from a given MAC prefix."""
    prefixstr = prefix.replace("-", ":").strip(":")
    if not prefixstr:
        raise Exception(
            "Bad prefix", dict(prefix=prefix, prefixstr=prefixstr, octetstr=[])
        )

    octetstr = prefixstr.split(":")
    if len(octetstr) > 6:
        raise Exception(
            "Bad prefix", dict(prefix=prefix, prefixstr=prefixstr, octetstr=octetstr)
        )

    remaining = 6 - len(octetstr)
    if remaining > 0:
        octetstr.extend(rand_hex(remaining))
    return (":".join(octetstr)).upper()


def mac_from_vendor(vendor: str, config: "Config | None" = None) -> str:
    """Generate a random MAC address for a given vendor name."""
    config = config or Config()

    vendor_matches = find_vendor(vendor, config=config)
    if not vendor_matches:
        raise ValueError("There were no matches for vendor=%s" % vendor)

    prefixes = [x.split(",", 1)[0] for x in vendor_matches.split("\n")]
    logging.debug("Found %d MAC prefix(es) for vendor '%s'", len(prefixes), vendor)

    prefix = prefixes[randrange(0, len(prefixes))]
    logging.debug("Selected random prefix '%s' for vendor '%s'", prefix, vendor)

    return mac_from_prefix(prefix)


def get_parser() -> "ArgumentParser":
    """Build and return the argument parser for the CLI."""
    from argparse import ArgumentParser

    parser = ArgumentParser(
        prog="mactool",
        description="A MAC address toolkit for generating, looking up vendors, and downloading IEEE OUI datasets.",
    )
    parser.add_argument(
        "--oui-url",
        dest="oui_url",
        help="URL to download the IEEE OUI database from",
    )
    parser.add_argument(
        "-d",
        "--download",
        dest="download",
        action="store_true",
        help="Download the latest standard IEEE OUI MAC list to ~/.macvendors",
    )
    parser.add_argument(
        "-m",
        "--mac",
        dest="mac",
        help="MAC address or prefix to convert to a vendor string",
    )
    parser.add_argument(
        "-v",
        "--vendor",
        dest="vendor",
        help="Vendor name to search for associated MAC prefixes",
    )
    parser.add_argument(
        "-r",
        "--random",
        dest="rand",
        action="store_true",
        help="Generate a random MAC address matching a given vendor or prefix, or a completely random MAC",
    )
    parser.add_argument(
        "-a",
        "--all",
        dest="stdall",
        action="store_true",
        help="Read from stdin and convert all incoming MAC addresses to vendor strings",
    )

    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose (DEBUG) logging",
    )
    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="Enable quiet (ERROR) logging",
    )
    parser.add_argument(
        "--loglevel",
        type=str,
        help="Set log level by name or number (e.g., DEBUG, INFO, 10, 20)",
    )
    parser.add_argument(
        "--color",
        type=str,
        default="auto",
        help="Enable/disable ANSI color logging output (e.g. --color=no)",
    )

    return parser


def main(argv: list[str] | None = None) -> None:
    """Parse CLI arguments and route to the appropriate MAC toolkit function."""

    if argv is None:
        argv = sys.argv

    parser = get_parser()

    try:
        import argcomplete

        argcomplete.autocomplete(parser)
    except ImportError:
        pass

    # argparse parse_known_args expects args excluding the script name
    args_to_parse = argv[1:] if argv and argv[0].endswith("mactool.py") else argv
    (options, args) = parser.parse_known_args(args_to_parse)

    setup_logging(options)
    config = Config(oui_url=getattr(options, "oui_url", None))

    logging.debug("args=%s, argv=%s", args_to_parse, str.join(" ", argv))
    logging.debug("Parsed args: options=%s, unknown_args=%s", options, args)

    if options.download:
        logging.info("Starting OUI database download.")
        download_oui(config=config)

    if options.vendor and options.rand:
        logging.info("Generating random MAC for vendor: %s", options.vendor)
        print(mac_from_vendor(options.vendor, config=config))
    elif options.vendor:
        logging.info("Searching for vendor: %s", options.vendor)
        print(find_vendor(options.vendor, config=config))

    if options.mac and options.rand:
        logging.info("Generating random MAC from prefix: %s", options.mac)
        print(mac_from_prefix(options.mac))
    elif options.mac:
        logging.info("Looking up vendor for MAC: %s", options.mac)
        print(mac_to_vendor(options.mac, config=config))

    if options.rand and not options.mac and not options.vendor:
        logging.info("Generating completely random MAC")
        print(rand_global())

    if options.stdall:
        logging.info("Reading MACs from stdin")
        ilines = sys.stdin.readlines()
        for x in ilines:
            print("%s -> %s" % (x.strip(), mac_to_vendor(x, config=config)))


if __name__ == "__main__":  # pragma: no cover
    import sys

    seed()
    main(sys.argv)

#!/usr/bin/env python

import re
import sys
from os import getenv
from random import randrange, seed

if sys.version_info.major > 2:
    from urllib.request import urlopen
else:
    from urllib import urlopen

_OUI_URL = "https://standards-oui.ieee.org/oui/oui.txt"
_MACFILE = "%s/.macvendors" % getenv("HOME")


_V_VMWARE = "00:0c:29"


def rand_hex(num:int) -> list[str]:
    return [hex(randrange(0, 255)).split("x")[1].zfill(2) for n in range(0, num)]


def rand_vmware():
    line = _V_VMWARE.split(":")
    line.extend(rand_hex(3))
    return ":".join(line)


def rand_global():
    return ":".join(rand_hex(6))


def format_line(line):
    s = line.split()
    return (s[0], " ".join(x.lower().capitalize() for x in s[2:]))


def download_oui():
    # f = open(filename,"r")
    f = urlopen(_OUI_URL)
    with open(_MACFILE, "w+") as o:
        lines = (format_line(line) for line in f.readlines() if "(hex)" in line)
        o.writelines(",".join(x) + "\n" for x in lines)
        o.close()
    print("OUI File downloaded to %s" % _MACFILE)


def mac_to_vendor(mac):
    with open(_MACFILE, "r") as f:
        mac = mac.replace(":", "-")[:8].upper()

    return "\n".join("".join(x.split(",")[1:]).strip() for x in f if x.startswith(mac))


def find_vendor(vendor:str):
    vendor = vendor.lower()
    with open(_MACFILE, "r") as f:
        return "\n".join(x.replace("-", ":").strip() for x in f.readlines() if re.match(vendor, str(f), re.IGNORECASE))


def mac_from_prefix(prefix):
    prefixstr = prefix.replace("-", ":")[:8]
    line = prefixstr.split(":")
    if len(line) != 3:
        raise Exception("Bad prefix")
    line.extend(rand_hex(3))
    return (":".join(line)).upper()


def mac_from_vendor(vendor):
    line = [x.split(",")[0] for x in find_vendor(vendor).split("\n")]
    return mac_from_prefix(line[randrange(0, len(line))])


def build_parser():
    from argparse import ArgumentParser

    arg = ArgumentParser(prog=__name__)
    arg.add_argument(
        "-d",
        "--download",
        dest="download",
        action="store_true",
        help="Download latest MAC list",
    )
    arg.add_argument(
        "-m", "--mac", dest="mac", help="MAC Address to Convert to Vendor String"
    )
    arg.add_argument(
        "-v", "--vendor", dest="vendor", help="Vendor to search for prefixes"
    )
    arg.add_argument(
        "-r", "--random", dest="rand", action="store_true", help="Generate random MAC"
    )
    arg.add_argument(
        "-a", dest="stdall", action="store_true", help="Convert All From stdin"
    )
    return arg


def main(argv):
    arg = build_parser()
    (options, args) = arg.parse_known_args(argv)
    print((options, args))
    if options.download:
        download_oui()

    if options.vendor and options.rand:
        print(mac_from_vendor(options.vendor))
    elif options.vendor:
        print(find_vendor(options.vendor))

    if options.mac and options.rand:
        print(mac_from_prefix(options.mac))
    elif options.mac:
        print(mac_to_vendor(options.mac))

    if options.stdall:
        ilines = sys.stdin.readlines()
        for x in ilines:
            print("%s -> %s" % (x.strip(), mac_to_vendor(x)))


if __name__ == "__main__":
    import sys
    seed()
    main(sys.argv)

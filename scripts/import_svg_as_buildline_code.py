#!/usr/bin/env python3
"""Print build123d buildline code generated from an SVG file."""

from __future__ import annotations

import argparse


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate build123d buildline code from an SVG file"
    )
    parser.add_argument("svg_path", help="Path to the SVG file")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    import build123d

    result = build123d.importers.import_svg_as_buildline_code(args.svg_path)
    print(result[0])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

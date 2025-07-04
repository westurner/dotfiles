#!/bin/sh
set -x
#code "${@}"
flatpak run com.visualstudio.code "${@}"

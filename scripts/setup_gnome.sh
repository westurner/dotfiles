#!/bin/bash

function setup_gnome_background_color {
  local color="${1:-"#1F2325"}"
  gsettings set org.gnome.desktop.background picture-uri ""
  # gsettings set org.gnome.desktop.background picture-options "zoom"
  gsettings set org.gnome.desktop.background primary-color "${color}"
  gsettings set org.gnome.desktop.background secondary-color "${color}"
  gsettings set org.gnome.desktop.background color-shading-type "solid"
}

function main {
  (set -x; setup_gnome_background_color)
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
  main
fi

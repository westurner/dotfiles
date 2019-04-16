#!/bin/sh

##  git-flow-versiontag.sh -- set gitflow/hubflow.prefix.versiontag v
#  
#  Usage:
#    git-flow-versiontag.sh --help
#    git-flow-versiontag.sh status
#    git-flow-versiontag.sh gf hf
#
# Author: @westurner <wes@wrd.nu>
# License: MIT

function git_flow_versiontag_status {
  (set -x; git config --show-origin --get-regexp '\w*flow.prefix.versiontag')
}

function set_gitflow_versiontag {
  (set -x; git config --replace-all gitflow.prefix.versiontag v)
}

function set_hubflow_versiontag {
  (set -x; git config --replace-all hubflow.prefix.versiontag v)
}

function git_flow_versiontag_test {
  local this=$(basename "${0}")

  function _tests {
    ${this} -h
    ${this} --help
    ${this} help
    ${this} gitflow
    ${this} gf
    ${this} hubflow
    ${this} hf
    ${this} hubflow gitflow
    ${this} hf gf
    ${this} both
    ${this} status
  }
  (set -x -v -e; _tests)
  local rc=$?
  if [ $rc -gt 0 ]; then
    ${this} status
    echo "TEST ERROR: Tests failed here ^"
    return $rc;
  else
    ${this} status
    echo "TEST SUCCESS!"
    return 0
  fi
}

function git_flow_versiontag_usage {
  local this=$(basename "${0}")
  echo "${this} [-h] <gitflow|gf|hubflow|hf|both>+"
  echo ""
  echo "Set gitflow and/or hubflow versiontags to 'v'"
  echo "so that release tags look like 'v0.1.0'"
  echo ""
  echo "Options:"
  echo ""
  echo "  status      -- print current gitflow/hubflow.prefix.versiontag"
  echo ""
  echo "  gitflow|gf  -- set the gitflow versiontag to 'v'"
  echo "  hubflow|hf  -- set the hubflow versiontag to 'v'"
  echo "  both        -- set the gitflow and hubflow versiontags to 'v'"
  echo ""
  echo "  -h/--help   -- print help"
  echo "  --test      -- run tests"
  echo "                 (this will set the versiontag a bunch of times)"
  echo ""
}

function git_flow_versiontag_main {
  local args=${@}

  for arg in "${@}"; do
    case "${arg}" in
      hubflow|hf) set_hubflow_versiontag;;
      gitflow|gf) set_gitflow_versiontag;;
      both) set_gitflow_versiontag; set_hubflow_versiontag;;
      status) ;;
      --test) git_flow_versiontag_test; return $?;;
      -h|--help|help|*) git_flow_versiontag_usage; return $?;;
    esac
  done
  git_flow_versiontag_status
  return
}

git_flow_versiontag_main "${@}"

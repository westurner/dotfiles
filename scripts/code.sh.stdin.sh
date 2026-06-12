#!/usr/bin/env bash
set -euo pipefail

declare -A __COVERAGE_HITS=()

cover_hit() {
  __COVERAGE_HITS["$1"]=1
}

choose_tmp_dir() {
  cover_hit "choose_tmp_dir"

  if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    printf '%s\n' "$XDG_RUNTIME_DIR"
    return
  fi

  if [[ -n "${XDG_STATE_HOME:-}" ]]; then
    printf '%s\n' "$XDG_STATE_HOME"
    return
  fi

  if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
    printf '%s\n' "$XDG_CACHE_HOME"
    return
  fi

  printf '%s\n' "${TMPDIR:-/tmp}"
}

create_log_tmpfile() {
  cover_hit "create_log_tmpfile"

  local tmp_dir
  local app_tmp_dir
  local tmp_file

  tmp_dir="$(choose_tmp_dir)"
  app_tmp_dir="$tmp_dir/dotfiles"

  # Keep the app temp directory private to the current user.
  mkdir -p -m 700 "$app_tmp_dir"
  tmp_file="$(mktemp "$app_tmp_dir/git-pager.XXXXXX.log")"
  chmod 600 "$tmp_file"

  printf '%s\n' "$tmp_file"
}

save_stdin_to_file() {
  cover_hit "save_stdin_to_file"

  local path="$1"

  # As a pager, consume stdin, mirror to stdout, and keep a copy for VS Code.
  tee "$path"
}

launch_code() {
  cover_hit "launch_code"

  local path="$1"
  "${CODE_BIN:-code}" "$path"
}

open_stdin_in_code() {
  cover_hit "open_stdin_in_code"

  local tmp_file
  tmp_file="$(create_log_tmpfile)"

  save_stdin_to_file "$tmp_file"
  launch_code "$tmp_file"
}

asserteq() {
  cover_hit "asserteq"

  local expected="$1"
  local actual="$2"
  local label="$3"

  __TAP_N=$((__TAP_N + 1))
  if [[ "$expected" == "$actual" ]]; then
    printf 'ok %d - %s\n' "$__TAP_N" "$label"
    return 0
  fi

  printf 'not ok %d - %s\n' "$__TAP_N" "$label"
  printf '# expected: %s\n' "$expected"
  printf '#   actual: %s\n' "$actual"
  __TAP_FAIL=$((__TAP_FAIL + 1))
  return 1
}

run_tests_tap() {
  local t_root
  local got
  local tmp_file
  local perms
  local out
  local saved_runtime
  local saved_state
  local saved_cache
  local saved_tmpdir
  local covered
  local target_count
  local got_file
  local out_file

  __TAP_N=0
  __TAP_FAIL=0
  printf 'TAP version 13\n'
  printf '1..9\n'

  # Allow all assertions to execute and report in one TAP stream.
  set +e

  t_root="$(mktemp -d)"

  saved_runtime="${XDG_RUNTIME_DIR-}"
  saved_state="${XDG_STATE_HOME-}"
  saved_cache="${XDG_CACHE_HOME-}"
  saved_tmpdir="${TMPDIR-}"

  XDG_RUNTIME_DIR="$t_root/runtime"
  XDG_STATE_HOME="$t_root/state"
  XDG_CACHE_HOME="$t_root/cache"
  TMPDIR="$t_root/tmp"
  got_file="$t_root/got.txt"
  choose_tmp_dir > "$got_file"
  got="$(cat "$got_file")"
  asserteq "$XDG_RUNTIME_DIR" "$got" "choose_tmp_dir prefers XDG_RUNTIME_DIR"

  unset XDG_RUNTIME_DIR
  choose_tmp_dir > "$got_file"
  got="$(cat "$got_file")"
  asserteq "$XDG_STATE_HOME" "$got" "choose_tmp_dir falls back to XDG_STATE_HOME"

  unset XDG_STATE_HOME
  choose_tmp_dir > "$got_file"
  got="$(cat "$got_file")"
  asserteq "$XDG_CACHE_HOME" "$got" "choose_tmp_dir falls back to XDG_CACHE_HOME"

  unset XDG_CACHE_HOME
  choose_tmp_dir > "$got_file"
  got="$(cat "$got_file")"
  asserteq "$TMPDIR" "$got" "choose_tmp_dir falls back to TMPDIR"

  XDG_RUNTIME_DIR="$t_root/runtime"
  XDG_STATE_HOME="$t_root/state"
  XDG_CACHE_HOME="$t_root/cache"
  create_log_tmpfile > "$got_file"
  tmp_file="$(cat "$got_file")"
  perms="$(stat -c '%a' "$tmp_file")"
  asserteq "600" "$perms" "create_log_tmpfile sets mode 600"

  out_file="$t_root/out.txt"
  save_stdin_to_file "$tmp_file" <<< $'line1\nline2' > "$out_file"
  out="$(cat "$out_file")"
  asserteq $'line1\nline2' "$out" "save_stdin_to_file mirrors stdin to stdout"

  CODE_BIN=true
  launch_code "$tmp_file"
  asserteq "0" "$?" "launch_code executes configured CODE_BIN"

  open_stdin_in_code <<< $'stdin-via-open' > "$out_file"
  out="$(cat "$out_file")"
  asserteq "stdin-via-open" "$out" "open_stdin_in_code preserves pager output"

  covered=0
  for f in choose_tmp_dir create_log_tmpfile save_stdin_to_file launch_code open_stdin_in_code asserteq; do
    if [[ -n "${__COVERAGE_HITS[$f]:-}" ]]; then
      covered=$((covered + 1))
    fi
  done
  target_count=6
  printf '# coverage: %d/%d functions\n' "$covered" "$target_count"
  asserteq "$target_count" "$covered" "function coverage complete"

  rm -rf "$t_root"

  if [[ -n "${saved_runtime}" ]]; then
    XDG_RUNTIME_DIR="$saved_runtime"
  else
    unset XDG_RUNTIME_DIR
  fi

  if [[ -n "${saved_state}" ]]; then
    XDG_STATE_HOME="$saved_state"
  else
    unset XDG_STATE_HOME
  fi

  if [[ -n "${saved_cache}" ]]; then
    XDG_CACHE_HOME="$saved_cache"
  else
    unset XDG_CACHE_HOME
  fi

  if [[ -n "${saved_tmpdir}" ]]; then
    TMPDIR="$saved_tmpdir"
  else
    unset TMPDIR
  fi

  if [[ "$__TAP_FAIL" -ne 0 ]]; then
    return 1
  fi
  return 0
}

main() {
  cover_hit "main"

  if [[ "${1:-}" == "--test" ]]; then
    run_tests_tap
    return $?
  fi

  open_stdin_in_code
}

main "$@"

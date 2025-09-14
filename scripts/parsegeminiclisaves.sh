#!/bin/sh

_read_commands_from_gemini_cli_shell_output_log() {
    # Parses prompt out of a gemini-cli shell output log
    # There is now an /export command in gemini-cli.
    local shell_log=$1
    cat "${shell_log}" | grep -E '│  > (.*)' -A 2 | grep '^│' | sed 's/^\s*│\s*/  /g' | sed 's/^\s*>/-/' | sed 's/\s*│$//'
}

main() {

if [ -n "" ]; then
  _read_commands_from_gemini_cli_shell_output_log "${@}"
fi

}

main "${@}"

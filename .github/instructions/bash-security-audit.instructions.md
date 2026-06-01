---
description: Auditing Bash scripts for security, proper variable escaping, and safe JSON payload construction natively.
applyTo:
  - "**/*.sh"
  - "scripts/**"
---

# Bash Security & Escaping Audit Guidelines

When reviewing, writing, or refactoring Bash scripts in this workspace, rigorously audit for the following safety patterns to prevent injection flaws and logic errors:

## 1. Safe JSON Construction (Native Bash)
If `jq` or `python` is unavailable and JSON must be constructed manually:
- **Strings:** Never inject string variables directly (e.g., `{"key": "$val"}`). Always manually escape backslashes first, then double-quotes, and use `printf`:
  ```bash
  val_escaped="${val//\\/\\\\}"
  val_escaped="${val_escaped//\"/\\\"}"
  printf '{"key": "%s"}\n' "$val_escaped"
  ```
- **Integers:** Coerce positional parameters or variables intended to be integers using the `%d` format specifier in `printf`. This prevents a malicious string from injecting code or breaking JSON structure if it slips in:
  ```bash
  printf '{"exit_code": %d}\n' "$exit_code"
  ```
- Avoid using `echo '{...}'` to output JSON payloads, as shells handle backslash escapes unpredictably in `echo`.

## 2. Safe Trap and Eval Definitions
When passing variables to delayed execution contexts like `trap` or `eval`:
- Avoid referencing raw variables directly inside the trap string, as changes during runtime or spaces in names can break the expected invocation. 
- Quote arguments safely at declaration time using `printf "%q "` to ensure variables are parsed safely as single shell arguments, regardless of spaces or quotes.
  ```bash
  # Good
  safe_args=$(printf "%q " "$path" "$name")
  trap "cleanup_func \$? $safe_args" EXIT
  ```

## 3. General Expansion
- Always quote variable expansions `"$var"` to prevent globbing and word splitting.
- Expand array arguments safely with `"${array[@]}"`.

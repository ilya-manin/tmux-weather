#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${CURRENT_DIR}/scripts/helpers.sh"

replace_placeholder_in_status_line() {
  local placeholder="\#{$1}"
  local script="#($2)"
  local status_line_side=status-${3:-right}
  local old_status_line
  local new_status_line

  old_status_line="$(get_tmux_option "$status_line_side")"
  new_status_line=${old_status_line/$placeholder/$script}

  set_tmux_option "$status_line_side" "$new_status_line"
}

main() {
  local weather="$CURRENT_DIR/scripts/weather.sh"
  replace_placeholder_in_status_line "weather" "$weather" right
  replace_placeholder_in_status_line "weather" "$weather" left
}

main

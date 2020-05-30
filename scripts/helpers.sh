#!/usr/bin/env bash

get_tmux_option() {
  local option_name="$1"
  local default_value="$2"
  local option_value

  option_value=$(tmux show-option -gqv "$option_name")

  echo -n "${option_value:-${default_value}}"
}

set_tmux_option() {
  local option_name="$1"
  local option_value="$2"
  tmux set-option -gq "$option_name" "$option_value"
}


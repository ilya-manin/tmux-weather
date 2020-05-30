#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${CURRENT_DIR}/helpers.sh"

DEFAULT_UPDATE_INTERVAL=15
DEFAULT_FORMAT=1
DEFAULT_UNITS="metric"

get_weather() {
  local location
  local format
  local units

  location=$(get_tmux_option "@tmux-weather-location")
  format=$(get_tmux_option "@tmux-weather-format" "$DEFAULT_FORMAT")
  units=$(get_tmux_option "@tmux-weather-units" "$DEFAULT_UNITS")

  case "$units" in
    imperial|usa|u|uscs)
      units="u"
      ;;
    *)
      units="m"
      ;;
  esac

  res=$(curl -fsSL "https://wttr.in/${location}?${units}&format=${format}")

  case "$(get_tmux_option "@tmux-weather-hide-units")" in
    true|1|yes)
      if [[ "$units" == "m" ]]
      then
        res="${res//°C/}"
      else
        res="${res//°F/}"
      fi
      ;;
  esac

  case "$(get_tmux_option "@tmux-weather-hide-positive-number-sign")" in
    true|1|yes)
      res="$(sed -r 's/\+([0-9]+)/\1/' <<< "$res")"
      ;;
  esac

  echo "$res"
}

main() {
  local current_time
  local delta
  local previous_update
  local update_interval
  local value

  update_interval="$(get_tmux_option "@tmux-weather-interval" "$DEFAULT_UPDATE_INTERVAL")"
  update_interval=$(( 60 * update_interval ))
  current_time="$(date "+%s")"
  previous_update="$(get_tmux_option "@weather-previous-update-time")"
  delta="$(( current_time - previous_update ))"

  if [[ -z "$previous_update" ]] || [[ "$delta" -ge "$update_interval" ]] || \
     [[ -n "$WEATHER_FORCE_UPDATE" ]]  # debug
  then
    echo "Updating weather data" >&2
    if value="$(get_weather)"
    then
      set_tmux_option "@weather-previous-update-time" "$current_time"
      set_tmux_option "@weather-previous-value" "$value"
    fi
  fi

  get_tmux_option "@weather-previous-value"
}

main

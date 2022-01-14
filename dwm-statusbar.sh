#!/bin/bash
#
# ~/Scripts/statusbar
#
# Status bar for dwm. Expanded from:
# https://bitbucket.org/jasonwryan/eeepc/src/73dadb289dead8ef17ef29a9315ba8f1706927cb/Scripts/dwm-status

print_mem_used() {
  mem_used="$(free -m | awk 'NR==2 {print $3}')"
  echo -ne "${sep_line}${colour_blu} ${glyph_mem} ${mem_used}M "
}

print_datetime() {
  datetime="$(date "+%a %d %b %H:%M")"
  echo -ne "${datetime} "
}

print_batt_rem() {
  batt_rem="$(acpi | awk '{print $4}' | tr -d ',')"
  echo -ne "${sep_line}${colour_blu} ${glyph_batt} ${batt_rem} "
}

print_ip() {
  ip="$(iwgetid -r)"
  echo -ne "${sep_line}${colour_blu} ${glyph_eth} ${ip} "
}

print_temp() {
    temp="$(vcgencmd measure_temp | sed 's/temp=//g')"
    echo -ne "${temp} "
}

# cpu (from: https://bbs.archlinux.org/viewtopic.php?pid=661641#p661641)

while true; do
  # get new cpu idle and total usage
  eval $(awk '/^cpu /{print "cpu_idle_now=" $5 "; cpu_total_now=" $2+$3+$4+$5 }' /proc/stat)
  cpu_interval=$((cpu_total_now-${cpu_total_old:-0}))
  # calculate cpu usage (%)
  let cpu_used="100 * ($cpu_interval - ($cpu_idle_now-${cpu_idle_old:-0})) / $cpu_interval"

  # output vars
  print_cpu_used() {
    printf "${cpu_used}%%"
  }

  # Pipe to status bar, not indented due to printing extra spaces/tabs
  xsetroot -name "$(print_cpu_used) $(print_temp) $(print_datetime)"

  # reset old rates
  cpu_idle_old=$cpu_idle_now
  cpu_total_old=$cpu_total_now
  # loop stats every 1 second
  sleep 5
done

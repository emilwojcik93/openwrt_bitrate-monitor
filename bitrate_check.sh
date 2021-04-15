#!/bin/sh

iface="$1"
output_forward="$2"
time="$3"

net="lan"
output=$(echo "ifdown "$net" && sleep 5 && ifup "$net"")
rx=$(iw $iface link | grep bitrate | awk '{print $3}' | awk -F. '{print $1}' | awk 'NR==1')
tx=$(iw $iface link | grep bitrate | awk '{print $3}' | awk -F. '{print $1}' | awk 'NR==2')

if [ -z "$iface" ]; then
  echo -e "Please declare interface name as first argument\nwhile executing script eg.:\n\n./bitrate_check.sh wlan1\nsh bitrate_check.sh wlan0\n"
  exit 0
fi

if [ -z "$output_forward" ]; then
  output_forward="manual"
fi

if [ "$output_forward" != "auto" ]; then
  if [ "$output_forward" != "manual" ]; then
    echo -e "Please declare corret value as second argument\nwhile executing script eg.:\n\n./bitrate_check.sh wlan1 auto\nsh bitrate_check.sh wlan0 manual\n"
  fi
fi

if [ -z "$time" ]; then
  time=600
fi

if [ "$time" != 600 ] > /dev/null 2>&1; then
  if [ expr -- "$time" + 0 ] > /dev/null 2>&1; then
    echo "$time is a number" > /dev/null 2>&1
  else
    echo -e "Please declare corret value as second argument\nwhile executing script eg.:\n\n./bitrate_check.sh wlan1 auto\nsh bitrate_check.sh wlan0 manual\n"
  fi
fi

if [ ! -f /tmp/bitrate.out ]; then
  touch /tmp/bitrate.out
else
  rm -r /tmp/bitrate.out
  touch /tmp/bitrate.out
fi


c=1
while [[ $c -le $time ]]
do
  counter0=$(expr "$time" - "$c")
  counter=$(expr "$counter0" % 60)
  counter1=$(expr "$time" - "$c")
  left=$(expr "$counter1" / 60)
  echo "$rx" | tee -a /tmp/bitrate.out > /dev/null 2>&1
  echo "$tx" | tee -a /tmp/bitrate.out > /dev/null 2>&1
  let c=c+1
  if [ "$counter" -eq 0 ]; then
    echo Left: "$left" minutes
  fi
  sleep 1
done

min_bitrate=$(sort -n /tmp/bitrate.out | head -1)

echo -e "Minimum value of bitrate is: "$min_bitrate
sleep 2

output_script=$(cat << END
(while true
do
  "rx=\$(iw $iface link | grep bitrate | awk '{print \$3}' | awk -F. '{print \$1}' | awk 'NR==1')"
  if [ "\$rx" -lt "$(expr $min_bitrate - 100)" ]; then
    $output
  fi
  sleep 30
done) &
END
)

if [ "$output_forward" = "auto" ]; then
  sed -i '/exit 0/d' /etc/rc.local
  echo -e "$output_script\n\nexit 0" | tee -a /etc/rc.local  > /dev/null 2>&1
  echo -e "script appended to /etc/rc.local\n\n"
  sleep 2
  cat /etc/rc.local
fi


if [ "$output_forward" = "manual" ]; then
output_manual=$(cat << END

# If minimum value of bitrate is different than checked one
# please change second value in "lower then" condition within loop
#
# Paste this into "/etc/rc.local".
# You can do this through:
# - LuCI (System >> Startup >> Local Startup)
# - through CLI
#
END
)
echo "$output_manual"
echo "$output_script"
fi

rm -r /tmp/bitrate.out

exit 0

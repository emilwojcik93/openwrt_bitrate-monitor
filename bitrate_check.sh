#!/bin/sh

iface="$1"
net="lan"
output=$(echo "ifdown "$net" && sleep 5 && ifup "$net"")
time=601
rx=$(iw $iface link | grep bitrate | awk '{print $3}' | awk -F. '{print $1}' | awk 'NR==1')
tx=$(iw $iface link | grep bitrate | awk '{print $3}' | awk -F. '{print $1}' | awk 'NR==2')

if [ -z "$iface" ]; then
  echo -e "Please declare interface name as first argument\nwhile executing script eg.:\n\n./bitrate_check.sh wlan1\nsh bitrate_check.sh wlan0\n"
  exit 0
fi

if [ -f /root/temp.out ]; then
  touch /root/temp.out
fi

c=1
while [[ $c -le $time ]]
do
  counter0=$(expr "$time" - "$c")
  counter=$(expr "$counter0" % 60)
  counter1=$(expr "$time" - "$c")
  left=$(expr "$counter1" / 60)
  echo "$rx" | tee -a /root/temp.out > /dev/null 2>&1
  echo "$tx" | tee -a /root/temp.out > /dev/null 2>&1
  let c=c+1
  if [ "$counter" -eq 0 ]; then
    echo Left: "$left" minutes
  fi
  sleep 1
done

echo -e "Minimum value of bitrate is: "$(sort -n /root/temp.out | head -1)

min_bitrate=$(sort -n /root/temp.out | head -1)


output_script=$(cat << END

# If minimum value of bitrate is different than checked one
# please change second value in "lower then" condition within loop
#
# Paste this into "/etc/rc.local".
# You can do this through:
# - LuCI (System >> Startup >> Local Startup)
# - through CLI

(while true
do
  "rx=\$(iw $iface link | grep bitrate | awk '{print $3}' | awk -F. '{print $1}' | awk 'NR==1')"
  if [ "\$rx" -lt "$min_bitrate" ]; then
    $output
  fi
  sleep 5
done) &


END
)

echo "$output_script"

rm -r /root/temp.out

exit 0

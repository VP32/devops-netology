#!/usr/bin/env bash
ips=(192.168.0.1 173.194.222.113 87.250.250.242)
for ip in ${ips[@]}
do
  for attempt in {1..5}
  do
    curl -Is --connect-timeout 5 $ip:80 >/dev/null
    res=$?
    if (($res != 0))
    then
      echo "$ip failed with status $res, attempt no $attempt" >> log
    else
      echo "$ip is available, attempt no $attempt" >> log
    fi
  done
done
#!/usr/bin/env bash
ips=(192.168.0.1 173.194.222.113 87.250.250.242)
res=0

while (($res==0))
do
    for ip in ${ips[@]}
    do
        curl -Is --connect-timeout 5 $ip:80 >/dev/null
        res=$?
        if (($res != 0))
        then
          echo $ip >> error
          break
        fi
    done
done

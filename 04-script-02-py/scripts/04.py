#!/usr/bin/env python3
import socket
import time

TIMEOUT = 2  # интервал между проверками
ATTEMPTS = 5  # количество попыток проверки
services = {'drive.google.com': '0.0.0.0', 'mail.google.com': '0.0.0.0', 'google.com': '0.0.0.0'}
i = 0

while i < ATTEMPTS:
    for host, old_ip in services.items():
        new_ip = socket.gethostbyname(host)

        if new_ip != old_ip:
            print(f"[ERROR] {host} IP mismatch: {old_ip} {new_ip}")
        else:
            print(f"{host} - {new_ip}")

        services[host] = new_ip
        time.sleep(TIMEOUT)
    i += 1

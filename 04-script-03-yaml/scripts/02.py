#!/usr/bin/env python3
import os.path
import socket
import time
import json
import yaml

TIMEOUT = 2  # интервал между проверками
ATTEMPTS = 5  # количество попыток проверки
services = {'drive.google.com': '0.0.0.0', 'mail.google.com': '0.0.0.0', 'google.com': '0.0.0.0'}
i = 0

# создадим папку для файлов, если ее нет
OUTPUTDIR = os.path.join(os.getcwd(), "hostfiles")
os.makedirs(OUTPUTDIR, exist_ok=True)

while i < ATTEMPTS:
    for host, old_ip in services.items():
        new_ip = socket.gethostbyname(host)

        if new_ip != old_ip:
            print(f"[ERROR] {host} IP mismatch: {old_ip} {new_ip}")
        else:
            print(f"{host} - {new_ip}")

        # запишем данные в отдельные файлы
        output = {host: new_ip}
        with open(os.path.join(OUTPUTDIR, f"{host}.json"), "w") as jsonfile:
            jsonfile.write(json.dumps(output))

        with open(os.path.join(OUTPUTDIR, f"{host}.yml"), "w") as ymlfile:
            # обернем в массив, чтобы соблюдать формат: - имя сервиса: его IP
            yaml.dump([output], ymlfile, explicit_start=True)

        services[host] = new_ip
        time.sleep(TIMEOUT)
    # запишем данные по всем сервисам в общие файлы
    with open(os.path.join(OUTPUTDIR, "services.json"), "w") as jsonfile:
        jsonfile.write(json.dumps(services, indent=2))

    with open(os.path.join(OUTPUTDIR, "services.yml"), "w") as ymlfile:
        # обернем в массив, чтобы соблюдать формат: - имя сервиса: его IP
        services_list = []
        for host, ip in services.items():
            services_list.append({host: ip})
        yaml.dump(services_list, ymlfile, explicit_start=True)

    i += 1

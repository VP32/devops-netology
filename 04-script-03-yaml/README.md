# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

Критические ошибки, ведущие к невалидности json:

 - не хватает запятой между блоками в массиве elements
 - не хватает закрывающих кавычек у поля ip в втором блоке в elements
 - сам ip-адрес не внесен в кавычки

После исправления получается следующий json:

```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

Небольшие замечания, не являющиеся критическими ошибками и не ломающие валидность json:

 - в первом блоке elements странное значение в виде числа для ip
 - для улучшения читаемости можно улучшить форматирование, где-то есть лишние пробелы, где-то их не хватает, где-то можно добавить перенос строки, а в блоках elements не хватает отступов

После улучшения форматирования получается такой json:

```
{
  "info": "Sample JSON output from our service\t",
  "elements": [
    {
      "name": "first",
      "type": "server",
      "ip": 7175
    },
    {
      "name": "second",
      "type": "proxy",
      "ip": "71.78.22.43"
    }
  ]
}
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
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
```

### Вывод скрипта при запуске при тестировании:
```
vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts$ ./02.py 
[ERROR] drive.google.com IP mismatch: 0.0.0.0 64.233.162.194
[ERROR] mail.google.com IP mismatch: 0.0.0.0 173.194.222.18
[ERROR] google.com IP mismatch: 0.0.0.0 142.251.1.139
drive.google.com - 64.233.162.194
[ERROR] mail.google.com IP mismatch: 173.194.222.18 173.194.222.83
[ERROR] google.com IP mismatch: 142.251.1.139 142.251.1.113
drive.google.com - 64.233.162.194
mail.google.com - 173.194.222.83
google.com - 142.251.1.113
drive.google.com - 64.233.162.194
mail.google.com - 173.194.222.83
google.com - 142.251.1.113
drive.google.com - 64.233.162.194
mail.google.com - 173.194.222.83
google.com - 142.251.1.113
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat drive.google.com.json 
{"drive.google.com": "64.233.162.194"}vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat mail.google.com.json 
{"mail.google.com": "173.194.222.83"}vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat google.com.json 
{"google.com": "142.251.1.113"}vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat services.json 
{
  "drive.google.com": "64.233.162.194",
  "mail.google.com": "173.194.222.83",
  "google.com": "142.251.1.113"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat drive.google.com.yml 
---
- drive.google.com: 64.233.162.194
vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat mail.google.com.yml 
---
- mail.google.com: 173.194.222.83
vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat google.com.yml 
---
- google.com: 142.251.1.113
vladimir@linuxstage:~/learndevops/devops-netology/04-script-03-yaml/scripts/hostfiles$ cat services.yml 
---
- drive.google.com: 64.233.162.194
- mail.google.com: 173.194.222.83
- google.com: 142.251.1.113

```

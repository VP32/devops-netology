# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ                                                                  |
| ------------- |------------------------------------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | Будет ошибка, так как мы пытаемся сложить переменные типа int и string |
| Как получить для переменной `c` значение 12?  | Нужно привести к строке переменную а: `c = str(a) + b`                 |
| Как получить для переменной `c` значение 3?  | Нужно привести к int переменную b: `c = a + int(b)`                                    |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

dir = "~/learndevops/devops-netology"
bash_command = ["cd " + dir, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('изменено') != -1:
        prepare_result = os.path.join(dir, result.replace('\tизменено:   ', '').strip())
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
vladimir@linuxstage:~/learndevops/devops-netology/04-script-02-py/scripts$ ./02.py 
~/learndevops/devops-netology/04-script-02-py/scripts/01.py
~/learndevops/devops-netology/04-script-02-py/scripts/02.py
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

dir = os.getcwd()
if len(sys.argv) > 1:
    dir = sys.argv[1]

bash_command = ["cd " + dir, "git status 2>&1"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('fatal') != -1:
        print(f"Каталог {dir} не является git-репозиторием!")
    elif result.find('изменено') != -1:
        prepare_result = os.path.join(dir, result.replace('\tизменено:   ', '').strip())
        print(prepare_result)

```

### Вывод скрипта при запуске при тестировании:
```
vladimir@linuxstage:~/learndevops/devops-netology/04-script-02-py/scripts$ ./03.py ~
Каталог /home/vladimir не является git-репозиторием!
vladimir@linuxstage:~/learndevops/devops-netology/04-script-02-py/scripts$ ./03.py ~/learndevops/sysadm-homeworks/
vladimir@linuxstage:~/learndevops/devops-netology/04-script-02-py/scripts$ ./03.py 
/home/vladimir/learndevops/devops-netology/04-script-02-py/scripts/01.py
/home/vladimir/learndevops/devops-netology/04-script-02-py/scripts/02.py
/home/vladimir/learndevops/devops-netology/04-script-02-py/scripts/03.py
vladimir@linuxstage:~/learndevops/devops-netology/04-script-02-py/scripts$ 
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
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

```

### Вывод скрипта при запуске при тестировании:
```
vladimir@linuxstage:~/learndevops/devops-netology/04-script-02-py/scripts$ ./04.py 
[ERROR] drive.google.com IP mismatch: 0.0.0.0 64.233.164.194
[ERROR] mail.google.com IP mismatch: 0.0.0.0 64.233.164.19
[ERROR] google.com IP mismatch: 0.0.0.0 142.251.1.138
drive.google.com - 64.233.164.194
[ERROR] mail.google.com IP mismatch: 64.233.164.19 64.233.164.83
[ERROR] google.com IP mismatch: 142.251.1.138 142.251.1.139
drive.google.com - 64.233.164.194
mail.google.com - 64.233.164.83
google.com - 142.251.1.139
drive.google.com - 64.233.164.194
mail.google.com - 64.233.164.83
google.com - 142.251.1.139
drive.google.com - 64.233.164.194
mail.google.com - 64.233.164.83
google.com - 142.251.1.139

```

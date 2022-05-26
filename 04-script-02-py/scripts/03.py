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

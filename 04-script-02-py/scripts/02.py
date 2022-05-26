#!/usr/bin/env python3

import os

dir = "~/learndevops/devops-netology"
bash_command = ["cd " + dir, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('изменено') != -1:
        prepare_result = os.path.join(dir, result.replace('\tизменено:   ', '').strip())
        print(prepare_result)

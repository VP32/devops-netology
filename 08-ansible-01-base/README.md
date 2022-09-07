# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

**Решение**

Ссылка на репозиторий: [https://github.com/VP32/learn-ansible1](https://github.com/VP32/learn-ansible1)

Докер-окружение поднимал через docker-compose, манифест в файле https://github.com/VP32/learn-ansible1/blob/main/docker-compose.yml

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

**Решение**

Размещаю результаты второго задания в новой ветке репозитория (чтобы не искажать результаты первого задания).

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
```
vladimir@vp-learndevops:~/learndevops/learn-ansible1$ ansible-vault decrypt group_vars/deb/examp.yml 
Vault password: 
Decryption successful
vladimir@vp-learndevops:~/learndevops/learn-ansible1$ ansible-vault decrypt group_vars/el/examp.yml 
Vault password: 
Decryption successful
```

2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.

```
vladimir@vp-learndevops:~/learndevops/learn-ansible1$ ansible-vault encrypt_string
New Vault password: 
Confirm New Vault password: 
Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
PaSSw0rd
Encryption successful
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          30323362313336623430663037353939333365613033323763333766343566663634663065383135
          6434633430323963623330386236313735373934313866320a353264386236393037363738376431
          63623264656336326166623931396436313232363434616663613966363630353165356261626463
          3535316561326633640a623639626162393835656130306236393265653939396264613939303365
          6235 
```

```
vladimir@vp-learndevops:~/learndevops/learn-ansible1$ cat group_vars/all/exmp.yml 
---
  some_fact: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          30323362313336623430663037353939333365613033323763333766343566663634663065383135
          6434633430323963623330386236313735373934313866320a353264386236393037363738376431
          63623264656336326166623931396436313232363434616663613966363630353165356261626463
          3535316561326633640a623639626162393835656130306236393265653939396264613939303365
          6235
```
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

```
vladimir@vp-learndevops:~/learndevops/learn-ansible1$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] *******************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***********************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "PaSSw0rd"
}

PLAY RECAP ******************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).

Группу хостов добавил в [инвентори](https://github.com/VP32/learn-ansible1/blob/7ba1e884caae1f3be36aafd63aee7939377b3bf7/inventory/prod.yml#L10) 

Добавил хост под нее в манифест [docker-compose.yml](https://github.com/VP32/learn-ansible1/blob/7ba1e884caae1f3be36aafd63aee7939377b3bf7/docker-compose.yml#L11)

Добавил переменную в [group_vars/fedora/examp.yml](https://github.com/VP32/learn-ansible1/blob/task2/group_vars/fedora/examp.yml)

5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

Скрипт написал: https://github.com/VP32/learn-ansible1/blob/task2/run.sh

Результат запуска (вместе с изменениями из пункта 4):

```
vladimir@vp-learndevops:~/learndevops/learn-ansible1$ ./run.sh 
Creating network "learn-ansible1_default" with the default driver
Creating centos7     ... done
Creating fedora_host ... done
Creating ubuntu      ... done
Vault password: 

PLAY [Print os facts] *******************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [localhost]
ok: [fedora_host]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora_host] => {
    "msg": "Fedora"
}
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***********************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora_host] => {
    "msg": "fedora fact"
}
ok: [localhost] => {
    "msg": "PaSSw0rd"
}

PLAY RECAP ******************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora_host                : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Stopping ubuntu      ... done
Stopping centos7     ... done
Stopping fedora_host ... done
Removing ubuntu      ... done
Removing centos7     ... done
Removing fedora_host ... done
Removing network learn-ansible1_default

```


7. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

Зафиксировал изменения в том же репозитории, но в ветке [task2](https://github.com/VP32/learn-ansible1/tree/task2).


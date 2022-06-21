## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

**Ответ:**
- Паттерн Непрерывная интеграция позволяет выявлять ошибки в ПО на ранней стадии и быстро их устранять, что достигается за счет непрерывного слияния изменений из рабочих веток в основную ветку разработки и выполнении при этом частых сборок проекта и автоматического тестирования. Непрерывная доставка позволяет по ручному нажатию кнопки оперативно развертывать собранные с помощью непрерывной интеграции новые версии. То есть это возможность быстро выкатить в прод новую версию и откатить на предыдущую в случае ошибок. Наконец Непрерывное развертывание подразумевает автоматическое развертывание релиза после его сборки, в том числе в прод. Как правило, она применяется для тестовых или стендовых окружений, а для прода не применяется из-за рисков для бизнеса либо бюрократических процедур согласования релиза.
- По сути основополагающий принцип это расшифровка аббревиатуры IaaC - инфраструктура как код - процесс создания/настройки инфраструктуры аналогичен разработки программного обеспечения, инфраструктура описывается в виде кода.  Если говорить о паттернах, то в основе лежит непрерывная интеграция.

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

**Ответ:**

- Ansible позволяет выполнять разворачивание инфраструктуры без установки агентов на хосты, используя SSH-инфраструктуру. Тогда как прочие системы требуют использования Private Key Infrastructure.
- На мой взгляд наиболее надежный комбинированный метод, сочетающий pull и push. Если выбирать из двух, то думаю, что push, так как задачи запуска разворачивания и обновления в этом случае решаются централизованно с центрального сервера, а не отданы на откуп хостам.

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

VirtualBox и Vagrant устанавливал в предыдущих ДЗ:

```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-02-iaac$ virtualbox --help
Oracle VM VirtualBox VM Selector v6.1.32
(C) 2005-2022 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
```

```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-02-iaac$ vagrant --version
Vagrant 2.2.19
```

Установил Ansible:

```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-02-iaac$ ansible --version
ansible [core 2.12.6]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vladimir/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/vladimir/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```

При запуске vagrant up на одном из шагов была ошибка, связанная с тем, что на моем компьютере не было файла ключа ~/.ssh/id_rsa.pub:

```
TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: If you are using a module and expect the file to exist on the remote, see the remote_src option
fatal: [server1.netology]: FAILED! => {"changed": false, "msg": "Could not find or access '~/.ssh/id_rsa.pub' on the Ansible Controller.\nIf you are using a module and expect the file to exist on the remote, see the remote_src option"}
...ignoring
```

Тем не менее, Docker на виртуальную машину ставился и команда docker ps на ней отрабатывала. Для чистоты опыта удалил эту машину через vagrant destroy -f, сгенерировал ключ командой ssh-keygen -t rsa, и тогда vagrant up нормально отработал:

```
...
PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

vladimir@linuxstage:~/learndevops/devops-netology/05-virt-02-iaac/src/vagrant$ vagrant ssh
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Tue 21 Jun 2022 03:03:11 PM UTC

  System load:  0.11               Users logged in:          0
  Usage of /:   13.6% of 30.88GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 24%                IPv4 address for eth0:    10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1:    192.168.56.11
  Processes:    124


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Tue Jun 21 15:00:07 2022 from 10.0.2.2
vagrant@server1:~$ service docker status
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-06-21 14:59:57 UTC; 3min 30s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 29116 (dockerd)
      Tasks: 7
     Memory: 39.7M
     CGroup: /system.slice/docker.service
             └─29116 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.403339719Z" level=warning msg="Your kernel does not support CPU >
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.403344235Z" level=warning msg="Your kernel does not support cgro>
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.403349462Z" level=warning msg="Your kernel does not support cgro>
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.404140313Z" level=info msg="Loading containers: start."
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.597627697Z" level=info msg="Default bridge (docker0) is assigned>
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.701942463Z" level=info msg="Loading containers: done."
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.768470897Z" level=info msg="Docker daemon" commit=a89b842 graphd>
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.768568574Z" level=info msg="Daemon has completed initialization"
Jun 21 14:59:57 server1 dockerd[29116]: time="2022-06-21T14:59:57.822436977Z" level=info msg="API listen on /run/docker.sock"
Jun 21 14:59:57 server1 systemd[1]: Started Docker Application Container Engine.
vagrant@server1:~$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
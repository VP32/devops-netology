# Домашнее задание к занятию "Установка кластера K8s"



### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

### Решение

Устанавливаю кластер через kubespray в Яндекс Облаке.

Поскольку у меня было пустое облако, то вначале создавал сеть и подсеть:

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/3.2/src$ yc vpc network create --name k8s-network --description "Network for k8s" --folder-id b1g93e8c1rj5ohc6pk80
id: enpm4ll0v8dd049ks0od
folder_id: b1g93e8c1rj5ohc6pk80
created_at: "2023-03-26T09:06:14Z"
name: k8s-network
description: Network for k8s
```

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/3.2/src$ yc vpc subnet create --name k8s-subnet-1 --description "K8S subnet" --network-id=enpm4ll0v8dd049ks0od --zone ru-central1-c --range 192.168.0.0/24
id: b0c78ho3jfrl4vj5ibbc
folder_id: b1g93e8c1rj5ohc6pk80
created_at: "2023-03-26T09:39:35Z"
name: k8s-subnet-1
description: K8S subnet
network_id: enpm4ll0v8dd049ks0od
zone_id: ru-central1-c
v4_cidr_blocks:
  - 192.168.0.0/24
```

Затем с помощью скрипта из репозитория aak74/kubernetes-for-beginners создал 1 мастер-ноду и 4 воркер-ноды в ранее созданной подсети:

```bash
#!/bin/bash

set -e

function create_vm {
  local NAME=$1

  YC=$(cat <<END
    yc compute instance create \
      --name $NAME \
      --hostname $NAME \
      --zone ru-central1-c \
      --network-interface subnet-name=k8s-subnet-1,nat-ip-version=ipv4 \
      --memory 2 \
      --cores 2 \
      --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2004-lts,type=network-ssd,size=20 \
      --ssh-key /home/vladimir/.ssh/id_yc_rsa.pub
END
)
#  echo "$YC"
  eval "$YC"
}

create_vm "master1"
create_vm "node1"
create_vm "node2"
create_vm "node3"
create_vm "node4"
```

Получились следующие инстансы:

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/3.2/src$ yc compute instances list
+----------------------+---------+---------------+---------+----------------+--------------+
|          ID          |  NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP  |
+----------------------+---------+---------------+---------+----------------+--------------+
| ef3eu87rbmrmgcrsjtlr | node3   | ru-central1-c | RUNNING | 84.201.169.252 | 192.168.0.7  |
| ef3liruk7b413eka89es | node1   | ru-central1-c | RUNNING | 51.250.40.153  | 192.168.0.14 |
| ef3ngu03u9s4tgkc7f6v | node2   | ru-central1-c | RUNNING | 84.201.168.251 | 192.168.0.10 |
| ef3tqat1pqr962vl9f9e | master1 | ru-central1-c | RUNNING | 84.201.148.137 | 192.168.0.12 |
| ef3v8bsi0htbi71nbnei | node4   | ru-central1-c | RUNNING | 84.201.168.21  | 192.168.0.25 |
+----------------------+---------+---------------+---------+----------------+--------------+
```

После клонирования репозитория kubespray с помощью билдера создаю инвентори с моими ВМ:

```
vladimir@vp32hard:~/learndevops/kubespray$ declare -a IPS=(84.201.169.252 51.250.40.153 84.201.168.251 84.201.148.137 84.201.168.21)
vladimir@vp32hard:~/learndevops/kubespray$ CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
DEBUG: Adding group all
DEBUG: Adding group kube_control_plane
DEBUG: Adding group kube_node
DEBUG: Adding group etcd
DEBUG: Adding group k8s_cluster
DEBUG: Adding group calico_rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node3 to group all
DEBUG: adding host node4 to group all
DEBUG: adding host node5 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node2 to group etcd
DEBUG: adding host node3 to group etcd
DEBUG: adding host node1 to group kube_control_plane
DEBUG: adding host node2 to group kube_control_plane
DEBUG: adding host node1 to group kube_node
DEBUG: adding host node2 to group kube_node
DEBUG: adding host node3 to group kube_node
DEBUG: adding host node4 to group kube_node
DEBUG: adding host node5 to group kube_node
```

Корректирую инвентори. Прописываю внутренние адреса в переменных ip, access_ip, прописываю пользователя в ansible_user: yc-user.

Итоговый файл hosts.yaml:

```yaml
all:
  hosts:
    master:
      ansible_host: 84.201.148.137
      ansible_user: yc-user
      ip: 192.168.0.12
      access_ip: 192.168.0.12
    node1:
      ansible_host: 84.201.169.252
      ansible_user: yc-user
      ip: 192.168.0.7
      access_ip: 192.168.0.7
    node2:
      ansible_host: 51.250.40.153
      ansible_user: yc-user
      ip: 192.168.0.14
      access_ip: 192.168.0.14
    node3:
      ansible_host: 84.201.168.251
      ansible_user: yc-user
      ip: 192.168.0.10
      access_ip: 192.168.0.10
    node4:
      ansible_host: 84.201.168.21
      ansible_user: yc-user
      ip: 192.168.0.25
      access_ip: 192.168.0.25
  children:
    kube_control_plane:
      hosts:
        master:
    kube_node:
      hosts:
        node1:
        node2:
        node3:
        node4:
    etcd:
      hosts:
        master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```

Далее в файле inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml прописываю для доступа извне внешний ip мастер-ноды в параметре supplementary_addresses_in_ssl_keys:

```
## Supplementary addresses that can be added in kubernetes ssl keys.
## That can be useful for example to setup a keepalived virtual IP
supplementary_addresses_in_ssl_keys: [84.201.148.137]
```

Проверяю, что CRI указан containerd:

```
## Container runtime
## docker for docker, crio for cri-o and containerd for containerd.
## Default: containerd
container_manager: containerd
```

Выполняю плейбук:

```
vladimir@vp32hard:~/learndevops/kubespray$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v
Using /home/vladimir/learndevops/kubespray/ansible.cfg as config file
[WARNING]: Skipping callback plugin 'ara_default', unable to load
...
```

После успешного выполнения плейбука проверяю с мастер-ноды работу кластера командой `kubectl get nodes`:

```
vladimir@vp32hard:~/learndevops/kubespray$ ssh yc-user@84.201.148.137
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-137-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Introducing Expanded Security Maintenance for Applications.
   Receive updates to over 25,000 software packages with your
   Ubuntu Pro subscription. Free for personal use.

     https://ubuntu.com/pro
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Sun Mar 26 11:12:32 2023 from 95.72.81.66
yc-user@master:~$ kubectl get nodes
E0326 11:13:12.403079   21339 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0326 11:13:12.404012   21339 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0326 11:13:12.404869   21339 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0326 11:13:12.406220   21339 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
E0326 11:13:12.407564   21339 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
```

Нужно подложить конфиг для kubectl, после его копирования в ./kube/config команда `kubectl get nodes` успешно отрабатывает:

```
yc-user@master:~$ mkdir .kube
yc-user@master:~$ sudo cp /etc/kubernetes/admin.conf ~/.kube/config
yc-user@master:~$ kubectl get nodes
error: error loading config file "/home/yc-user/.kube/config": open /home/yc-user/.kube/config: permission denied
yc-user@master:~$ ls -la .kube
total 16
drwxrwxr-x 2 yc-user yc-user 4096 Mar 26 11:21 .
drwxr-xr-x 7 yc-user yc-user 4096 Mar 26 11:21 ..
-rw------- 1 root    root    5649 Mar 26 10:42 config
yc-user@master:~$ chown yc-user .kube/config 
chown: changing ownership of '.kube/config': Operation not permitted
yc-user@master:~$ sudo !!
sudo chown yc-user .kube/config 
yc-user@master:~$ ls -la .kube
total 16
drwxrwxr-x 2 yc-user yc-user 4096 Mar 26 11:21 .
drwxr-xr-x 7 yc-user yc-user 4096 Mar 26 11:21 ..
-rw------- 1 yc-user root    5649 Mar 26 10:42 config
yc-user@master:~$ kubectl get nodes
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   40m   v1.26.3
node1    Ready    <none>          39m   v1.26.3
node2    Ready    <none>          39m   v1.26.3
node3    Ready    <none>          38m   v1.26.3
node4    Ready    <none>          39m   v1.26.3
```

Пробую подключиться с локальной машины. После внесения данных по созданному кластеру в локальный конфиг и установки контекста команда успешно отрабатывает:

```
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME     STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master   Ready    control-plane   66m   v1.26.3   192.168.0.12   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1    Ready    <none>          64m   v1.26.3   192.168.0.7    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2    Ready    <none>          64m   v1.26.3   192.168.0.14   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3    Ready    <none>          64m   v1.26.3   192.168.0.10   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4    Ready    <none>          64m   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
vladimir@vp32hard:~/learndevops/kubespray$ 
```

![1.png](img%2F1.png)

## Дополнительные задания (со звездочкой*)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.**   Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой дополнительные (необязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA
2. Использовать нечетное кол-во Master-node
3. Для cluster ip использовать keepalived или другой способ

### Правила приема работы

1. Домашняя работа оформляется в своем Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md

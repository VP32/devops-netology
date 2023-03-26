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

Затем с помощью скрипта из репозитория **aak74/kubernetes-for-beginners** создал 1 мастер-ноду и 4 воркер-ноды в ранее созданной подсети:

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

Корректирую инвентори. Прописываю внутренние адреса в переменных ip, access_ip (без этого исправления не накатывался плейбук), прописываю пользователя в ansible_user: yc-user.

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


------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA
2. Использовать нечетное кол-во Master-node
3. Для cluster ip использовать keepalived или другой способ

### Решение

Создал 3 мастер-ноды, 4 воркер-ноды.

Скрипт на создание ВМ:

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
create_vm "master2"
create_vm "master3"
create_vm "node1"
create_vm "node2"
create_vm "node3"
create_vm "node4"
```

Создались следующие ВМ:

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/3.2/src/task2$ yc compute instance list
+----------------------+---------+---------------+---------+----------------+--------------+
|          ID          |  NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP  |
+----------------------+---------+---------------+---------+----------------+--------------+
| ef310aeuuctbns72m9lq | node4   | ru-central1-c | RUNNING | 84.201.181.120 | 192.168.0.25 |
| ef34gkqqdther0ebhlht | master1 | ru-central1-c | RUNNING | 84.201.170.180 | 192.168.0.11 |
| ef38br13e5jvbu8dd27t | node1   | ru-central1-c | RUNNING | 84.201.180.215 | 192.168.0.22 |
| ef3j65oj8klu1q8jb95l | node3   | ru-central1-c | RUNNING | 84.201.181.162 | 192.168.0.6  |
| ef3k8hathqa9mfskvnu3 | master3 | ru-central1-c | RUNNING | 84.201.181.17  | 192.168.0.33 |
| ef3l8d2f3738010mk16m | master2 | ru-central1-c | RUNNING | 84.201.169.232 | 192.168.0.17 |
| ef3u81h65oiinfpfpeca | node2   | ru-central1-c | RUNNING | 84.201.181.183 | 192.168.0.21 |
+----------------------+---------+---------------+---------+----------------+--------------+
```


Попробовал сначала сделать, как описано в ссылке из лекции: https://github.com/BigKAA/youtube/blob/master/kubeadm/ha_cluster.md

Но уперся в то, что по команде `ip n l` у меня не видно кластерного ip-aдреса. И как будто keepalived видит только машину, на которой он запущен и тут же становится мастером на ней. Манипуляции с настройками iptables не помогли. Также мне пока непонятно, как транслировать наружу из Яндекс-облака выбранный мной кластерный адрес из внутренней подсети с нодами.

Поэтому попробовал сделать иначе. Создал сетевой балансировщик Яндекс Облака, указал ему в качестве целевой группы мои 3 мастер-ноды. В качестве обработчика сделал проброс с порта 7443 внешнего ip-адреса балансировщика на порт 6443 в подсети кластера. 

Вот так я это сделал:

Создаем сетевой балансировщик:

Создаем целевую группу, вносим в нее все наши мастер-ноды:

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/3.2/src/task2$ yc load-balancer target-group create \
--region-id ru-central1 \
--name k8s-tg \
--target subnet-id=b0c78ho3jfrl4vj5ibbc,address=192.168.0.11 \
--target subnet-id=b0c78ho3jfrl4vj5ibbc,address=192.168.0.17 \
--target subnet-id=b0c78ho3jfrl4vj5ibbc,address=192.168.0.33
done (1s)
id: enp5otptieosupmnd1nv
folder_id: b1g93e8c1rj5ohc6pk80
created_at: "2023-03-26T15:10:41Z"
name: k8s-tg
region_id: ru-central1
targets:
  - subnet_id: b0c78ho3jfrl4vj5ibbc
    address: 192.168.0.11
  - subnet_id: b0c78ho3jfrl4vj5ibbc
    address: 192.168.0.17
  - subnet_id: b0c78ho3jfrl4vj5ibbc
    address: 192.168.0.33
```


Создаем балансировщик с целевой группой и обработчиком:

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/3.2/src/task2$ yc load-balancer network-load-balancer create \
  --region-id ru-central1 \
  --name k8s-balancer \
  --listener name=ks8-listener,external-ip-version=ipv4,port=7443,target-port=6443,protocol=tcp \
  --target-group target-group-id=enp5otptieosupmnd1nv,healthcheck-name=k8s-health,healthcheck-interval=2s,healthcheck-timeout=1s,healthcheck-unhealthythreshold=2,healthcheck-healthythreshold=2,healthcheck-tcp-port=6443
done (2s)
id: enp1tcg6kjk9uq3ml609
folder_id: b1g93e8c1rj5ohc6pk80
created_at: "2023-03-26T15:23:58Z"
name: k8s-balancer
region_id: ru-central1
status: ACTIVE
type: EXTERNAL
listeners:
  - name: ks8-listener
    address: 51.250.43.243
    port: "7443"
    protocol: TCP
    target_port: "6443"
    ip_version: IPV4
attached_target_groups:
  - target_group_id: enp5otptieosupmnd1nv
    health_checks:
      - name: k8s-health
        interval: 2s
        timeout: 1s
        unhealthy_threshold: "2"
        healthy_threshold: "2"
        tcp_options:
          port: "6443"
```
  
Добавим полученный ip-адрес обработчика в конфиг `inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml` в параметр supplementary_addresses_in_ssl_keys.

Запустим плейбук:

```
vladimir@vp32hard:~/learndevops/kubespray$ ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v 
...
```

По какой-то причине плейбук полностью успешно отработал только со второго запуска, при первом были ошибки с сертификатами для master2, master3. Запустил повторно, отработал без ошибок и ноды видны балансировщиком в статусе Healthy.

После успешного применения плейбука внесем в локальный конфиг сведения о кластере. В качестве адреса сервера указываем ip-адрес балансировщика 51.250.43.243 и порт балансировщика 7443.
После чего команда kubectl get nodes успешно отрабатывает с локальной машины:

```
vladimir@vp32hard:~/learndevops/kubespray$ cat ~/.kube/config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0...==
    server: https://192.168.1.68:16443
  name: microk8s-cluster
- cluster:
    certificate-authority-data: LS0...==
    server: https://51.250.43.243:7443
  name: yc-k8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
- context:
    cluster: yc-k8s-cluster
    user: yc-k8s-admin
  name: yc-k8s
current-context: yc-k8s
kind: Config
preferences: {}
users:
- name: admin
  user:
    token: VnNVMHM2bjBIczB6dlYrTDd3c2ZXTDd5c0FJM3kzaDNxaHRJYURiMzY1VT0K
- name: yc-k8s-admin
  user:
    client-certificate-data: LS0t...==
    client-key-data: LS0...=

```


```
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes
NAME      STATUS   ROLES           AGE     VERSION
master1   Ready    control-plane   20m     v1.26.3
master2   Ready    control-plane   9m33s   v1.26.3
master3   Ready    control-plane   9m7s    v1.26.3
node1     Ready    <none>          7m41s   v1.26.3
node2     Ready    <none>          7m40s   v1.26.3
node3     Ready    <none>          7m40s   v1.26.3
node4     Ready    <none>          7m41s   v1.26.3
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME      STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   Ready    control-plane   20m     v1.26.3   192.168.0.11   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master2   Ready    control-plane   9m39s   v1.26.3   192.168.0.17   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master3   Ready    control-plane   9m13s   v1.26.3   192.168.0.33   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1     Ready    <none>          7m47s   v1.26.3   192.168.0.22   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2     Ready    <none>          7m46s   v1.26.3   192.168.0.21   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3     Ready    <none>          7m46s   v1.26.3   192.168.0.6    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4     Ready    <none>          7m47s   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
vladimir@vp32hard:~/learndevops/kubespray$ 
```

Проверим работу при условии отключении одной мастер-ноды.


Гасим первую мастер-ноду. Кластер отзывается, нода master1 не готова:

```
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME      STATUS     ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   NotReady   control-plane   32m   v1.26.3   192.168.0.11   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master2   Ready      control-plane   21m   v1.26.3   192.168.0.17   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master3   Ready      control-plane   21m   v1.26.3   192.168.0.33   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1     Ready      <none>          19m   v1.26.3   192.168.0.22   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2     Ready      <none>          19m   v1.26.3   192.168.0.21   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3     Ready      <none>          19m   v1.26.3   192.168.0.6    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4     Ready      <none>          19m   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
vladimir@vp32hard:~/learndevops/kubespray$ 
```

Включаем первую мастер-ноду. Кластер отзывается, нода через некоторое время возвращается в статус Ready:

```
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   Ready    control-plane   35m   v1.26.3   192.168.0.11   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master2   Ready    control-plane   24m   v1.26.3   192.168.0.17   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master3   Ready    control-plane   24m   v1.26.3   192.168.0.33   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1     Ready    <none>          22m   v1.26.3   192.168.0.22   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2     Ready    <none>          22m   v1.26.3   192.168.0.21   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3     Ready    <none>          22m   v1.26.3   192.168.0.6    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4     Ready    <none>          22m   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
```


Выключаем третью мастер-ноду. Кластер отзывается, нода master3 не готова:

```
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME      STATUS     ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   Ready      control-plane   38m   v1.26.3   192.168.0.11   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master2   Ready      control-plane   27m   v1.26.3   192.168.0.17   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master3   NotReady   control-plane   27m   v1.26.3   192.168.0.33   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1     Ready      <none>          25m   v1.26.3   192.168.0.22   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2     Ready      <none>          25m   v1.26.3   192.168.0.21   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3     Ready      <none>          25m   v1.26.3   192.168.0.6    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4     Ready      <none>          25m   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
```


Включаем третью мастер-ноду. Кластер отзывается, нода master3 через некоторое время возвращается в статус Ready:

```
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME      STATUS     ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   Ready      control-plane   41m   v1.26.3   192.168.0.11   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master2   Ready      control-plane   30m   v1.26.3   192.168.0.17   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master3   NotReady   control-plane   30m   v1.26.3   192.168.0.33   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1     Ready      <none>          28m   v1.26.3   192.168.0.22   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2     Ready      <none>          28m   v1.26.3   192.168.0.21   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3     Ready      <none>          28m   v1.26.3   192.168.0.6    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4     Ready      <none>          28m   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
vladimir@vp32hard:~/learndevops/kubespray$ kubectl get nodes -o wide
NAME      STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master1   Ready    control-plane   42m   v1.26.3   192.168.0.11   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master2   Ready    control-plane   31m   v1.26.3   192.168.0.17   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
master3   Ready    control-plane   31m   v1.26.3   192.168.0.33   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node1     Ready    <none>          29m   v1.26.3   192.168.0.22   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node2     Ready    <none>          29m   v1.26.3   192.168.0.21   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node3     Ready    <none>          29m   v1.26.3   192.168.0.6    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
node4     Ready    <none>          29m   v1.26.3   192.168.0.25   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.0
vladimir@vp32hard:~/learndevops/kubespray$ 
```
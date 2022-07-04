# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
- Что такое Overlay Network?

**Ответы:**

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?

В случае режима работы global сервис автоматически устанавливается во все ноды кластера. В случае режима replication необходимо указать количество реплик сервиса, и он будет автоматически установлен на то количество нод, сколько указали реплик.

- Какой алгоритм выбора лидера используется в Docker Swarm кластере?

Лидер выбирается по алгортиму Raft consensus. Он основнан на выборах лидера по большинству голосов (откликов) между узлами и репликации лога изменений от лидера к узлам. В случае недоступности лидера выбирается новый лидер.

- Что такое Overlay Network?

Это виртуальная распределенная сеть, которую используют контейнеры, она связывает физические хосты, на которых запущен Докер. Создается поверх сетей, используемых на хостах. С ее помощью Докер-контейнеры могут взаимодействовать друг с другом. Используется в Docker Swarm.

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```

**Результат:**

Подготовил 6 ВМ по исходному коду из ДЗ. Подключился по ssh к первой ноде, вызвал команду:

```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-05-docker-swarm/src/terraform$ ssh centos@51.250.94.76
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
urzw3tnshb82q0lhynz9h8fu0 *   node01.netology.yc   Ready     Active         Leader           20.10.17
j7v8q60rvr2912d9z1hu82z4p     node02.netology.yc   Ready     Active         Reachable        20.10.17
tqv5cxcwvw7gk3tbnuy6mx4on     node03.netology.yc   Ready     Active         Reachable        20.10.17
i8x6j4wb6kx2bb8mffc6j10rz     node04.netology.yc   Ready     Active                          20.10.17
idt16au9acvb7peym8i6ufg9n     node05.netology.yc   Ready     Active                          20.10.17
5lgpfs47mbi98ydt65l2hz5s5     node06.netology.yc   Ready     Active                          20.10.17
[centos@node01 ~]$
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```

**Результат:**

Из первой ноды из предыдущего задания вызвал команду:

```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-05-docker-swarm/src/terraform$ ssh centos@51.250.94.76
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
cmnfwl7w3efc   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
n8pvmmuxuudx   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
him1anqwwstx   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
20jh9ko6gvnf   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
ygz8b040tul7   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
wp7uq4mb93fe   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
gj6nqodzozt1   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
l7h9z8j43dk9   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0                        
```

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

**Результат:**

Команду ввел:

```
[centos@node01 ~]$ sudo -i
[root@node01 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-LIsE0NQuo12vVSgQUUbG//hPFAkjsGn2YKOzWSWmG1o

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```

Эта команда включает на ноде-менеджере защиту TLS-ключа и ключа, используемого для шифрования и дешифрования логов Raft. После перезапуска Докер-демона (например, при рестарте виртуалки) включится блокировка этого менеджера Swarm. Проверил также, с других нод эта нода видна как Unreachable. Для дальнейшей работы менеджера и доступа к нему с этой включенной защитой, необходимо будет разблокировать менеджер, ведя команду docker swarm unlock и ввести ключ, который вывела нам команда. По сути, это дополнительная защита кластера.
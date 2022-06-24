## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

**Ответ:** 
 
Использовал базовый образ nginx:1.23.0.

Использовал для сборки следующий Dockerfile:

```
FROM nginx:1.23.0
COPY ./index.html /usr/share/nginx/html/index.html
```

index.html:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I'm DevOps Engineer!</h1>
</body>
</html>
```
Ссылка на полученный форк: https://hub.docker.com/repository/docker/vlpol32/vp32-nginx

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

**Ответ:**

- Высоконагруженное монолитное java веб-приложение - тут на мой взгляд лучше использовать физическую машину, так как высокая нагрузка, и нужно минимизировать все накладные расходы, и монолитная архитектура, не предполагающая возможного распараллеливания.
- Nodejs веб-приложение - классический вариант применения контейнеров Докер. Stateless-сервис, допускающий распараллеливание и микросервисную архитектуру.
- Мобильное приложение c версиями для Android и iOS - тут скорее виртуальная машина, так как необходимо работать с графическим интерфейсом;
- Шина данных на базе Apache Kafka - контейнер Докера явно не подходит, так как критична потеря данных, которая возможна при перезапуске контейнера. Думаю тут подойдет виртуальная машина. 
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana - Elasticsearch лучше разместить на виртуальных машинах, так как предполагается хранение и обработка данных, logstah, kibana - можно в докер-контейнеры, они сами по себе данных не хранят, и как раз подходит требование по масштабированию.
- Мониторинг-стек на базе Prometheus и Grafana - эти сервисы данные не хранят, поэтому можно вынести их в Докер-контейнеры, кроме того, их можно масштабировать и распараллеливать
- MongoDB, как основное хранилище данных для java-приложения - думаю тут оптимальной будет виртуальная машина. Из-за задач хранения данных контейнер не подходит. В случае высокой нагрузки можно использовать физический сервер.
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry. Docker Registry полагаю лучше вынести на виртуальную машину, аналогично и БД для сервера Gitlab, так как подразумевается хранение данных. Сам сервер Gitlab можно в Докер-контейнеры, его можно распараллелить, подняв несколько инстансов. 


## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

**Решение:**

Так как простой запуск контейнеров командой docker run без дополнительных аргументов приводит к тому, что они закрываются сразу же после запуска, сочетал запуск в фоне с запуском команды bash в каждом контейнере. И при этом мониторовал папку data:

```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-03-docker/task3$ docker run -v /home/vladimir/learndevops/devops-netology/05-virt-03-docker/task3/data:/data --name centos-d -d -it centos bash
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete 
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
e295389d9d32d4220a9931d0e773e675944341764108bdd78c89f875a0e3593f
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-03-docker/task3$ docker run -v /home/vladimir/learndevops/devops-netology/05-virt-03-docker/task3/data:/data --name debian-d -d -it debian bash
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
1339eaac5b67: Pull complete 
Digest: sha256:859ea45db307402ee024b153c7a63ad4888eb4751921abbef68679fc73c4c739
Status: Downloaded newer image for debian:latest
9b57af851d36606781ac5ca561f6f216d1164d6a160e121c467807cef9dc9533
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-03-docker/task3$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS          PORTS     NAMES
9b57af851d36   debian    "bash"    11 seconds ago   Up 10 seconds             debian-d
e295389d9d32   centos    "bash"    29 seconds ago   Up 28 seconds             centos-d
```

Заполняем файлы и проверяем содержимое:
```
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-03-docker/task3$ docker exec -it centos-d bash
[root@e295389d9d32 /]# echo 'I am from Centos' > /data/first
[root@e295389d9d32 /]# cat /data/first 
I am from Centos
[root@e295389d9d32 /]# exit
exit
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-03-docker/task3$ echo 'I am from host' > ./data/second
vladimir@linuxstage:~/learndevops/devops-netology/05-virt-03-docker/task3$ docker exec -it debian-d bash
root@9b57af851d36:/# ls /data -lah
total 16K
drwxrwxr-x 2 1000 1000 4.0K Jun 24 14:42 .
drwxr-xr-x 1 root root 4.0K Jun 24 14:40 ..
-rw-r--r-- 1 root root   17 Jun 24 14:41 first
-rw-rw-r-- 1 1000 1000   15 Jun 24 14:42 second
root@9b57af851d36:/# cat /data/first 
I am from Centos
root@9b57af851d36:/# cat /data/second 
I am from host
root@9b57af851d36:/# 
```



## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

**Ответ:**

Сделал. Ссылка на образ: https://hub.docker.com/repository/docker/vlpol32/ansible

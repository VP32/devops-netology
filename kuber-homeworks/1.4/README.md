# Домашнее задание к занятию "Сетевое взаимодействие в K8S. Часть 1"


### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod'а внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров - nginx и multitool с кол-вом реплик 3шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 - nginx 80, по 9002 - multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment'а и Service в решении, а также скриншоты или вывод команды п.4

**Решение**

Итоговый манифест. Брал за основу предыдущее ДЗ:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1-deployment
  labels:
    app: task1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: task1
  template:
    metadata:
      labels:
        app: task1
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "11443"
---
apiVersion: v1
kind: Service
metadata:
  name: task1-svc
spec:
  selector:
    app: task1
  ports:
  - name: task1-nginx-svc-port
    port: 9001
    targetPort: 80
  - name: task1-multitool-svc-port
    port: 9002
    targetPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: outer-pod
spec:
  containers:
  - name: multitool
    image: wbitt/network-multitool
    ports:
    - containerPort: 8080

```


Применил манифест. Все сущности создались удачно. Вывод команды curl на порты 9001 и 9002 по ip-адресу сервиса:

![1-1.png](img%2F1-1.png)

Также проверил curl на порты 9001 и 9002 по доменному имени сервиса:

![1-2.png](img%2F1-2.png)

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

**Решение**

Итоговый манифест. Добавил в манифест из задания 1 блок с сервисом task2-np-svc:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task2-deployment
  labels:
    app: task2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: task2
  template:
    metadata:
      labels:
        app: task2
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "11443"
---
apiVersion: v1
kind: Service
metadata:
  name: task2-svc
spec:
  selector:
    app: task2
  ports:
  - name: task2-nginx-svc-port
    port: 9001
    targetPort: 80
  - name: task2-multitool-svc-port
    port: 9002
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: task2-np-svc
spec:
  selector:
    app: task2
  ports:
  - name: task2-nginx-np-svc-port
    protocol: TCP
    nodePort: 30000
    port: 80
  - name: task2-multitool-np-svc-port
    protocol: TCP
    port: 8080
    nodePort: 30001
  type: NodePort
---
apiVersion: v1
kind: Pod
metadata:
  name: outer-pod
spec:
  containers:
  - name: multitool
    image: wbitt/network-multitool
    ports:
    - containerPort: 8080

```

Применил манифест. Все создалось успешно. Для проверки доступности через NodePort использовал curl на ip-адрес ноды моего кластера с указанными в манифесте портами 30000 и 30001:

![2.png](img%2F2.png)

------


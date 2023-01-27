# Домашнее задание к занятию "Сетевое взаимодействие в K8S. Часть 2"



### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с кол-вом реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service'ы, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment'а и Service в решении, а также скриншоты или вывод команды п.4.

**Решение**

Итоговый манифест:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: task1-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: task1-nginx
  template:
    metadata:
      labels:
        app: task1-nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
          name: nginx-port
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: task1-nginx
  ports:
  - name: task1-nginx-svc-port
    port: 80
    targetPort: nginx-port
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: task1-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: task1-multitool
  template:
    metadata:
      labels:
        app: task1-multitool
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
          name: multitool-port
        env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "11443"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  selector:
    app: task1-multitool
  ports:
  - name: task1-multitool-svc-port
    port: 80
    targetPort: multitool-port

```

Применяю манифест, все успешно создается и стартует:

![1-1.png](img%2F1-1.png)

Проверяю видимость приложений через сервисы: frontend видит backend и наоборот:

![1-2.png](img%2F1-2.png)


------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в microk8s
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера microk8s, так чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера
4. Предоставить манифесты, а также скриншоты или вывод команды п.2

**Решение**

Ingress-контроллер ранее включил с помощью команды `microk8s enable ingress`, он включен:

![2-1.png](img%2F2-1.png)

------


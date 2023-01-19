# Домашнее задание к занятию "Запуск приложений в K8S"


------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod'а

1. Создать Deployment приложения состоящего из двух контейнеров - nginx и multitool. Решить возникшую ошибку
2. После запуска увеличить кол-во реплик работающего приложения до 2
3. Продемонстрировать кол-во подов до и после масштабирования
4. Создать Service, который обеспечит доступ до реплик приложений из п.1
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl` что из пода есть доступ до приложений из п.1

**Решение**

1. Манифест для Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1-deployment
  labels:
    app: task1
spec:
  replicas: 1
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
```

Ошибка состояла в том, что в multitool по умолчанию так же стартовал nginx и пытался занять порт 80, который уже был занят nginx из контейнера nginx.
Выяснил это по логам пода:

![1-1.png](img%2F1-1.png)

Согласно [документации по multitool](https://github.com/wbitt/Network-MultiTool#configurable-http-and-https-ports) поменял для него порты через переменные окружения в манифесте. После этого оба контейнера заработали в одном поде:

![1-1-1.png](img%2F1-1-1.png)

2, 3:

Поменял в манифесте параметр replicas на 2, применил манифест. Подов стало 2. Результат:

![1-3.png](img%2F1-3.png)

Манифест, который применял:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1-deployment
  labels:
    app: task1
spec:
  replicas: 2
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
```

4. Сервис создал:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1-deployment
  labels:
    app: task1
spec:
  replicas: 2
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
    port: 80
    targetPort: 80
  - name: task1-multitool-svc-port
    port: 8080
    targetPort: 8080
```

Проброс портов до nginx и multitool:

![1-4-1.png](img%2F1-4-1.png)

![1-4-2.png](img%2F1-4-2.png)

Проверка доступности с помощью curl:

![1-4-3.png](img%2F1-4-3.png)

5. Создал под. Полученный манифест:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task1-deployment
  labels:
    app: task1
spec:
  replicas: 2
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
    port: 80
    targetPort: 80
  - name: task1-multitool-svc-port
    port: 8080
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


Полученные поды и проверка доступности из пода до приложений:
Проверка с первой репликой:

![1-5-1.png](img%2F1-5-1.png)

Проверка со второй репликой:

![1-5-2.png](img%2F1-5-2.png)

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения
2. Убедиться, что nginx не стартует. В качестве init-контейнера взять busybox
3. Создать и запустить Service. Убедиться, что nginx запустился
4. Продемонстрировать состояние пода до и после запуска сервиса

------
 
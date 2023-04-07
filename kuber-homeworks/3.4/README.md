# Домашнее задание к занятию "Стратегии обновлений приложений"


### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения ограничены и нет возможности увеличить
3. Запас по ресурсам в менее загруженный момент времени составляет 20%
4. Обновление мажорное, новые версии приложения не умеют работать со старыми
5. Какую стратегию обновления выберете и почему?

**Ответ:**

В зависимости от специфики использования приложения я бы использовал следуюшие стратегии:

 - **Canary update**: если недоступность приложения недопустима. При таком обновлении также не будут использованы дополнительные ресурсы. Указано, что у нас есть запас по ресурсам 20%. Как раз этот запас можно задействовать для поочередного обновления по 20% реплик. Но при этом необходимо разграничивать трафик от новых и старых клиентов приложения к обновленным и необновленным репликам. Постепенно при удачном обновлении все реплики обновятся, и старым клиентам будет закрыт доступ.
 - **Recreate**: если допустима недоступность приложения. При таком обновлении мы не будем использовать дополнительные ресурсы, так как у нас нет возможности их увеличиить. Старые реплики будут уничтожены и запущены обновленные вместо них. Кроме того, если клиенты приложения также должны обновиться (например, фронт для бэка) и у них не будет обратной совместимости, то при успешном обновлении приложения клиент новой версии не столкнется со старой версией приложения. Старым клиентам надо будет сразу закрывать доступ.


### Задание 2. Обновить приложение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Кол-во реплик - 5 
2. Обновить версию nginx в приложении до версии 1.20 сократив время обновления до минимума. Приложение должно быть доступно 
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным 
4. Откатиться после неудачного обновления


**Решение:**

1. Манифест для deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-multitool
  labels:
    app: nginx-multitool
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 3
  selector:
    matchLabels:
      app: nginx-multitool
  template:
    metadata:
      labels:
        app: nginx-multitool
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
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

Применяю манифест, деплоймент успешно создается:

![1.png](img%2F1.png)

2. Для обновления использую стратегию Rolling Update. Чтобы приложение оставалось доступным во время обновления, использую параметр maxUnavailable: 3. Тогда у нас пойдут на обновление 3 реплики, и 2 останутся доступными. При этом для сокращения времени обновления использую параметр maxSurge: 2. За счет этого сразу же начнут создаваться 2 реплики. Если обновление пойдет удачно, то у нас на первом же заходе будут готовы все 5 реплик (3 + 2). Оставшиеся 2 старые реплики будут остановлены. Если обновление пойдет неудачно, то у нас останется 2 старых работающих реплики.

Меняю версию nginx в манифесте:

```
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
```

Применяю манифест:

пошло обновление, остановилось 3 старых реплики и создается 5 новых:
![2.png](img%2F2.png)

приложение успешно обновилось:
![3.png](img%2F3.png)

3. Меняю версию nginx в манифесте:

```
      containers:
      - name: nginx
        image: nginx:1.28
        ports:
```

Применяю обновление. Пошли ошибки при создании подов, но остаются рабочими 2 реплики, за счет чего приложение остается доступным:

![4.png](img%2F4.png)

4. Откатываю обновление командой `kubectl rollout undo deployment nginx-multitool`.

Реплики восстанавливаются на предыдущей версии nginx 1.20:

![5.png](img%2F5.png)

![6.png](img%2F6.png)


### Задание 3*. Создать Canary deployment

1. Создать 2 deployment'а приложения nginx.
2. При помощи разных ConfigMap сделать 2 версии приложения (веб-страницы)
3. С помощью ingress создать канареечный деплоймент, чтобы можно было часть трафика перебросить на разные версии приложения


**Решение**

Итоговый манифест:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-blue
  labels:
    app: nginx-blue
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx-blue
  template:
    metadata:
      labels:
        app: nginx-blue
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: index-page-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: index-page-volume
        configMap:
          name: index-page-blue-configmap
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: index-page-blue-configmap
data:
  index.html: |
    <html>
    <head>
    <title>Version Blue</title>
    <style>
    body{
    background-color: rgb(153, 204, 255);
    }
    </style>
    </head>
    <body>
    <h1>Version Blue page</h1>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-blue-svc
spec:
  selector:
    app: nginx-blue
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: blue-ingress
  annotations:
spec:
  defaultBackend:
    service:
      name: nginx-blue-svc
      port:
        number: 80
---
# canary green version
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-green
  labels:
    app: nginx-green
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx-green
  template:
    metadata:
      labels:
        app: nginx-green
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: index-page-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: index-page-volume
        configMap:
          name: index-page-green-configmap
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: index-page-green-configmap
data:
  index.html: |
    <html>
    <head>
    <title>Version Green</title>
    <style>
    body{
    background-color: rgb(153, 255, 204);
    }
    </style>
    </head>
    <body>
    <h1>Version Green page</h1>
    </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-green-svc
spec:
  selector:
    app: nginx-green
  ports:
  - port: 8080
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: green-ingress
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "User-Agent"
    nginx.ingress.kubernetes.io/canary-by-header-pattern: "Chrome"
spec:
  defaultBackend:
    service:
      name: nginx-green-svc
      port:
        number: 80
```

Создаю 2 версии приложения. Назвал их Version Blue и Version Green. Для голубой версии ingress сделал основным, для зеленой - канареечным. 

Сделал настройку, чтобы зеленая версия отображалась бы для браузера на основе Chrome, для чего указал в аннотациях для green-ingress параметры для названия заголовка: `nginx.ingress.kubernetes.io/canary-by-header: "User-Agent"` и для паттерна, по которому ищем в самом заголовке: `nginx.ingress.kubernetes.io/canary-by-header-pattern: "Chrome"`

Применяю манифест, все объекты создаются и работают:

![7.png](img%2F7.png)

Проверяю отображение приложение в браузерах:

Firefox - отображается базовая, синяя версия:
![8.png](img%2F8.png)

Chrome - отображается канареечная, зеленая версия:
![9.png](img%2F9.png)
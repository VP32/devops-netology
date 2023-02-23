# Домашнее задание к занятию "Helm"


------

### Задание 1. Подготовить helm чарт для приложения

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом/
3. В переменных чарта измените образ приложения для изменения версии.

**Решение**

Сделал пробное приложение, состоящее из двух Deployment-ов: для nginx и для Multitool. Для каждого из деплойментов добавил свой Service.

Все манифесты лежат в папке [myapp](./src/myapp)

Темплейты для деплойментов:

 - [deployment-multitool.yaml](src%2Fmyapp%2Ftemplates%2Fdeployment-multitool.yaml)

 - [deployment-nginx.yaml](src%2Fmyapp%2Ftemplates%2Fdeployment-nginx.yaml)


Темплейт для сервисов:

 - [services.yaml](src%2Fmyapp%2Ftemplates%2Fservices.yaml)

Вынес tag для образа приложения в переменные в файле [values.yaml](src%2Fmyapp%2Fvalues.yaml)

Переопределенные версии прописал в файле [other-ver-values.yaml](src%2Fmyapp%2Fother-ver-values.yaml).

Проверяю генерацию итогового манифеста. Для настроек по умолчанию:


```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/2.5/src$ helm template myapp
---
# Source: myapp/templates/services.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-nginx-svc
  namespace: default
spec:
  selector:
    app: myapp-nginx
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/services.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-multitool-svc
  namespace: default
spec:
  selector:
    app: myapp-multitool
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/deployment-multitool.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-multitool-deployment
  namespace: default
  labels:
    app: myapp-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-multitool
  template:
    metadata:
      labels:
        app: myapp-multitool
    spec:
      containers:
      - name: release-name-multitool
        image: "wbitt/network-multitool:latest"
        ports:
        - containerPort: 80
---
# Source: myapp/templates/deployment-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-nginx-deployment
  namespace: default
  labels:
    app: myapp-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-nginx
  template:
    metadata:
      labels:
        app: myapp-nginx
    spec:
      containers:
      - name: release-name-nginx
        image: "nginx:latest"
        ports:
        - containerPort: 80
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/2.5/src$ 
```

![1.png](img%2F1.png)


Для переопределенных версий образов компонентов приложения (для файла [other-ver-values.yaml](src%2Fmyapp%2Fother-ver-values.yaml)):

```
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/2.5/src$ helm template -f myapp/other-ver-values.yaml myapp
---
# Source: myapp/templates/services.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-nginx-svc
  namespace: default
spec:
  selector:
    app: myapp-nginx
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/services.yaml
apiVersion: v1
kind: Service
metadata:
  name: release-name-multitool-svc
  namespace: default
spec:
  selector:
    app: myapp-multitool
  ports:
  - port: 80
    targetPort: 80
---
# Source: myapp/templates/deployment-multitool.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-multitool-deployment
  namespace: default
  labels:
    app: myapp-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-multitool
  template:
    metadata:
      labels:
        app: myapp-multitool
    spec:
      containers:
      - name: release-name-multitool
        image: "wbitt/network-multitool:alpine-minimal"
        ports:
        - containerPort: 80
---
# Source: myapp/templates/deployment-nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: release-name-nginx-deployment
  namespace: default
  labels:
    app: myapp-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp-nginx
  template:
    metadata:
      labels:
        app: myapp-nginx
    spec:
      containers:
      - name: release-name-nginx
        image: "nginx:1.22.1"
        ports:
        - containerPort: 80
vladimir@vp32hard:~/learndevops/devops-netology/kuber-homeworks/2.5/src$ 

```
![2.png](img%2F2.png)

------
### Задание 2. Запустить 2 версии в разных неймспейсах

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе;третью версию в namespace=app2.
3. Продемонстрируйте результат/

**Решение**

Создаю неймспейсы app1, app2:

![3.png](img%2F3.png)

Запускаю базовую версию в неймспейсе app1:

![4.png](img%2F4.png)

Запускаю версию с измененными тегами образов по файлу other-ver-values.yaml в неймспейсе app1:

![5.png](img%2F5.png)

Запускаю версию c переопределенными тегами образов из командной строки в неймспейсе app2:

![6.png](img%2F6.png)

Проверяю релизы и объекты в неймспейсе app1:

Образы для myapp - со стандартными версиями из values.yaml (тег latest).

Образы для myapp2 - c измененными версиями из other-ver-values.yaml (теги 1.22.1 для nginx и alpine-minimal для multitool).

![7.png](img%2F7.png)

Проверяю релизы и объекты в неймспейсе app2:

Образы для myapp здесь с измененными версиями из командной строки: теги 1.22.3 для nginx и alpine-extra для multitool:

![8.png](img%2F8.png)

# Домашнее задание к занятию "Базовые объекты K8S"


------

### Задание 1. Создать Pod с именем "hello-world"

1. Создать манифест (yaml-конфигурацию) Pod
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере)

------

**Решение**

Манифест для пода:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: echoserver
spec:
  containers:
  - name: echoserver
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
```

Применяю конфигурацию из манифеста, запрашиваю `kubectl get pods` и port-forward:

![1.png](img%2F1.png)

Значение через curl:
![1-1.png](img%2F1-1.png)

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем "netology-web"
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2
3. Создать Service с именем "netology-svc" и подключить к "netology-web"
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере)

------

**Решение:**

Манифест для пода и сервиса:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app: echo
spec:
  containers:
  - name: echoserver
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
    - containerPort: 8080
      name: web-port
---
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  selector:
    app: echo
  ports:
  - name: netology-svc-port
    port: 80
    targetPort: web-port
```

Применяю конфигурацию из манифеста, запрашиваю `kubectl get pods,svc` и port-forward:

![2.png](img%2F2.png)

Значение через curl:

![2-1.png](img%2F2-1.png)

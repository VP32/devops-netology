# Домашнее задание к занятию "Хранение в K8s. Часть 1"


### Задание 1. Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые 5 секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment'а в решении, а также скриншоты или вывод команды п.4

**Решение**

Итоговый манифест:

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
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'while true; do echo Hello world! >> /output/output.txt; sleep 5; done']
        volumeMounts:
        - name: task1-volume
          mountPath: /output
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "11443"
        volumeMounts:
        - name: task1-volume
          mountPath: /input
      volumes:
      - name: task1-volume
        emptyDir: {}
```

Применяю манифест, Deployment и под успешно запускаются:

![1.png](img%2F1.png)

Проверяю, что в файл идет запись со стороны busybox:

![1-2.png](img%2F1-2.png)

Проверяю, что файл читается со стороны multitool:

![1-3.png](img%2F1-3.png)

------

### Задание 2. Создать DaemonSet приложения, которое может прочитать логи ноды

1. Создать DaemonSet приложения состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера microK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды п.2

**Решение**

Итоговый манифест:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: task2-ds
  labels:
    app: task2
spec:
  selector:
    matchLabels:
      app: task2
  template:
    metadata:
      labels:
        app: task2
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
        - name: varsyslog
          mountPath: /output/logs
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "11443"
      volumes:
      - name: varsyslog
        hostPath:
          path: /var/log/syslog
```

Применяю манифест, Daemonset и под успешно запускаются:

![2-1.png](img%2F2-1.png)

Проверяю чтение /var/log/syslog ноды кластера изнутри пода:

![2-2.png](img%2F2-2.png)

------



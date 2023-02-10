# Домашнее задание к занятию "Хранение в K8s. Часть 2"


### Задание 1. Создать Deployment приложения, использующего локальный PV, созданный вручную

1. Создать Deployment приложения состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые 5 секунд в общей директории. 
4. Продемонстрировать, что файл сохранился на локальном диске ноды, а также что произойдет с файлом после удаления пода и deployment'а. Почему?
5. Предоставить манифесты, а также скриншоты и/или вывод необходимых команд.

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
        command: ['sh', '-c', 'while true; do echo Hello world $(date)! >> /output/output.txt; sleep 5; done']
        volumeMounts:
        - name: task1-volume
          mountPath: /output
      - name: multitool
        image: wbitt/network-multitool
        ports:
        volumeMounts:
        - name: task1-volume
          mountPath: /input
      volumes:
      - name: task1-volume
        persistentVolumeClaim:
          claimName: pvc-vol
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  capacity:
    storage: 512Mi
  accessModes:
  - ReadWriteOnce
  storageClassName: host-path
  hostPath:
    path: /data/pv1
  persistentVolumeReclaimPolicy: Delete
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-vol
spec:
  volumeMode: Filesystem
  storageClassName: host-path
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 512Mi

```

Обратил внимание, что если в PVC не указать явно storageClassName, то PV создается автоматически с помощью дефолтного StorageClass в microk8s, при этом создаваемый мной pv1 игнорируется и используется автоматически созданный вольюм.

Применяю манифест. Все успешно создается и запускается:

![1-1.png](img%2F1-1.png)

Проверяю, что multitool может читать файл:

![1-2.png](img%2F1-2.png)

Также файл виден по пути на ноде:

![1-3.png](img%2F1-3.png)

Удаляю под, он пересоздается деплойментом, файл на месте:

![1-4.png](img%2F1-4.png)

Удаляю деплоймент, файл остался на месте, так как у нас остался не удаленным PV:

![1-5.png](img%2F1-5.png)

Удаляю PVС и PV. Файл остался на месте.
Хотя в манифесте и написана для PV политика persistentVolumeReclaimPolicy: Delete, но она срабатывает в облачных storage. У нас storage локальный. Поэтому файл не удаляется:

![1-6.png](img%2F1-6.png)

------

### Задание 2. Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV

1. Включить и настроить NFS-сервер на microK8S.
2. Создать Deployment приложения состоящего из multitool и подключить к нему PV, созданный автоматически на сервере NFS
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты и/или вывод необходимых команд.

**Решение**

Итоговый манифест:

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: 192.168.1.68
  share: /srv/nfs
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - hard
  - nfsvers=4.1
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: nfs-csi
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 512Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task2-deployment
  labels:
    app: task2
spec:
  replicas: 1
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
        ports:
        volumeMounts:
        - name: task2-volume
          mountPath: /input
      volumes:
      - name: task2-volume
        persistentVolumeClaim:
          claimName: my-pvc
```

_Примечания по манифесту и настройкам NFS_

Так как microk8s у меня установлен локально, устанавливал NFS так же локально и использовал адрес ноды в качестве адреса NFS в блоке со Storage Class:

```
parameters:
  server: 192.168.1.68
```

Дополнительно при настройке NFS-сервера использовал команду с адресами моей домашней сети, то есть: 

`echo '/srv/nfs 192.168.1.0/24(rw,sync,no_subtree_check)' | sudo tee /etc/exports`

вместо: 

`echo '/srv/nfs 10.0.0.0/24(rw,sync,no_subtree_check)' | sudo tee /etc/exports`

При конфигурировании Storage Class в microk8s эта команда отработала только с включенным vpn, так как адрес https://charts.gitlab.io/ заблокирован Роскомнадзором:

```
microk8s helm3 install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet
```

**Применил манифест:**

Все создалось и успешно стартовало:

![2-1.png](img%2F2-1.png)

Изнутри пода успешно получается читать и писать в примониторованный том:

![2-2.png](img%2F2-2.png)

Также файл виден в файловой системе ноды (локальной машины):

![2-3.png](img%2F2-3.png)


------



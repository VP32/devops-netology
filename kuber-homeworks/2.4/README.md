# Домашнее задание к занятию "Управление доступом"

### Задание 1. Создать конфигурацию для подключения пользователя

1. Создать и подписать SSL-сертификат для подключения к кластеру.
2. Настроить конфигурационный файл kubectl для подключения
3. Создать Роли и все необходимые настройки для пользователя
4. Предусмотреть права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`)
5. Предоставить манифесты, а также скриншоты и/или вывод необходимых команд.

**Решение**

1. Создаем пользователя podwatcher и сертификат для него, подписываем его CA-серфтикатом от microk8s:

![1.png](img%2F1.png)

2. Дополняем текущий конфиг для kubectl:

Создаем пользователя:

![2.png](img%2F2.png)

Создаем контекст:

![3.png](img%2F3.png)

Подстраиваем права на файлы и переключаемся на созданный контекст:

![4.png](img%2F4.png)

Получившийся конфиг kubectl:

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUREekNDQWZlZ0F3SUJBZ0lVR1d6QTBRWFo2MnpBMy84UmZOb2RJMlhMdmI0d0RRWUpLb1pJaHZjTkFRRUwKQlFBd0Z6RVZNQk1HQTFVRUF3d01NVEF1TVRVeUxqRTRNeTR4TUI0WERUSXpNREl5TURBNU5EUXdNMW9YRFRNegpNREl4TnpBNU5EUXdNMW93RnpFVk1CTUdBMVVFQXd3TU1UQXVNVFV5TGpFNE15NHhNSUlCSWpBTkJna3Foa2lHCjl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF6YmtMMzZkZ3NlTExnektiSlBoa08vT2VwOEc2RzJhdDZ2QXYKOSticUlHSlVFMHlSYTE5MGVhWUVtTGtnNUFaRzBsOS9jaFJ0ZlB6NmhFcFhXcWlVVStGOEtVbkJJUEcxL01FMgpvbUxmMzIxNityY3B3TTFweVQ3bWF1OE4rZ00wOU9jYTcxOHVKeThkSkl3MEYydVNQZTNSTXYvOWZaQml4UjBnCjRaNjJiSVhOTDc1akJYaFh1NUl4QjdxejZxNzB0TUZFZ1BCTWY0c1pTREtvcXBUc3M5VnlGSXNnTkkyYktrVTUKYnBndXlxYTBaS1BJNEt4L2NYTlJicDRpaGxneU5wME52RGphNVZPdHNSWEEwQ2NVZmZhTzQzbmdnNkxMMEtlawpFUm1KL0paNGxUNUhIdWQ0Y2dIMFdrR215QkZXS3FyVDBDMEUxbUZRcEo3QnJKeUZBUUlEQVFBQm8xTXdVVEFkCkJnTlZIUTRFRmdRVTVTWnNWdFBSU1BZU2Vyd3BsQm43Q2g1dXhJZ3dId1lEVlIwakJCZ3dGb0FVNVNac1Z0UFIKU1BZU2Vyd3BsQm43Q2g1dXhJZ3dEd1lEVlIwVEFRSC9CQVV3QXdFQi96QU5CZ2txaGtpRzl3MEJBUXNGQUFPQwpBUUVBQ2FMUEk2bVFqRTRIZkJpSWFrRlBlR29wUzVoTzRGbFl0RUdaT2Z2SjdEMy8zL25iMXdmc1dyeHREc2hiCmhHZFk1RHJGRmZrVWordG5xRG5Za2JkZ3N6Qi9ZQkdKYWpwUVFaaUtQeWxWNDlyUEV5bDIrc3IyWGJDbEdrMTIKMmEvTHVmUm8yUGxEbG5hMFJBWnhxMHpPRlg0UnI5SHZHSEx5allSM2tSUkw1TWlaVXFTTzdFWlBOaTMwQ1M3egovS3UwVitFQlhkRTZUbEF1WlQ0akkrTkhEWlJZTzNaVXlCR29KOU1KcGRteEhJcWNkZWt1QzVwaFoxaUtldmhWCkhuUytmZ1BBY1FseEkvRkVYWHpKMUE5QlNyZExIVno4Z1pqOVhQT3pnaVZ0WHZDL09BdmwyWnNTdUNGdG5QaUMKY0d6Q0VGMVlMUTg5a0Q3YTNoTnRKMmFNVHc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://192.168.1.68:16443
  name: microk8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
- context:
    cluster: microk8s-cluster
    user: podwatcher
  name: podwatcher-context
current-context: podwatcher-context
kind: Config
preferences: {}
users:
- name: admin
  user:
    token: SzFHeDVSS3h5T2hsVWQ3ZnlCK1FOMGMweXhGMStWbGZQcTdHdVUvVlNETT0K
- name: podwatcher
  user:
    client-certificate: /home/podwatcher/podwatcher.crt
    client-key: /home/podwatcher/podwatcher.key

```

Пробуем получить какие-либо данные под созданным пользователем, доступа нет, так как не настраивал права:

![5.png](img%2F5.png)

3,4, 5. Создал роль, RoleBinding и пробный под, на котором можно проверить работу роли. Манифест:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-readlog-role
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-readlog-rb
subjects:
- kind: User
  name: podwatcher
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-readlog-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Pod
metadata:
  name: testpod
spec:
  containers:
  - name: multitool
    image: wbitt/network-multitool
```

Для применения манифеста переключаюсь обратно на контекст админа microk8s. Применяю манифест, все успешно создается и стартует:

![6.png](img%2F6.png)

Меняю контекст на podwatcher-context. 
Команды `kubectl logs testpod`, `kubectl describe pod testpod` успешно отрабатывают:

![7.png](img%2F7.png)

При этом получение списка подов и другие команды, например `kubectl get all` или `kubectl get nodes` не работают, так как на них не предоставлены права:

![8.png](img%2F8-1.png)
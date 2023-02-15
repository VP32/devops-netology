# Домашнее задание к занятию "Конфигурация приложений"



### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить web-страницу

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Решить возникшую проблему с помощью ConfigMap
3. Продемонстрировать, что pod стартовал, и оба конейнера работают.
4. Сделать простую web-страницу и подключить ее к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
5. Предоставить манифесты, а также скриншоты и/или вывод необходимых команд.

**Решение**

1-3.

Манифест для Deployment с изменением портов для multitool через env и ConfigMap:

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
          valueFrom:
            configMapKeyRef:
              name: task1-configmap
              key: http-port
        - name: HTTPS_PORT
          valueFrom:
            configMapKeyRef:
              name: task1-configmap
              key: https-port
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: task1-configmap
data:
  http-port: "8080"
  https-port: "11443"
```

Применяю манифест, под с обоими контейнерам удачно стартует и работает:

![1-1.png](img%2F1-1.png)

4-5.

Добавил отдельный ConfigMap для проброса веб-страницы в контейнер Nginx. Не стал добавлять параметр с кодом страницы в существующий ConfigMap, чтобы при монтировании вольюма не создавались ненужные файлы с параметрами портов. Добавил сервис:

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
        volumeMounts:
        - name: index-page-volume
          mountPath: /usr/share/nginx/html
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
        env:
        - name: HTTP_PORT
          valueFrom:
            configMapKeyRef:
              name: task1-configmap
              key: http-port
        - name: HTTPS_PORT
          valueFrom:
            configMapKeyRef:
              name: task1-configmap
              key: https-port
      volumes:
      - name: index-page-volume
        configMap:
          name: index-page-configmap
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
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: task1-configmap
data:
  http-port: "8080"
  https-port: "11443"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: index-page-configmap
data:
  index.html: |
    <html>
    <head>
    <title>Hello Netology Page</title>
    </head>
    <body>
    <h1>Hello Netology Page</h1>
    <p>This is <b>Task 1</b></p>
    </body>
    </html>
```

Применяю манифест. Все удачно создается и стартует:

![1-2.png](img%2F1-2.png)

Делаю проброс порта для просмотра сайта на Nginx:

![1-3.png](img%2F1-3.png)

Проверяю через curl в другой консоли:

![1-4.png](img%2F1-4.png)

Проверяю отображение в браузере:

![1-5.png](img%2F1-5.png)

------

### Задание 2. Создать приложение с вашей web-страницей, доступной по HTTPS 

1. Создать Deployment приложения состоящего из nginx.
2. Создать собственную web-страницу и подключить ее как ConfigMap к приложению.
3. Выпустить самоподписной сертификат SSL. Создать Secret для использования данного сертификата.
4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
4. Предоставить манифесты, а также скриншоты и/или вывод необходимых команд.

**Решение**

Для генерации самоподписанного сертификата использовал домен test-app.dev.
Чтобы он ресолвился на мой кластер, добавил его в файл /etc/hosts:


![2.png](img%2F2.png)

Сертификат генерировал командой:

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -sha256 -keyout nginx-selfsigned.key -out nginx-selfsigned.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=Test company/OU=Org/CN=test-app.dev"
```

Далее кодировал в base64 полученные файлы командами:

```
cat nginx-selfsigned.crt | base64
sudo cat nginx-selfsigned.key | base64
```

Что получилось после base64, добавлял в манифест Secret.

Для того, чтобы сертификат считался доверенным, понадобилось добавить его в хранилище сертификатов и обновить хранилище следующими командами:


```
sudo cp nginx-selfsigned.crt /usr/local/share/ca-certificates/
sudo cp nginx-selfsigned.key /usr/local/share/ca-certificates/
sudo update-ca-certificates -v
```



Итоговый манифест:

```yaml
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
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
          name: http-port
        volumeMounts:
        - name: index-page-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: index-page-volume
        configMap:
          name: index-page-configmap
---
apiVersion: v1
kind: Service
metadata:
  name: task2-svc
spec:
  selector:
    app: task2
  ports:
  - name: task2-svc-http-port
    port: 80
    targetPort: http-port
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: task2-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: test-app.dev
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: task2-svc
            port:
              number: 80
  tls:
  - hosts:
    - test-app.dev
    secretName: task2-secret-tls
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: index-page-configmap
data:
  index.html: |
    <html>
    <head>
    <title>Hello Netology Page</title>
    </head>
    <body>
    <h1>Hello Netology Page</h1>
    <p>This is <b>Task 2</b></p>
    </body>
    </html>
---
apiVersion: v1
kind: Secret
metadata:
  name: task2-secret-tls
type: kubernetes.io/tls
data:
  tls.crt: |
    LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZ0ekNDQTUrZ0F3SUJBZ0lVRUFjOUlaOWRn
    RFRJcEMza3l2WTM2OHVMUllzd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2F6RUxNQWtHQTFVRUJoTUNV
    bFV4RHpBTkJnTlZCQWdNQmsxdmMyTnZkekVQTUEwR0ExVUVCd3dHVFc5egpZMjkzTVJVd0V3WURW
    UVFLREF4VVpYTjBJR052YlhCaGJua3hEREFLQmdOVkJBc01BMDl5WnpFVk1CTUdBMVVFCkF3d01k
    R1Z6ZEMxaGNIQXVaR1YyTUI0WERUSXpNREl4TlRFek5UUXpORm9YRFRJME1ESXhOVEV6TlRRek5G
    b3cKYXpFTE1Ba0dBMVVFQmhNQ1VsVXhEekFOQmdOVkJBZ01CazF2YzJOdmR6RVBNQTBHQTFVRUJ3
    d0dUVzl6WTI5MwpNUlV3RXdZRFZRUUtEQXhVWlhOMElHTnZiWEJoYm5reEREQUtCZ05WQkFzTUEw
    OXlaekVWTUJNR0ExVUVBd3dNCmRHVnpkQzFoY0hBdVpHVjJNSUlDSWpBTkJna3Foa2lHOXcwQkFR
    RUZBQU9DQWc4QU1JSUNDZ0tDQWdFQWxBdmUKSlFuVHYwcUlYYjNGK2ZVNXpBTGhDTjRaQURwdldR
    VjlYTzhvZFl1SS9GN0REalRmNDdETTlTaVBVb0hob3RaVwptNW9vL0JLV0JsSytJZGFpZ2p0KzVy
    TTBVdlZEMUU3OWNncDZSQXM5WFloMnhYSndqNUFxN3RtZEJ2RlRQaGN4CkM2dzVNRVViK1B2aUNF
    WEVXdkZaRkVjOUJSOFBPdmtIOHRwdU5HZVdESmNGRnlzOXVXY2VmOWJBSG1EeG9xb3kKemFQZ2JK
    WDZyOEJKaVlNS0c5dUtyUnJqN3JzSkQyVjFjOFFiYUJiOGdyWDFBcnREQnNGNTFFbU1ITTZpWDlP
    RgpNaUpyK3F2c25rREJSQjMxT1h4UlFVc1RzcWFna3dvTjczVXEvSWdPclo1a2hVbThOZTN1a0Nw
    aytyOXdPTk5PCkxBRnBpSGRHb2E3b0Vhb05zRlVOUk1xTXVSUk5yYjd2c3ZtUFN4NExRcU4wUThk
    R1pSZW8wcExnRzNCTDJmRDMKaC9Jc0tXSm1ZMld4UmY3Yy9nbGw5ZGVQTnNhTTkvWGY2ZFNZVWRQ
    aEZaYWFQSGRnVnFBcnhTaFRsWmFYUEdYSgpvMmR5emZHRmRONFhrR3BZcmd5MmZvR09kTTF6SGFI
    RW5FTktiUk9nNWxjeHB2VGU2YkQxOGRQL3dkcHN5a2NxCjUreEhGc2hyZkpEVUJkekJ6QzdEenc5
    UnlIcHE1ckJXRnM4KzErRmlFMDJyZXcvMGtlb1V2OUNLQk41aHp5ODgKS2ZCOXdCTkt6VGQ0Z0NE
    Q1hTQ0RPVTd0b3JTRVk4MjE4aXB1TlVUL3ZHME80ZnBnQVQrL3J3YjhlYmltSWREdgpua0NrYTZH
    c3B2MmlDSnNmV0RnQXh3eGZlMXRnUklTMmNSV2ptYk1DQXdFQUFhTlRNRkV3SFFZRFZSME9CQllF
    CkZONGl6Q3pObFhmbEZxamlWS2lmNEZNQWNYdXVNQjhHQTFVZEl3UVlNQmFBRk40aXpDek5sWGZs
    RnFqaVZLaWYKNEZNQWNYdXVNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEUVlKS29aSWh2Y05BUUVM
    QlFBRGdnSUJBRGRwcjZkaQpDTStWMXhocUJHdGVWN0pDdWE2eWVKVXM2MmNhQ25vUHRwTjJjNG1j
    ZmFPai85QVhET09sRkQrZm40dmdDZ1hwCnB1QW9pRXVCWVF6VEtBVEJlTFNSN1dBQzk3MHlRUW5O
    Rlp6cXJhZTRUWERvL2pSTllid1I2N0dKT0lMM1NlZlEKVExFN09kNGpPOURzUWlDZWplSXVGZ01I
    OVZ2ejhxQ2w5WEtlcTFnUncvdFpVSVdObGFXQ2QrdTlNdWxxdkdOUQpURTVKQjJJTFlnZVREa3dy
    bG1PZFpBNTdENm5CS1FVakZ5TmYvem5DU3ZBcjhOanpxL0tSUHdnaitXUTBVWHA5CmhaVjFqTWlz
    bHdUd2owZG9JU2VVNEtxUjdMcjR1VVdINDlXYmdPallrazRHRUh4cFY1NnhNdnZmaDZITEdEUmcK
    a3o2TnhEaHFDNDNvZFoyU29rWjBoL0hWZXJDSUxkSTh1TFhvazJzZHVPM2hYaERLRFBFNzd4cFJS
    WjhleE5ieApmR29kVUpHOFFhVjgzMXpjVHpiTTlabWh4cFlzWmRUT0tyb3diaXdMQk9yYXllU0Np
    Nk41WW9Gb3Vjbm8zZEhZCkE2NFQ4THFXT011Qit1QncyNGtIUkZpYU5aTUlFQktrZWRjenJZa3ln
    TE1Pb1pNWVNNZzdQNCs1d3Q0RnhWZFAKdkRnVC9sc1piY3FGYVh0c0UyOW03N09nQVhGbEZPWks5
    MkZBOHdYM2xuQ3hZU1J3ekpsN3Rhb3NFODRZemNwMApQWmxaWlk3U25LZ1pvbDN0RjlKbGxCeUl6
    c2p1ZVdwM1FURGsxSGxzYndqU255YTErOFdyYytNN1FDNWZIa3g1Cmt5OWY2RTROdjNvRXdmeE1Y
    Yy9vZUFjU2lBTFZiK3hNWXZKZAotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: |
    LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZB
    QVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ1VDOTRsQ2RPL1NvaGQKdmNYNTlUbk1BdUVJM2hrQU9tOVpC
    WDFjN3loMWk0ajhYc01PTk4vanNNejFLSTlTZ2VHaTFsYWJtaWo4RXBZRwpVcjRoMXFLQ08zN21z
    elJTOVVQVVR2MXlDbnBFQ3oxZGlIYkZjbkNQa0NydTJaMEc4Vk0rRnpFTHJEa3dSUnY0CisrSUlS
    Y1JhOFZrVVJ6MEZIdzg2K1FmeTJtNDBaNVlNbHdVWEt6MjVaeDUvMXNBZVlQR2lxakxObytCc2xm
    cXYKd0VtSmd3b2IyNHF0R3VQdXV3a1BaWFZ6eEJ0b0Z2eUN0ZlVDdTBNR3dYblVTWXdjenFKZjA0
    VXlJbXY2cSt5ZQpRTUZFSGZVNWZGRkJTeE95cHFDVENnM3ZkU3I4aUE2dG5tU0ZTYncxN2U2UUtt
    VDZ2M0E0MDA0c0FXbUlkMGFoCnJ1Z1JxZzJ3VlExRXlveTVGRTJ0dnUreStZOUxIZ3RDbzNSRHgw
    WmxGNmpTa3VBYmNFdlo4UGVIOGl3cFltWmoKWmJGRi90eitDV1gxMTQ4MnhvejM5ZC9wMUpoUjAr
    RVZscG84ZDJCV29DdkZLRk9WbHBjOFpjbWpaM0xOOFlWMAozaGVRYWxpdURMWitnWTUwelhNZG9j
    U2NRMHB0RTZEbVZ6R205Tjdwc1BYeDAvL0IybXpLUnlybjdFY1d5R3Q4CmtOUUYzTUhNTHNQUEQx
    SEllbXJtc0ZZV3p6N1g0V0lUVGF0N0QvU1I2aFMvMElvRTNtSFBMendwOEgzQUUwck4KTjNpQUlN
    SmRJSU01VHUyaXRJUmp6Ylh5S200MVJQKzhiUTdoK21BQlA3K3ZCdng1dUtZaDBPK2VRS1Jyb2F5
    bQovYUlJbXg5WU9BREhERjk3VzJCRWhMWnhGYU9ac3dJREFRQUJBb0lDQUNQK1RLaUpucHNUNWxx
    UUlIbDRkdkJVClJOendqbmlCUElBU3R4dG9vOWdNTUNaWGJhbmZEZzNmOXJ5bCswNXVlR3FzSE10
    ZzdCVDQrZE9ZdTFRanlFZk0KYWpweG1FZVJETWdwMmpHblBYbWNsL05ORWI5SVp2aG9ieCs1OVpU
    eUNEQ0ExL0pFRVhWY1lBUWxUUnVBeHMvcgpmS0pTL1pGb3J6M0J2UDU4djYxcS84Nll5dXFLbjB1
    YnVBMFJxNHpYT2ZnMzAva3VIZ3FZWGlYcnBKVlRzQm44Cnd0YjZRaTlROXM5dzllREs3WFRkbmMr
    enFGbGRLTnNVSCtnT1o0dTdhenZNQThhZ0dzdUxrQkFibzBGSjNVeDQKSHBNMnl4ZTByamFCaThq
    TG5rTmVXdDg0TXEwN001Q1RBOXkyQ2UzeXJEaU1teVZVeEpFaW1xQUZrN056dWpibApsSFR1VWxT
    SkxqOHg2UDBrOEVUNHdjd080ck9PUVN1dVJBK0ZlVzZPSnZNc0dXYWcxWThibmNqUmxraXRoMUR2
    ClFNRVFwQTljWlg4L0h5VklwM1NhWUJHcUgwZkQrZWlFOUJzcWZVdHFFM1k3K0lzVU9LbVBGSFZq
    V3p6ZnlheUgKZU9xN0lNb250eEhPRVBxb3c3Q292TWpnVTgxbU5CR0RkSkdtdC82bU9Bc2NwTEtz
    SmR4eTZHVUNkZlUyMEw5YQpNeERLZjlEUFFrY2F0Sk1pT2FET2tmcE5OYVprQlR0SkRBTFVyRm1l
    Nkc1d25udXBGNWhaY3I4TGlEaVFKQ2dICnJWQW8yTEE1VEltRmlZTkxodFptTXlyRGR0VDhkS2Jv
    dnllaWdsNUxSK3hnM01mL1JjbTN5SGIxTFI0VlhUak8Kc2RyTWNvTUxtV2lVcWRkUmVLS1pBb0lC
    QVFERUJlTW5nZHpUWWt3K3dlSmw2R004eUJna2taQllwUm1rMSt4Vwp2ZXRPUjZDMEJiT01walFZ
    SmxUVVZFaGdZMkpscWRBZExHOXFGRTBmRFdBSlU0eHR1OTJLUG9lN2NoMWk2NXNBCklIemFaYmpD
    SzMwUXVlVEFld1NmQkNkb2hObXpIVDZxYUhKSGlmanA0dW11VzhuYVV5L1NLa0k5VGV6emEvSlMK
    T09tRG4yNFZrcnh6eG55TmZLTDBFSCtQUmN0bXpZajhTclExRnJyUDNlbVRUNW1nbkI3S3FSTkh4
    Zm9ZaEdFWApMT1RBS2VDL2ZMdjdETTBQV0J3L1pxYlczV0hPRzVtby91SjZRWDdvUU9HZTc0VnYw
    NmVhK056YldnOUdpOHJMCitUc21VK3FDNTUrZkhoRzQzTnJUdUY3bWtBNTVyN210OTZNOTNtSzAr
    M2tkem5icEFvSUJBUURCV0E5L3dXM3cKWFRkS2JzRjdzcUxPOVQ2K3NNcFlGYkVJSHVZaFFTd2Ra
    YS8rcjBrVDZMaTVONWM3NE5peldwbUVoYThWcXRCcQpZU0tmZzZiaTJjOTNzaEZWRWI2UUZ1M0lx
    d2ZxelJEcnRISUg4VHJ5dkNDMjVwNDdnOWQvZWhkcERrUzdacHdkCkJlOU5WcGlJbW5UNkRyN1ZH
    RVNYYU1LMi82RVlEQVhRQ2Z1WTVoaTlSSUxiVklXZUdRdVdtTXpRWDlFSTY0RHQKNGtyU1hDU0xr
    c2RDWUJnRUxkVVF3UEMrWmtqNWlCVlROc0xPYmpjcmVrc0ZQM1ZkWmd1U1pHdXdCVGVjL0dIbQpW
    UkdMY1U3RldXV2t6VllNdGsrZVF3aUVTckV6SmQ4WnNrSzdVcXJSVjg1UDVLb1ZkV0lyRkZXVDlE
    WGdWU3FzCk1HbWZiVVVkb1dJN0FvSUJBSHloVVorWXpaSUllWG1kUkJpTy9DbDAvd1NoR0NtRUx4
    M0R1eHdiZkRRMURsUG4KSEJWY3h0cGo1S05yUXVrbHh6WGtGZEcyb3MvTFFJMXhyNUcrY1JhRHo0
    Tko1bnFqUDFQWmdKOUFDS0hDOHdsaApKUTh4WWVPUFU0elcwMGQ4ei8wMXB0WXB1aDhKOWh5ZWpQ
    eXlsMUFjZTljZnp5V3pHZWhheGFMSlZJNi9HdnJVClpNVW5lYUZya1Ira0xiWW1KZ0NpeFduREJY
    aUxqeE1DZ0xPTWRKek5KamFyOFBvOVFabTg4UTRQR1JHa2pxU3cKNWNQa2k2d3AxU3ZxVkVGZ1dB
    TDNRV2RWUnlGNzZ2ZzM2RHRwQm1ubkpEVS83UXY1NHFSejFPaUMrYnlRdGhXcwp0cXd3TGd4ZlB6
    SkZrdkQ4dm5kWDVySlpOSXp0aTh5TjVwK3cyYUVDZ2dFQUw1aEM4SHNvV2lSSVNSMXNxY3UyCndt
    V2kxWVJsdXp0VHdpRUJHNnlVZElRa3gvaFViLzg1QWZkS1ZtWXFValI2V0NJa2tKdmxCRnIzRC9k
    enJLSmIKclNaN2w4cHZjNzhCT0FYS1JDWEpCWXo5Q1RGOEJtY0RVcU1BenJ2TTM4ZXBYYVl5aTBO
    ZUtOTGVMdGFqWS9WSgoySWlxdDRCcTJpN2l4L096cjF5K1RaRTNpMU1SUWY1TWpEdUpUUHJ6WEZZ
    dkRSaVpONjNwcGlXdnI0c1pQL2FZCjhLRUJLSDR6MWhUNDdwWDFYdC8rQitjU0c0a01NYnJBSHdH
    WkhhM1NLVzVwQ0FLd3h3ZGwvakp3eURmVFlVZDUKZXhGRkhvbituWUg0NWNBUlVQc0FxYTIxT2JI
    RzlSTzlhUE5zWHkzdlJaV1MzNElkaFNUU0JXTkJqUXAwR2pBeApJd0tDQVFFQXdDSkI2VHFTeDYv
    WjFDcWovb0VRNnJyaFRsZjgrM2xpc21DQm5tQXcwcnNSQU92cnh6eXBEYUpXCkV5VE9iY3dDcnlu
    STR6MWdUNGJSVDZLTnZxb1NKWjNocFVaRDRLcWg0Z1JNVWZ6anBYU1RnQzZUUjdscExhNTMKOVkv
    YXFaVjRKYkk5TnRkM3BpOEVSZks4cDBHYjhBK3VUY2thQzJOeWsvYUd6OXdoc0ozN2FvM1FCQTVu
    WTFvSQpDMjA1Uy9mYVpLUVl0RVJodkVmM0Vic1FlRGFESUlaVnBSakpqOTMxdzcza3I2SzNZWUFZ
    WlNlR2NlQnR6a2E5CkRjRWNrdktNOXJNVU5jUVAwbS8rUVVpOTlxakdDUEVPSFMyRkZZUDhRc1Bo
    QUF0QXJudHJlbFFsQWx6dTJ6OFMKZ0c2K2N5N3FlQW9VaUkranFGYldGZ0RWMk0zTmpnPT0KLS0t
    LS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
```

Применяю манифест, все сущности успешно создаются и запускаются:

![2-1.png](img%2F2-1.png)

Проверяю доступность через curl по HTTPS, доступно:

![2-2.png](img%2F2-2.png)


------



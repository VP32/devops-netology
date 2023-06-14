# Дипломный практикум в Yandex.Cloud

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---

# Решение


Все репозитории завел на Gitlab.com.

В качестве тестового приложения использовал свой прошлый pet-проект на Laravel 8 - блог с фотогалереями. Через админку блога происходит загрузка фотографий в галереи, далее из галереи можно сгенерировать пост с выбранными фотографиями и написать в нем текст в визуальном редакторе.

Тестовое приложение работает на php 8.1, испольузет БД MySQL для хранения данных галерей и постов. Сами фотографии сохраняются и отображаются из S3-хранилища в Яндекс Облаке. Все эти сервисы также создаются у меня с помощью Terraform.

Сделал 2 workspace Terraform: stage и prod.
За счет этого далее во всей работе использую 2 независимых контура проекта: stage и prod. В контуре prod - более мощные машины.

Для backend Terraform использую Terraform Cloud (приходится включать VPN).

Кластер Kubernetes создавал с помощью Kubespray на созданных из Терраформа ВМ. Кластеров также создается два: stage и prod-кластеры.

Для дальнейшего деплоя в кластеры с помощью CI/CD использую ClusterRole с ограниченными правами.

Мониторинг кластера развернул с помощью [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).

Приложение разворачиваю в кластере с помощью helm chart.

Для CI/CD использую Gitlab CI.

Более подробные сведения можно узнать из соответствующих репозиториев. 

## Привожу все ссылки по пунктам задания:

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.

Репозиторий: 
https://gitlab.com/vp32-devops-diploma/terraform-infrastructure


2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.

Использую Terraform Cloud.

Merge Request, пример: https://gitlab.com/vp32-devops-diploma/terraform-infrastructure/-/merge_requests/17

Скриншоты из Terraform Cloud:

![1.png](img%2F1.png)

![2.png](img%2F2.png)

![3.png](img%2F3.png)

3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.

Репозиторий с конфигурацией для Kubespray: https://gitlab.com/vp32-devops-diploma/k8s-clusters-config

4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.

- Репозиторий тестового приложения: https://gitlab.com/vp32-devops-diploma/webapp

- Dockerfile для приложения на базе php-fpm:  https://gitlab.com/vp32-devops-diploma/webapp/-/blob/main/Dockerfile

- Dockerfile для nginx для проксирования запросов в php-fpm: https://gitlab.com/vp32-devops-diploma/webapp/-/blob/main/Dockerfile-nginx

- Файл конфигурации CI/CD для Gitlab CI: https://gitlab.com/vp32-devops-diploma/webapp/-/blob/main/.gitlab-ci.yml

Ссылки на docker images. Возможно будут недоступны, так как образы находятся в registry в Яндекс Облаке, и мне будет необходимо открыть Вам туда доступ:

Stage registry:

- [webapp php-fpm](https://console.cloud.yandex.ru/folders/b1gbs15fbe0jet0kppoa/container-registry/registries/crp022ddolurhttl1td3/overview/vp-diploma-webapp/image/crpeveiqj0ae6dmqhboh/overview)
- [webapp nginx ](https://console.cloud.yandex.ru/folders/b1gbs15fbe0jet0kppoa/container-registry/registries/crp022ddolurhttl1td3/overview/vp-diploma-nginx/image/crpmgiirie5q5tf48on5/overview)

Prod registry:

- [webapp php-fpm](https://console.cloud.yandex.ru/folders/b1gbs15fbe0jet0kppoa/container-registry/registries/crp21d6nmjj9go1scrqg/overview/vp-diploma-webapp/image/crp3mm4cv97r1rrtajio/overview)
- [webapp nginx](https://console.cloud.yandex.ru/folders/b1gbs15fbe0jet0kppoa/container-registry/registries/crp21d6nmjj9go1scrqg/overview/vp-diploma-nginx/image/crpekcihghthgnnj8boq/overview)


5. Репозиторий с конфигурацией Kubernetes кластера.

Конфигурацию кластера реализовал с помощью Helm.
Репозиторий: https://gitlab.com/vp32-devops-diploma/helm-chart-webapp

Более подробно описал в самом репозитории.

Здесь содержатся чарты:

- [vp-diploma-webapp-chart](https://gitlab.com/vp32-devops-diploma/helm-chart-webapp/-/tree/main/vp-diploma-webapp-chart) - чарт тестового приложения

- [vp-diploma-rbac-chart](https://gitlab.com/vp32-devops-diploma/helm-chart-webapp/-/tree/main/vp-diploma-rbac-chart) - чарт для кластерной роли, от имени которой предполагается использование чарта приложения в CI/CD

- [kube-prometheus-stack-config/values.yaml](https://gitlab.com/vp32-devops-diploma/helm-chart-webapp/-/blob/main/kube-prometheus-stack-config/values.yaml) - файл values.yaml для чарта [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), с помощью которого реализован мониторинг кластера K8S в приложении.

6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.

Доступ в приложение реализован через ingress и сетевой балансировщик. 
Доступы в PhpMyAdmin (задеплоил для возможного служебного доступа к БД) и мониторинг - через service типа NodePort и сетевые балансировщики.

**Stage окружение:**

**Приложение**: http://158.160.99.235

**PhpMyAdmin**: http://158.160.98.24

логин: superuser

пароль: fZmuGon9U4b7gp24


**Grafana**: http://158.160.108.231:8080

логин: admin

пароль: vp-diploma-prom

**Prod окружение:**


**Приложение**: http://158.160.110.56

**PhpMyAdmin**: http://62.84.119.56

логин: superuser

пароль: JJHVDarGYZ1ZBU9y


**Grafana**:  http://158.160.96.39:8080/

логин: admin

пароль: vp-diploma-prom

CI/CD происходит внутри Gitlab.com, примеры выполненных пайплайнов доступны в репозитории тестового приложения:

https://gitlab.com/vp32-devops-diploma/webapp/-/pipelines

Пример пайплайна при коммите:

https://gitlab.com/vp32-devops-diploma/webapp/-/pipelines/899458165

Пример пайплайна при создании тега:

https://gitlab.com/vp32-devops-diploma/webapp/-/pipelines/899492367

7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

Все репозитории хранятся на Gitlab.com.
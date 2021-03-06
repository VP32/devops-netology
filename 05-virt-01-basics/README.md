## Задача 1

Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.

**Ответ:**

Аппаратная виртуализация подразумевает, что не требуется установки ОС на физический сервер, так как гипервизор является сам операционной системой. Тогда как в случае паравиртуализации гипервизор устаналивается как служба внутри ОС на сервере, при этом он модифицирует ядро гостевой ОС для разделения доступа к ресурсам физического сервера. В случае с аппаратной и паравиртуализацией виртуальные машины используют собственные ядра ОС. В то время как в случае виртуализации на основе ОС виртуальные машины могут использовать только одно ядро ОС, которое используется на хост-машине. Также в случае с виртуализацией на основе ОС контейнеры работают как отдельные процессы на основной ОС.


## Задача 2

Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования.

Организация серверов:
- физические сервера,
- паравиртуализация,
- виртуализация уровня ОС.

Условия использования:
- Высоконагруженная база данных, чувствительная к отказу.
- Различные web-приложения.
- Windows системы для использования бухгалтерским отделом.
- Системы, выполняющие высокопроизводительные расчеты на GPU.

Опишите, почему вы выбрали к каждому целевому использованию такую организацию.

**Ответ:**

Для условий использования:
- Высоконагруженная база данных, чувствительная к отказу. - из-за высокой нагрузки использовал бы физические сервера. При этом для обеспечения отказоустойчивости рассмотрел бы кластеризацию средствами самого сервера БД на физических серверах. Здесь не указан вариант полной аппаратной виртуализации, он бы тоже подошел для кластеризации.
- Различные web-приложения - использовал бы виртуализацию уровня ОС. В частности, для этого массово используется Докер с запуском в контейнерах веб-приложений. При использовании оркестрации контейнеров можно настроить их автоматический перезапуск и создание.
- Windows системы для использования бухгалтерским отделом - паравиртуализация на базе Hyper-V. Так как Hyper-V является нативным продуктом для Windows-серверов, его использование облегчает задачи поддержки и администрирования на Windows-стеке.
- Системы, выполняющие высокопроизводительные расчеты на GPU. - использовал бы физические сервера, чтобы максимально использовать производительность GPU без накладных расходов на виртуализацию.

## Задача 3

Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

Сценарии:

1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.
2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.
3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры.
4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.

**Ответ:**

1. Тут бы использовал Microsoft Hyper-V, так как преимущественно windows-инфраструктура. Меньше затрат на обучение персонала по этой же причине. Компоненты Hyper-V позволяют решить требуемые задачи.
2. Для наилучшей производительности использовал бы KVM. Он позволяет запускать гостевые машины на многих ОС, при этом при использовании драйвера virtio производительность близка к хост-машине.
3. Можно использовать в бесплатной версии Hyper-V за счет совместимости с windows-инфраструктурой.
4. Использовал бы Docker с его возможностями запуска программного продукта на основе базовых образов с разными дистрибутивами Linux. Это требует меньше накладных расходов, и может быть запущено как в среде автоматического тестирования, так и на компьютере тестировщика.

## Задача 4

Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

**Ответ:**

У меня нет практического опыта в настойке сред виртуализации, так что личных примеров дать не могу. Тем не менее, я старался бы избежать создания гетерогенной среды. Либо минимизировал бы ее гетерогенность. Зоопарк систем привел бы к кадровым проблемам: необходимо будет найти или обучить людей, кто может администрировать каждую систему управления виртуализацией, одну или все. Также возникли бы проблемы с самим администрированием: для одних и тех же задач приходилось бы использовать разные инструменты в разных системах. Если предусматриваются какие-либо автоматизации, то их тоже пришлось бы делать под каждую систему отдельно. Все это в свою очередь ведет к увеличению финансовых затрат.
Если необходимы виртуальные машины с разными ОС, то, чтобы избежать гетерогенности, можно использовать одну систему виртуализации, позволяющую использовать такие машины, например KVM. 
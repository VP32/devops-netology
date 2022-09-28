# Домашнее задание к занятию "08.04 Создание собственных modules"

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл
2. Наполнить его содержимым:
```python
#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        name=dict(type='str', required=True),
        new=dict(type='bool', required=False, default=False)
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['original_message'] = module.params['name']
    result['message'] = 'goodbye'

    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    if module.params['new']:
        result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```
Или возьмите данное наполнение из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).

3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.
4. Проверьте module на исполняемость локально.
5. Напишите single task playbook и используйте module в нём.
6. Проверьте через playbook на идемпотентность.
7. Выйдите из виртуального окружения.
8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.yandex_cloud_elk`
9. В данную collection перенесите свой module в соответствующую директорию.
10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module
11. Создайте playbook для использования этой role.
12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.
13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`
16. Запустите playbook, убедитесь, что он работает.
17. В ответ необходимо прислать ссылку на репозиторий с collection

## Решение 

### На окружении ansible:

Подготовил модуль:

```python
#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module

short_description: Создает файл по указанному пути с указанным наполнением.

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: Создает файл по указанному пути с указанным наполнением. Если файл уже существует, ничего не делает.

options:
    path:
        description: Путь для создания файла.
        required: true
        type: str
    content:
        description:
            - Содержимое файла. Если не указано, создается пустой файл.
        required: false
        type: str
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - vp_netology.learn_ansible.my_own_module

author:
    - Vladimir Polikarpov (@VP32)
'''

EXAMPLES = r'''
# Создание пустого файла.
- name: Create empty file 
  vp_netology.learn_ansible.my_own_module:
    path: ~/test/my.test

# Создание файла с содержимым.
- name: Create file with content My new content
  vp_netology.learn_ansible.my_own_module:
    path: ~/test/my.test
    content: My new content

'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
message:
    description: Сообщение, поясняющее, что файл создался.
    type: str
    returned: always
    sample: 'File ~/test/my.test was created'
message:
    description: Сообщение, поясняющее, что файл уже существует.
    type: str
    returned: always
    sample: 'File ~/test/my.test already exists'
'''

from ansible.module_utils.basic import AnsibleModule
from pathlib import Path
from os import path


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=False, default='')
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # module logic
    my_file = Path(module.params['path'])
    if my_file.exists():
        result['changed'] = False
        result['message'] = f'File {module.params["path"]} already exists'
        module.exit_json(**result)

    my_dir = Path(path.dirname(module.params['path']))
    if not my_dir.exists():
        my_dir.mkdir(parents=True)

    with open(module.params['path'], 'w', encoding='utf-8') as f:
        f.write(module.params['content'])
        result['changed'] = True
        result['message'] = f'File {module.params["path"]} was created'

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```

Подготовил плейбук для его запуска:

```yaml
---
  - name: Test file creation
    hosts: localhost
    tasks:
      - name: Run my_own_module
        my_own_module:
          path: ~/test2/file2.test
          content: My new content from playbook
```

Результат запуска на venv:

```
(venv) vladimir@VP32Hard:~/learndevops/ansible$ ansible-playbook site.yml 
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development. This is a rapidly changing source
of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Test file creation] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Run my_own_module] ******************************************************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

(venv) vladimir@VP32Hard:~/learndevops/ansible$ ansible-playbook site.yml 
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development. This is a rapidly changing source
of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Test file creation] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Run my_own_module] ******************************************************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

(venv) vladimir@VP32Hard:~/learndevops/ansible$ 
```

При повторном запуске результат показывает идемпотентность:

```
(venv) vladimir@VP32Hard:~/learndevops/ansible$ ansible-playbook site.yml 
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development. This is a rapidly changing source
of code and can become unstable at any point.
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Test file creation] *****************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************
ok: [localhost]

TASK [Run my_own_module] ******************************************************************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ********************************************************************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

(venv) vladimir@VP32Hard:~/learndevops/ansible$ 
```

### При работе с коллекцией:

Ссылка на репозиторий с коллекцией: https://github.com/VP32/my_own_collection

Сначала я проставил тег 1.0.0, но затем при установке и проверке этой коллекции выяснил, что нужны исправления. Поэтому фактически работающая коллекция идет с тегом 1.0.1

Создание tar.gz, п.13:

```
vladimir@VP32Hard:~/learndevops/custom-collection/vp_netology/learn_ansible$ ansible-galaxy collection build 
Created collection for vp_netology.learn_ansible at /home/vladimir/learndevops/custom-collection/vp_netology/learn_ansible/vp_netology-learn_ansible-1.0.0.tar.gz
vladimir@VP32Hard:~/learndevops/custom-collection/vp_netology/learn_ansible$ 
```

Проверка работы с плагином из коллекции через роль, п. 14, 15, 16:

Плейбук для использования роли из коллекции:

```yaml
---
  - name: test my module
    hosts: localhost
    collections:
      - vp_netology.learn_ansible
    roles:
      - my-test-role
```

Устанавливаем коллекцию и запускаем плейбук:

```
vladimir@VP32Hard:~/learndevops/test-of-collections$ ansible-galaxy collection install vp_netology-learn_ansible-1.0.0.tar.gz --force
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Installing 'vp_netology.learn_ansible:1.0.0' to '/home/vladimir/.ansible/collections/ansible_collections/vp_netology/learn_ansible'
vp_netology.learn_ansible:1.0.0 was installed successfully
vladimir@VP32Hard:~/learndevops/test-of-collections$ ansible-playbook site.yml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit
localhost does not match 'all'

PLAY [test my module] *******************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [localhost]

TASK [vp_netology.learn_ansible.my-test-role : Run file creation module] ****************************
ok: [localhost]

PLAY RECAP ******************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

vladimir@VP32Hard:~/learndevops/test-of-collections$ 
```


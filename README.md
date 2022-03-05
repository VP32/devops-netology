1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.

aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Update CHANGELOG.md

`git show aefea`

2. Какому тегу соответствует коммит 85024d3?

tag: v0.12.23

`git show 85024d3`

3. Сколько родителей у коммита b8d720? Напишите их хеши.

2 родителя:
```
56cd7859e05c36c06b56d013b55a252d0bb7e158
9ea88f22fc6269854151c571162c5bcf958bee2b
```

```
git show b8d720
git show b8d720^1
git show b8d720^2
```


5. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

```
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release
```

` git log  v0.12.23..v0.12.24^ --oneline`


6. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).

`8c928e83589d90a031f811fae52a81be7153e82f`

`git log -S'func providerSource('`


7. Найдите все коммиты в которых была изменена функция globalPluginDirs.

```78b12205587fe839f10d946ea3fdc06719decb05 Remove config.go and update things using its aliases
52dbf94834cb970b510f2fba853a5b49ad9b1a46 keep .terraform.d/plugins for discovery
41ab0aef7a0fe030e84018973a64135b11abcd70 Add missing OS_ARCH dir to global plugin paths
66ebff90cdfaa6938f26f908c7ebad8d547fea17 move some more plugin search path logic to command
8364383c359a6b738a436d1b7745ccdce178df47 Push plugin discovery down into command package
```
Находим файл и коммит, где появилась функция:

git log -S'globalPluginDirs' --stat --oneline

По имени файла и функции ищем коммиты с ее изменением:

`git log --oneline -L :globalPluginDirs:plugins.go -s`

8. Кто автор функции synchronizedWriters?

Martin Atkins <mart@degeneration.co.uk>

находим все коммиты с функцией synchronizedWriters:

`git log -S'func synchronizedWriters(' --stat --oneline`

находим самый старый коммит, это 5ac311e2a, запоминаем имя файла synchronized_writers.go, вызываем git blame:

`git blame 5ac311e2a -C synchronized_writers.go`

находим по коду func synchronizedWriters(, автор Martin Atkins

Также дополнительно вызываем:

`git show 5ac311e2a`

автор коммита Martin Atkins <mart@degeneration.co.uk>

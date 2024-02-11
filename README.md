### Задача 1
В этом задании вы потренируетесь в:  
  
установке Elasticsearch,  
первоначальном конфигурировании Elasticsearch,  
запуске Elasticsearch в Docker.  
Используя Docker-образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:  
  
составьте Dockerfile-манифест для Elasticsearch,  
соберите Docker-образ и сделайте push в ваш docker.io-репозиторий,  
запустите контейнер из получившегося образа и выполните запрос пути / c хост-машины.  
Требования к elasticsearch.yml:  
  
данные path должны сохраняться в /var/lib,  
имя ноды должно быть netology_test.  
В ответе приведите:  
  
текст Dockerfile-манифеста,  
```
#Этап 1. Готовим файлы для установки эластика. Директива FROM указывает какой базовый образ использовать. Директива AS используется для мультистейд>
FROM centos:7 AS prep_files
#Скачиваем архив с эластиком в папку
COPY elasticsearch-7.14.0-linux-x86_64.tar.gz . /opt/
#Создаем папку и назначем её рабочей папкой, чтобы дальнейшие инструкции выполнялись в этой папке.
RUN mkdir /usr/share/elasticsearch
WORKDIR /usr/share/elasticsearch
# --strip-components=1 при распаковке убирает папку верхнего уровняи распаковывает все что в ней.
RUN tar --strip-components=1 -zxf /opt/elasticsearch-7.14.0-linux-x86_64.tar.gz
#Этап 2. Устанавливает эластик, открываем порт, и запускаем в фоновом режиме.
FROM centos:7
# container creator
MAINTAINER StrekozovVA
#Так можно определять переменные, которые будут доступны запущенным контейнерам.
ENV ELSTIC_CONTAINER true
RUN groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000
#Копируем файлы из предыдущего этапа в этот (Можно указать --from=0). Так же меняем владельца папки с эластиком.
COPY --chown=1000:1000 --from=prep_files /usr/share/elasticsearch /usr/share/elasticsearch
RUN mkdir /var/lib/data
RUN chown 1000 -R /var/lib/data
RUN chgrp 1000 -R /var/lib/data
#Добавляем в переменную PATH новый путь
WORKDIR /usr/share/elasticsearch
ENV PATH=/usr/share/elasticsearch/bin:$PATH
#Копируем конфиг эластика из папки где собираем внутрь образа.
COPY elasticsearch.yml . /usr/share/elasticsearch/config/
#Открываем порт эластика
EXPOSE 9200 9300
#Запускаем эластик
#CMD ["su elasticsearch && /usr/share/elasticsearch/bin/elasticsearch"]
```
ссылку на образ в репозитории dockerhub,  
`docker push svalker/str_elasticsearch:V1`  
[docker.io image](https://hub.docker.com/layers/svalker/str_elasticsearch/V1/images/sha256-d592a30f5faeef6dde1b42a20fa85a2666681552cf34f9cc174b2b5aec43863b?context=repo)  
ответ Elasticsearch на запрос пути / в json-виде.
Подсказки:

возможно, вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum,
при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml,
при некоторых проблемах вам поможет Docker-директива ulimit,
Elasticsearch в логах обычно описывает проблему и пути её решения.
Далее мы будем работать с этим экземпляром Elasticsearch.

Задача 2
В этом задании вы научитесь:

создавать и удалять индексы,
изучать состояние кластера,
обосновывать причину деградации доступности данных.
Ознакомьтесь с документацией и добавьте в Elasticsearch 3 индекса в соответствии с таблицей:

Имя	Количество реплик	Количество шард
ind-1	0	1
ind-2	1	2
ind-3	2	4
Получите список индексов и их статусов, используя API, и приведите в ответе на задание.

Получите состояние кластера Elasticsearch, используя API.

Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

Удалите все индексы.

Важно

При проектировании кластера Elasticsearch нужно корректно рассчитывать количество реплик и шард, иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

Задача 3
В этом задании вы научитесь:

создавать бэкапы данных,
восстанавливать индексы из бэкапов.
Создайте директорию {путь до корневой директории с Elasticsearch в образе}/snapshots.

Используя API, зарегистрируйте эту директорию как snapshot repository c именем netology_backup.

Приведите в ответе запрос API и результат вызова API для создания репозитория.

Создайте индекс test с 0 реплик и 1 шардом и приведите в ответе список индексов.

Создайте snapshot состояния кластера Elasticsearch.

Приведите в ответе список файлов в директории со snapshot.

Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.

Восстановите состояние кластера Elasticsearch из snapshot, созданного ранее.

Приведите в ответе запрос к API восстановления и итоговый список индексов.

Подсказки:

возможно, вам понадобится доработать elasticsearch.yml в части директивы path.repo и перезапустить Elasticsearch.

### Задача 1
В этом задании вы потренируетесь в:    
* установке Elasticsearch  
* первоначальном конфигурировании Elasticsearch  
* запуске Elasticsearch в Docker.  
Используя Docker-образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:  
* составьте Dockerfile-манифест для Elasticsearch  
* соберите Docker-образ и сделайте push в ваш docker.io-репозиторий,  
* запустите контейнер из получившегося образа и выполните запрос пути / c хост-машины.  
Требования к elasticsearch.yml:  
* данные path должны сохраняться в /var/lib,  
* имя ноды должно быть netology_test.  
В ответе приведите:  
* текст Dockerfile-манифеста,  
[dockerfile](https://github.com/Svalker1989/ElasticSearch_2/blob/main/dockerfile)  
ссылку на образ в репозитории dockerhub,  
`docker push svalker/str_elasticsearch:V1`  
[docker.io image](https://hub.docker.com/layers/svalker/str_elasticsearch/V1/images/sha256-d592a30f5faeef6dde1b42a20fa85a2666681552cf34f9cc174b2b5aec43863b?context=repo)  
ответ Elasticsearch на запрос пути / в json-виде.
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z1.PNG)  
Подсказки:  
возможно, вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum,  
при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml,  
при некоторых проблемах вам поможет Docker-директива ulimit,  
Elasticsearch в логах обычно описывает проблему и пути её решения.  
Далее мы будем работать с этим экземпляром Elasticsearch.  
  
### Задача 2
В этом задании вы научитесь:  
* создавать и удалять индексы  
* изучать состояние кластера 
* обосновывать причину деградации доступности данных.  
Ознакомьтесь с документацией и добавьте в Elasticsearch 3 индекса в соответствии с таблицей:  
  
Имя	Количество реплик	Количество шард  
ind-1	0	1  
ind-2	1	2  
ind-3	2	4  
Получите список индексов и их статусов, используя API, и приведите в ответе на задание.  
Список индексов:  
`curl -X GET "172.17.0.2:9200/*/?pretty"`  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z2_1.PNG)  
Статистика индекса:  
`curl -X GET "localhost:9200/*/_stats?pretty"`  
Получите состояние кластера Elasticsearch, используя API.  
`curl -X GET "172.17.0.2:9200/_cluster/health?pretty"`  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z2_2.PNG)  
Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?  
Т.к. в кластере всего 1 нода.  
Удалите все индексы.  
`curl -X DELETE "172.17.0.2:9200/*/?pretty"`  
Важно  
При проектировании кластера Elasticsearch нужно корректно рассчитывать количество реплик и шард, иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.  
  
### Задача 3
В этом задании вы научитесь:  
* создавать бэкапы данных  
* восстанавливать индексы из бэкапов.  
  
Создайте директорию {путь до корневой директории с Elasticsearch в образе}/snapshots.  
Используя API, зарегистрируйте эту директорию как snapshot repository c именем netology_backup.  
Приведите в ответе запрос API и результат вызова API для создания репозитория.  
Перед добавлением необходимо добавить в `elasticsearch.yml` директиву `path.repo=/usr/share/elasticsearch/snapshots/`  
  
```
curl -X PUT "172.17.0.2:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshots/"
  }
}
'
```
Результат вызова API для создания репозитория:  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z3_1.PNG)
Создайте индекс test с 0 реплик и 1 шардом и приведите в ответе список индексов.
```
curl -X PUT "172.17.0.2:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}
'
```
Список индексов:  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z3_2.PNG)  
Создайте snapshot состояния кластера Elasticsearch.  
`curl -X PUT "172.17.0.2:9200/_snapshot/netology_backup/str_snapshot?pretty"`  
Приведите в ответе список файлов в директории со snapshot.  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z3_3.PNG)  
Удалите индекс test и создайте индекс test-2. Приведите в ответе список индексов.  
Удаление индекса `curl -X DELETE "172.17.0.2:9200/test/?pretty"`  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z3_4.PNG)  
Восстановите состояние кластера Elasticsearch из snapshot, созданного ранее.  
Приведите в ответе запрос к API восстановления и итоговый список индексов.  
```
curl -X POST "172.17.0.2:9200/_snapshot/netology_backup/str_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "test"
}
'
```
Итоговый список индексов:  
![](https://github.com/Svalker1989/ElasticSearch_2/blob/main/Z3_5.PNG)  
Подсказки:  
возможно, вам понадобится доработать elasticsearch.yml в части директивы path.repo и перезапустить Elasticsearch.

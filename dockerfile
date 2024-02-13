#Этап 1. Готовим файлы для установки эластика. Директива FROM указывает какой базовый образ использовать. Директива AS используется для мультистейдж билдов
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
USER 1000
#Запускаем эластик
#CMD ["/usr/share/elasticsearch/bin/elasticsearch"]

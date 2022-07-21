FROM elasticsearch:7.17.5

RUN mkdir /var/lib/elasticsearch/ && \
        chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/  && \
        mkdir /usr/share/elasticsearch/snapshots/ && \
        chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots/

COPY ./config/elasticsearch.yml /usr/share/elasticsearch/config/

EXPOSE 9200

CMD ["bin/elasticsearch"]

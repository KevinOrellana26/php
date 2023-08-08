FROM ubuntu:latest

#Evita que los comandos de apt no soliciten interacción con el usuario
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y php libapache2-mod-php

COPY ../index.php /var/www/html/index.php
COPY ../helloWorld.php /var/www/html/helloWorld.php

WORKDIR /var/www/html

EXPOSE 80

CMD [ "apachectl", "-D", "FOREGROUND" ]

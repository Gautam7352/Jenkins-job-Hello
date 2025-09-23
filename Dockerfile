FROM jenkins/jenkins:lts

USER root

RUN apt-get update &&  apt-get install -y python3

COPY script.py  /usr/src/app/script.py

USER jenkins


COPY config.xml /usr/share/jenkins/ref/jobs/Python-Script-Runner/config.xml
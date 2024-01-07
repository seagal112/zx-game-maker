FROM python:3.10.0-slim-buster

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386
RUN apt-get update; apt-get install -y libgl1 default-jre wine32 make wget bc jq

RUN winecfg

WORKDIR /app

RUN pip install numpy opencv-python Pillow

COPY --from=rtorralba/zxbasic:latest /zxbasic /app/vendor/zxsgm/bin/zxbasic
COPY vendor /app/vendor
COPY Makefile /app/Makefile
COPY main.bas /app/main.bas
COPY screens-build.sh /app/screens-build.sh

ENTRYPOINT [ "make", "build" ]
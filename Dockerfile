FROM python:3.10.0-slim-buster

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386
RUN apt-get update; apt-get install -y libgl1 default-jre wine32 make wget

RUN winecfg

# # Download Mono
# RUN wget -P /mono http://dl.winehq.org/wine/wine-mono/4.9.3/wine-mono-4.9.3.msi

# # Install Mono Runtime for .NET Applications
# RUN wine msiexec /i /mono/wine-mono-4.9.3.msi
# RUN rm -rf /mono/wine-mono-4.9.3.msi

# # Fake X11 display for headless execution
# RUN apt-get install xvfb-run=1.20.4-r0

WORKDIR /app

RUN pip install numpy opencv-python Pillow

COPY --from=rtorralba/zxbasic:latest /zxbasic /app/vendor/zxbne/bin/zxbasic
COPY vendor /app/vendor
COPY Makefile /app/Makefile
COPY main.bas /app/main.bas

ENTRYPOINT [ "make", "build" ]
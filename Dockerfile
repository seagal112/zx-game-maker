FROM python:3.13.0-slim-bookworm

RUN apt-get update
RUN apt-get install -y libgl1 make wget bc jq libglib2.0-0

WORKDIR /app

RUN pip install numpy opencv-python Pillow matplotlib bin2tap

COPY --from=rtorralba/zxbasic:latest /zxbasic /app/vendor/zxsgm/bin/zxbasic
COPY vendor /app/vendor
COPY Makefile /app/Makefile
COPY main.bas /app/main.bas
COPY screens-build.sh /app/screens-build.sh
COPY check-memory.py /app/check-memory.py

ENTRYPOINT [ "make", "build", "--no-print-directory", "--silent" ]
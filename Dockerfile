FROM python:3.13.0-slim-bookworm

RUN apt-get update
RUN apt-get install -y libgl1 make wget jq libglib2.0-0

WORKDIR /app

RUN pip install numpy opencv-python pandas plotly kaleido bin2tap

COPY --from=rtorralba/zxbasic:latest /zxbasic /app/src/bin/zxbasic
COPY vendor /app/vendor
COPY Makefile /app/Makefile
COPY main.bas /app/main.bas
COPY src/bin/screens-build.py /app/src/bin/screens-build.py
COPY src/bin/check-memory.py /app/src/bin/check-memory.py

ENTRYPOINT [ "make", "build", "--no-print-directory", "--silent" ]
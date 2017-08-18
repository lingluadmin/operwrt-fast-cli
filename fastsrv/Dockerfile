FROM python:2.7
COPY .bashrc /root/
COPY ./src/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
EXPOSE 8000
VOLUME ["/fastsrv"]
WORKDIR /fastsrv/src

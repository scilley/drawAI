FROM python:3.5-slim
LABEL Darrin Scilley "scilley@openbooklabs.com"
RUN apt-get update -y && apt-get install -y gcc libc-dev

COPY . /app
ENV HOME=/app
WORKDIR /app

RUN pip3 install -r requirements.txt
EXPOSE 8080 

ENTRYPOINT ["python3", "server.py"]

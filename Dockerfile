FROM python:3.11.10-slim-bullseye
RUN pip install requests==2.32.3
WORKDIR /veld/code/


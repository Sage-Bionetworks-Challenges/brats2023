FROM python:3.10-slim

WORKDIR /usr/local/bin

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY surface_distance /usr/local/bin/surface_distance
COPY *.py .

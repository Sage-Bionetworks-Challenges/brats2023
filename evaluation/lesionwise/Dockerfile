FROM python:3.10-slim

WORKDIR /usr/local/bin

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY brats2023_metrics/surface_distance /usr/local/bin/surface_distance
COPY brats2023_metrics/metrics.py .
COPY *.py .

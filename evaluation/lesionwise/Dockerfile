FROM python:3.10-slim

WORKDIR /usr/local/bin

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY BraTS-2024-Metrics/surface_distance /usr/local/bin/surface_distance
COPY BraTS-2024-Metrics/metrics_*.py .
COPY *.py .

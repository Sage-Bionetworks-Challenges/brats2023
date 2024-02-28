FROM bitnami/pytorch:2.0.1

# Temporarily change to root user in order to create
# the .synapseCache folder required by synapseclient.
USER 0
RUN mkdir /.synapseCache
USER $CONTAINER_USER_I

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY 2023_challenge/evaluation/evaluation_utils.py .
COPY *.py .

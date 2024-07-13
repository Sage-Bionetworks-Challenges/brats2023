FROM python:3.9-slim

RUN apt-get update && apt-get install -y git
RUN git clone -b new-apis_v0.1.0-dev https://github.com/mlcommons/GaNDLF.git 
RUN pip install --upgrade pip \
    && cd GaNDLF \
    && pip install -e . \
    && pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cpu

# Something wonky is going on with numpy.... not sure what, but
# removing both distributions of numpy then reinstalling v1.25.0
# works......
RUN pip uninstall numpy -y && pip uninstall numpy -y && pip install numpy==1.25.0

WORKDIR /usr/local/bin/

COPY requirements.txt .
RUN pip install -r requirements.txt
COPY *.py .

FROM cbica/captk:release-1.8.1 as captk

WORKDIR /work/CaPTk/bin/

# Manually copy the Hausdorff binary, as an NITRC issue is
# preventing some of the precompiled apps from getting pushed
RUN curl https://captk.projects.nitrc.org/Hausdorff95_linux.zip -O  && \
    unzip -o Hausdorff95_linux.zip && \
    chmod +x Hausdorff95 && \
    rm Hausdorff95_linux.zip

FROM python:3.9-slim
COPY --from=captk /work /work

# Copy over shared libraries required by CaPTk application, then
# update the links and cache with `ldconfig`.
COPY --from=captk /usr/lib64/* /usr/lib/.
RUN ldconfig

WORKDIR /usr/local/bin/

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

COPY *.py .
RUN chmod +x *.py
COPY update_labels.sh .
RUN chmod +x update_labels.sh

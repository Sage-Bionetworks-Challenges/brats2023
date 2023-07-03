FROM cbica/captk:release-1.8.1

RUN yum install -y xz-devel
RUN pip install --upgrade pip
RUN pip install pandas synapseclient nibabel

WORKDIR /work/CaPTk/bin/

# Manually copy the Hausdorff binary, as an NITRC issue is
# preventing some of the precompiled apps from getting pushed
RUN curl https://captk.projects.nitrc.org/Hausdorff95_linux.zip -O  && \
    unzip -o Hausdorff95_linux.zip && \
    chmod +x Hausdorff95 && \
    rm Hausdorff95_linux.zip

WORKDIR /usr/local/bin/

COPY *.py .
RUN chmod +x *.py
COPY update_labels.sh .
RUN chmod +x update_labels.sh

# Override the base image's entrypoint so that the GUI does
# not start when the container is run
ENTRYPOINT ["/usr/bin/env"]

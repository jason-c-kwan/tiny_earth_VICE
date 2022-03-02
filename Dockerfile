# This is a VICE image that includes antismash for use in the Tiny Earth Genomics course
FROM cyversevice/jupyterlab-datascience:latest
LABEL maintainer="Jason Kwan <jason.kwan@wisc.edu>"

USER root

# First set up conda environments

# For antiSMASH:
RUN conda create -n antismash -y -c bioconda antismash

# For kofamscan:
RUN conda create -n kofamscan -y -c bioconda kofamscan

# For Prokka
RUN conda create -y -n prokka 

# We now install Prokka in its environment
SHELL ["conda", "run", "-n", "prokka", "/bin/bash", "-c"]
RUN conda install -y -c biobuilds perl=5.22
RUN conda install -y -c conda-forge parallel
RUN conda install -y -c bioconda prodigal blast=2.2 tbl2asn prokka

# We now need to download the antiSMASH databases
SHELL ["conda", "run", "-n", "antismash", "/bin/bash", "-c"]
RUN download-antismash-databases

# We now set up the kofamscan databases
SHELL ["conda", "run", "-n", "kofamscan", "/bin/bash", "-c"]
WORKDIR /opt/conda/envs/kofamscan/bin
RUN wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz && tar xvf profiles.tar.gz && rm profiles.tar.gz
RUN wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz && gunzip ko_list.gz
ADD config.yml /opt/conda/envs/kofamscan/bin/config.yml

## Add welcome message
USER jovyan
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ADD welcome_message /home/jovyan/.welcome_message
RUN cat /home/jovyan/.welcome_message >> /home/jovyan/.profile

WORKDIR /


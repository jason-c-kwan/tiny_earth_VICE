# This is a VICE image that includes antismash for use in the Tiny Earth Genomics course
FROM cyversevice/jupyterlab-datascience:latest
LABEL maintainer="Jason Kwan <jason.kwan@wisc.edu>"

# The following is adapted from the Antismash base Dockerfile
# set up apt-via-https
USER root
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg ca-certificates && \
    sudo apt-get clean -y && \
    sudo apt-get autoclean -y && \
    sudo apt-get autoremove -y && \
    sudo rm -rf /var/lib/apt/lists/*

# set up antiSMASH deb repo
ADD https://dl.secondarymetabolites.org/antismash-bullseye.list /etc/apt/sources.list.d/antismash.list
ADD https://dl.secondarymetabolites.org/antismash.asc /tmp/
RUN apt-key add /tmp/antismash.asc

# grab all the dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y \
        curl \
        default-jre-headless \
        diamond-aligner \
        fasttree \
        glimmerhmm \
        hmmer \
        hmmer2 \
        muscle \
        ncbi-blast+ \
        prodigal \
    && \
    sudo apt-get clean -y && \
    sudo apt-get autoclean -y && \
    sudo apt-get autoremove -y && \
    sudo rm -rf /var/lib/apt/lists/*

# The following is adapted from the Antismash Standalone-lite Dockerfile
ENV ANTISMASH_URL="https://dl.secondarymetabolites.org/releases/"
ENV ANTISMASH_VERSION="6.0.1"

ENV LANG C.UTF-8

# Grab antiSMASH
WORKDIR /
RUN curl -L ${ANTISMASH_URL}/${ANTISMASH_VERSION}/antismash-${ANTISMASH_VERSION}.tar.gz > /tmp/antismash-${ANTISMASH_VERSION}.tar.gz && \
    tar xf /tmp/antismash-${ANTISMASH_VERSION}.tar.gz && \
    rm /tmp/antismash-${ANTISMASH_VERSION}.tar.gz

ADD instance.cfg /antismash-${ANTISMASH_VERSION}/antismash/config/instance.cfg


RUN sudo /opt/conda/bin/pip3 install /antismash-${ANTISMASH_VERSION} && python3 -c "import antismash; antismash.config.build_config(['--databases', 'mounted_at_runtime'], modules=antismash.get_all_modules()); antismash.main.prepare_module_data()"

WORKDIR /usr/local/bin
RUN ln -s /antismash-${ANTISMASH_VERSION}/docker/run

RUN mkdir /matplotlib && MPLCONFIGDIR=/matplotlib python3 -c "import matplotlib.pyplot as plt" && chmod -R a+rw /matplotlib

VOLUME ["/input", "/output", "/databases"]
WORKDIR /output

# The folowing is adapted from the Antismash Standalone Dockerfile
# Grab the databases
RUN mkdir -p /local/databases && download-antismash-databases --data /local/databases
RUN rm -rf /opt/conda/lib/python3.9/site-packages/antismash/databases && ln -s /local/databases /opt/conda/lib/python3.9/site-packages/antismash/databases
VOLUME ["/input", "/output"]

WORKDIR /

# Now we install KofamScan
RUN git clone https://github.com/takaram/kofam_scan.git
RUN sudo apt-get update && apt-get install -y parallel
WORKDIR /kofam_scan
RUN wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz && tar xvf profiles.tar.gz && rm profiles.tar.gz
RUN wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz && gunzip ko_list.gz
ADD config.yml /kofam_scan/config.yml
ENV PATH="/kofam_scan:${PATH}"

# Now we install Prokka
WORKDIR /
RUN conda install -y -c biobuilds perl=5.22
RUN conda install -y -c conda-forge parallel
RUN conda install -y -c bioconda prodigal blast=2.2 tbl2asn prokka

# Now we install CheckM
RUN conda install -y -c bioconda checkm-genome

# Now we install GTDB-Tk
RUN conda install -c conda-forge -c bioconda gtdbtk=1.5.1

WORKDIR /

USER jovyan

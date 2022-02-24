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

# For CheckM
RUN conda create -n checkm -y -c bioconda checkm-genome

# For GTDB-Tk
RUN conda create -y -n gtdbtk -c conda-forge -c bioconda gtdbtk=1.5.1

# We now install Prokka in its environment
SHELL ["conda", "run", "-n", "prokka", "/bin/bash", "-c"]
RUN conda install -y -c biobuilds perl=5.22
RUN conda install -y -c conda-forge parallel
RUN conda install -y -c bioconda prodigal blast=2.2 tbl2asn prokka

# We now need to download the antiSMASH databases
SHELL ["conda", "run", "-n", "antismash", "/bin/bash", "-c"]
RUN download-antismash-databases

# We now set up the GTDB-Tk databases
SHELL ["conda", "run", "-n", "gtdbtk", "/bin/bash", "-c"]
WORKDIR /opt/conda/envs/gtdbtk/share/gtdbtk-1.5.1/db
#RUN /usr/bin/wget --no-verbose --show-progress --progress=bar:force:noscroll https://data.gtdb.ecogenomic.org/releases/latest/auxillary_files/gtdbtk_data.tar.gz && tar xvf gtdbtk_data.tar.gz && rm gtdbtk_data.tar.gz
# The following is the mirror download, which is sometimes faster
RUN /usr/bin/wget --no-verbose --show-progress --progress=bar:force:noscroll https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_data.tar.gz && tar xvf gtdbtk_data.tar.gz && rm gtdbtk_data.tar.gz

# We now set up the kofamscan databases
SHELL ["conda", "run", "-n", "kofamscan", "/bin/bash", "-c"]
WORKDIR /opt/conda/envs/kofamscan/bin
RUN wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz && tar xvf profiles.tar.gz && rm profiles.tar.gz
RUN wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz && gunzip ko_list.gz
ADD config.yml /opt/conda/envs/kofamscan/bin/config.yml

# Add welcome message
SHELL ["/bin/bash"]
ADD welcome_message /home/jovyan/.bash_profile

WORKDIR /

USER jovyan

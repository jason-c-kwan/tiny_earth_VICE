# This is a VICE image that includes antismash for use in the Tiny Earth Genomics course
FROM cyversevice/jupyterlab-datascience:latest
LABEL maintainer="Jason Kwan <jason.kwan@wisc.edu>"

USER root

# First set up conda environments

# For antiSMASH:
RUN conda create -n antismash -y -c bioconda antismash

# For kofamscan:
RUN conda create -n kofamscan -y

# For Prokka
RUN conda create -y -n prokka 

# For BiG-SCAPE
RUN conda create -y -n bigscape

# For clinker
RUN conda create -y -n clinker

# For Diamond
RUN conda create -y -n diamond

# We now install Prokka in its environment
SHELL ["conda", "run", "-n", "prokka", "/bin/bash", "-c"]
RUN conda install -y -c biobuilds perl=5.22
RUN conda install -y -c conda-forge parallel
RUN conda install -y -c bioconda prodigal blast=2.2 tbl2asn prokka

# We now need to download the antiSMASH databases
SHELL ["conda", "run", "-n", "antismash", "/bin/bash", "-c"]
RUN download-antismash-databases

# We now set up kofamscan and its databases
SHELL ["conda", "run", "-n", "kofamscan", "/bin/bash", "-c"]
RUN conda install -c bioconda kofamscan -y
WORKDIR /opt/conda/envs/kofamscan/bin
RUN wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz && tar xvf profiles.tar.gz && rm profiles.tar.gz
RUN wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz && gunzip ko_list.gz
ADD config.yml /opt/conda/envs/kofamscan/bin/config.yml

# Install BiG-SCAPE
WORKDIR /
SHELL ["conda", "run", "-n", "bigscape", "/bin/bash", "-c"]
RUN conda install -y -c anaconda python=3.6 numpy scipy networkx scikit-learn=0.19.1
RUN conda install -y -c bioconda hmmer fasttree
RUN conda install -y -c conda-forge biopython=1.70
RUN git clone https://git.wur.nl/medema-group/BiG-SCAPE.git && chmod +x /BiG-SCAPE/bigscape.py && chown -R jovyan /BiG-SCAPE
WORKDIR /BiG-SCAPE
RUN wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam32.0/Pfam-A.hmm.gz && gunzip Pfam-A.hmm.gz
RUN hmmpress Pfam-A.hmm
ENV PATH="/BiG-SCAPE:${PATH}"

# Install clinker
WORKDIR /
SHELL ["conda", "run", "-n", "clinker", "/bin/bash", "-c"]
RUN conda install -y -c conda-forge -c bioconda clinker-py

# Install diamond
SHELL ["conda", "run", "-n", "diamond", "/bin/bash", "-c"]
RUN conda install -y -c bioconda diamond

WORKDIR /

## Add welcome message
USER jovyan
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ADD welcome_message /home/jovyan/.welcome_message
RUN cat /home/jovyan/.welcome_message >> /home/jovyan/.profile

# Install R packages
RUN R -e "install.packages(c('vegan', 'ggplot2', 'plotly', 'viridis', 'grid', 'reshape2', 'ggalluvial'), dependencies=TRUE, repos='http://cran.us.r-project.org')"

# Add some useful scripts, and set up an environment for them
ADD bin_summary.py /usr/local/bin/bin_summary.py
ADD core_genes.py /usr/local/bin/core_genes.py
RUN conda create -n scripts -y -c conda-forge biopython pandas

WORKDIR /





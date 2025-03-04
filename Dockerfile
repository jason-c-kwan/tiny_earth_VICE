# This is a VICE image that includes antismash for use in the Tiny Earth Genomics course
FROM cyversevice/jupyterlab-datascience:latest
LABEL maintainer="Jason Kwan <jason.kwan@wisc.edu>"

USER root

# Install mamba for better dependency resolution
RUN conda install -n base -c conda-forge mamba -y

# First set up conda environments

# For antiSMASH:
RUN mamba create -n antismash -y -c conda-forge -c bioconda -c defaults --strict-channel-priority antismash=6.1.1
RUN conda run -n antismash pip install ipykernel && conda run -n antismash python -m ipykernel install --name antismash --display-name "Python (antismash)"

# For kofamscan:
RUN mamba create -n kofamscan -y

# For Prokka
RUN mamba create -y -n prokka 

# For BiG-SCAPE
#RUN mamba create -y -n bigscape

# For clinker
RUN mamba create -y -n clinker

# For Diamond
RUN mamba create -y -n diamond

# For barrnap
RUN mamba create -y -n barrnap

# For 16S visualization
RUN mamba create -y -n community -c conda-forge scikit-bio pandas numpy matplotlib scikit-learn
SHELL ["conda", "run", "-n", "community", "/bin/bash", "-c"]
RUN pip install ipykernel && python -m ipykernel install --name community --display-name "Python (community)"

# We now install Prokka in its environment
SHELL ["conda", "run", "-n", "prokka", "/bin/bash", "-c"]
RUN mamba install -y -c biobuilds perl=5.22
RUN mamba install -y -c conda-forge parallel
RUN mamba install -y -c bioconda prodigal blast=2.2 tbl2asn prokka
RUN pip install ipykernel && python -m ipykernel install --name prokka --display-name "Python (Prokka)"

# We now need to download the antiSMASH databases
SHELL ["conda", "run", "-n", "antismash", "/bin/bash", "-c"]
#RUN mamba install -c bioconda -c conda-forge nrpys -y
RUN pip install ipykernel && python -m ipykernel install --name antismash --display-name "Python (antismash)"
RUN download-antismash-databases

# We now set up kofamscan and its databases
SHELL ["conda", "run", "-n", "kofamscan", "/bin/bash", "-c"]
RUN mamba install -c bioconda kofamscan -y
WORKDIR /opt/conda/envs/kofamscan/bin
RUN wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz && tar xvf profiles.tar.gz && rm profiles.tar.gz
RUN wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz && gunzip ko_list.gz
ADD config.yml /opt/conda/envs/kofamscan/bin/config.yml
RUN chmod 644 /opt/conda/envs/kofamscan/bin/config.yml
RUN pip install ipykernel && python -m ipykernel install --name kofamscan --display-name "Python (kofamscan)"

### Add welcome message
#USER jovyan
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]
#ADD welcome_message /home/jovyan/.welcome_message
#RUN cat /home/jovyan/.welcome_message >> /home/jovyan/.profile

# Install BiG-SCAPE
WORKDIR /
#SHELL ["conda", "run", "-n", "bigscape", "/bin/bash", "-c"]
RUN git clone https://github.com/medema-group/BiG-SCAPE
WORKDIR /BiG-SCAPE
RUN mamba env create -f environment.yml
SHELL ["conda", "run", "-n", "bigscape", "/bin/bash", "-c"]
RUN mamba install -y -c bioconda hmmer
RUN wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam32.0/Pfam-A.hmm.gz && gunzip Pfam-A.hmm.gz
RUN hmmpress Pfam-A.hmm
RUN pip install .
ENV PATH="/BiG-SCAPE:${PATH}"
RUN chmod a+x /BiG-SCAPE/bigscape.py
RUN chmod -R a+wx /BiG-SCAPE/big_scape
RUN pip install ipykernel && python -m ipykernel install --name bigscape --display-name "Python (bigscape)"

# Install clinker
WORKDIR /
SHELL ["conda", "run", "-n", "clinker", "/bin/bash", "-c"]
RUN conda install -y -c conda-forge -c bioconda clinker-py
RUN pip install ipykernel && python -m ipykernel install --name clinker --display-name "Python (clinker)"

# Install diamond
SHELL ["conda", "run", "-n", "diamond", "/bin/bash", "-c"]
RUN conda install -y -c bioconda diamond
RUN pip install ipykernel && python -m ipykernel install --name diamond --display-name "Python (diamond)"

# Install barrnap
SHELL ["conda", "run", "-n", "barrnap", "/bin/bash", "-c"]
RUN conda install -y -c bioconda barrnap
RUN pip install ipykernel && python -m ipykernel install --name barrnap --display-name "Python (barrnap)"

## Install R packages
#RUN R -e "install.packages(c('vegan', 'ggplot2', 'plotly', 'viridis', 'grid', 'reshape2', 'ggalluvial'), dependencies=TRUE, repos='http://cran.us.r-project.org')"

# Add some useful scripts, and set up an environment for them
ADD bin_summary.py /usr/local/bin/bin_summary.py
ADD core_genes.py /usr/local/bin/core_genes.py
RUN conda create -n scripts -y -c conda-forge biopython pandas

RUN echo '#!/bin/bash\nsource /opt/conda/etc/profile.d/conda.sh\nconda activate "$1"\nexec "${@:2}"' > /usr/local/bin/with_conda && chmod +x /usr/local/bin/with_conda

USER jovyan
SHELL ["/bin/bash", "-c"]
RUN conda init bash && echo "conda activate base" >> /home/jovyan/.bashrc
WORKDIR /





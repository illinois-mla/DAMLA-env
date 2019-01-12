FROM ubuntu:bionic

MAINTAINER Matthew Feickert <matthewfeickert@users.noreply.github.com>

ENV HOME /root
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive
# Have Docker use Bash throughout
SHELL ["/bin/bash", "-c"]

# Install general dependencies
RUN apt-get -y -qq update && \
    apt-get -y -qq install apt-utils && \
    apt-get -y -qq update && \
    apt-get -y -qq upgrade && \
    apt-get -y -qq install \
        curl \
        wget \
        vim \
        emacs \
        git \
        libgl1-mesa-glx && \
    apt-get -y autoclean && \
    apt-get -y autoremove


RUN echo ""  >> ~/.bashrc \
    && echo "# as this is Ubuntu use C.UTF-8"  >> ~/.bashrc \
    && echo "export LC_ALL=C.UTF-8" >> ~/.bashrc \
    && echo "export LANG=C.UTF-8" >> ~/.bashrc

# Install miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p $HOME/miniconda && \
    echo ""  >> ~/.bashrc && \
    echo "# added by Miniconda3 installer"  >> ~/.bashrc && \
    echo 'export PATH="/root/miniconda/bin:$PATH"' >> ~/.bashrc && \
    rm miniconda.sh

# Create DAMLA environment
ENV PATH /root/miniconda/bin:$PATH
ADD environment.yml environment.yml
RUN conda config --set always_yes yes && \
    conda update -n base -c defaults -q conda && \
    conda env create -f environment.yml && \
    rm environment.yml && \
    conda clean -ilts

# This all gets run in a new shell when the DAMLA venv is activated
# Add packages from additional channels and install mls from GitHub
RUN source activate DAMLA && \
    conda env list && \
    conda install -c conda-forge \
       keras \
       libiconv \
       jupyter_contrib_nbextensions && \
    conda install -c astropy \
       emcee \
       astroml && \
    conda install pytorch-cpu -c pytorch && \
    pip install git+https://github.com/dkirkby/MachineLearningStatistics#egg=mls && \
    conda clean -ilts && \
    source deactivate

# Have Jupyter notebooks launch without command line options
RUN source activate DAMLA && \
    jupyter notebook --generate-config && \
    sed -i -e "/allow_root/ a c.NotebookApp.allow_root = True" ~/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/custom_display_url/ a c.NotebookApp.custom_display_url = \'http://localhost:8888\'" ~/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/c.NotebookApp.ip/ a c.NotebookApp.ip = '0.0.0.0'" ~/.jupyter/jupyter_notebook_config.py && \
    sed -i -e "/open_browser/ a c.NotebookApp.open_browser = False" ~/.jupyter/jupyter_notebook_config.py && \
    source deactivate

RUN conda config --set always_yes no

RUN rm -rf /root/src

RUN echo ". /root/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo ""  >> ~/.bashrc && \
    echo "# have DAMLA be default environment"  >> ~/.bashrc && \
    echo "conda activate DAMLA" >> ~/.bashrc

WORKDIR ${HOME}/data
VOLUME ["/root"]

# Start the container inside the conda environment
ENTRYPOINT ["/bin/bash"]

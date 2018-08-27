FROM ubuntu:bionic

MAINTAINER Matthew Feickert <matthewfeickert@users.noreply.github.com>

ENV HOME /root
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive
# Have Docker use Bash throughout
SHELL ["/bin/bash", "-c"]

# Install general dependencies
RUN apt-get -y -qq update
RUN apt-get -y -qq install apt-utils
RUN apt-get -y -qq update
RUN apt-get -y -qq upgrade
RUN apt-get -y -qq install curl \
   wget \
   vim \
   emacs \
   git \
   libgl1-mesa-glx

RUN echo ""  >> ~/.bashrc \
    && echo "# as this is Ubuntu use C.UTF-8"  >> ~/.bashrc \
    && echo "export LC_ALL=C.UTF-8" >> ~/.bashrc \
    && echo "export LANG=C.UTF-8" >> ~/.bashrc

# Install miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -b -p $HOME/miniconda
RUN echo ""  >> ~/.bashrc \
    && echo "# added by Miniconda3 installer"  >> ~/.bashrc \
    && echo 'export PATH="/root/miniconda/bin:$PATH"' >> ~/.bashrc

# Create DAMLA environment
ENV PATH /root/miniconda/bin:$PATH
RUN conda config --set always_yes yes
RUN conda update -q conda
RUN conda create -n DAMLA python=3.6 pip \
  numpy \
  scipy \
  pandas \
  matplotlib \
  seaborn \
  scikit-learn \
  hdf5 \
  h5py \
  pytables \
  pillow \
  jupyter \
  pytest

# This all gets run in a new shell when the DAMLA venv is activated
RUN source activate DAMLA \
    && conda env list \
    && pip install --upgrade pip \
    && conda install -c conda-forge keras \
       libiconv \
       jupyter_contrib_nbextensions \
    && conda install -c astropy \
       emcee \
       astroml \
    && conda install pytorch-cpu -c pytorch \
    && pip install wpca \
       tensorflow \
       tensorflow-probability \
       papermill \
       autograd \
    && source deactivate

# Install the mls package from the course syllabus repo
RUN source activate DAMLA \
    && mkdir src \
    && cd src \
    && git init \
    && git config core.sparseCheckout true \
    && git remote add -f origin https://github.com/illinois-mla/syllabus \
    && echo "mls" >> .git/info/sparse-checkout \
    && echo "MANIFEST.in" >> .git/info/sparse-checkout \
    && echo "setup.py" >> .git/info/sparse-checkout \
    && git checkout master \
    && pip install --upgrade . \
    && cd .. \
    && source deactivate

# Cleanup to save space
RUN source activate DAMLA \
    && conda clean -a \
    && source deactivate

# Have Jupyter notebooks launch without command line options
RUN source activate DAMLA \
    && jupyter notebook --generate-config \
    && sed -i -e "/allow_root/ a c.NotebookApp.allow_root = True" ~/.jupyter/jupyter_notebook_config.py \
    && sed -i -e "/custom_display_url/ a c.NotebookApp.custom_display_url = \'http://localhost:8888\'" ~/.jupyter/jupyter_notebook_config.py \
    && sed -i -e "/c.NotebookApp.ip/ a c.NotebookApp.ip = '0.0.0.0'" ~/.jupyter/jupyter_notebook_config.py \
    && sed -i -e "/open_browser/ a c.NotebookApp.open_browser = False" ~/.jupyter/jupyter_notebook_config.py \
    && source deactivate

RUN conda config --set always_yes no

RUN rm miniconda.sh

RUN echo ". /root/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc

WORKDIR /root
VOLUME ["/root"]

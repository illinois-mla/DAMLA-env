FROM ubuntu:bionic

MAINTAINER Matthew Feickert <matthewfeickert@users.noreply.github.com>

ENV HOME /root
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

# Install general dependencies
RUN apt-get -y -qq update
RUN apt-get -y -qq install apt-utils
RUN apt-get -y -qq update
RUN apt-get -y -qq upgrade
RUN apt-get -y -qq install curl wget vim emacs git

# Install miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -b -p $HOME/miniconda
RUN echo ""  >> ~/.bashrc \
    && echo "# added by Miniconda3 installer"  >> ~/.bashrc \
    && echo 'export PATH="/root/miniconda/bin:$PATH"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# Create DAMLA environment
ENV PATH /root/miniconda/bin:$PATH
RUN conda config --set always_yes yes
RUN conda update -q conda
RUN conda create -n DAMLA python=3.6 pip numpy scipy pandas matplotlib seaborn scikit-learn hdf5 pytables pillow jupyter
RUN /bin/bash -c "source activate DAMLA"
RUN pip install --upgrade pip
RUN conda install -c conda-forge libiconv jupyter_contrib_nbextensions
RUN conda install pytorch-cpu -c pytorch
RUN pip install wpca autograd tensorflow

RUN /bin/bash -c "source deactivate"
RUN conda config --set always_yes no

RUN rm miniconda.sh

WORKDIR /root
VOLUME ["/root"]

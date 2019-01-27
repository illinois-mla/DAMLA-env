# DAMLA-env

Docker image for the recommended Conda based environment for the Data Analysis and Machine Learning Applications course

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Docker Automated build](https://img.shields.io/docker/automated/illinoismla/damla-env.svg)](https://hub.docker.com/r/illinoismla/damla-env/)
[![Docker Build Status](https://img.shields.io/docker/build/illinoismla/damla-env.svg)](https://hub.docker.com/r/illinoismla/damla-env/builds/)
[![download-size number-of-layers](https://images.microbadger.com/badges/image/illinoismla/damla-env.svg)](https://microbadger.com/images/illinoismla/damla-env)

## Environment

### Python libraries

- [numpy](https://github.com/numpy/numpy)
- [scipy](https://github.com/scipy/scipy)
- [matplotlib](https://github.com/matplotlib/matplotlib)
- [seaborn](https://github.com/mwaskom/seaborn)
- [h5py](https://github.com/h5py/h5py)
- [pytables](https://github.com/PyTables/PyTables)
- [pillow](https://github.com/python-pillow/Pillow)
- [scikit-learn](https://github.com/scikit-learn/scikit-learn)
- [tensorflow](https://github.com/tensorflow/tensorflow)
- [tensorflow-probability](https://github.com/tensorflow/probability)
- [keras](https://github.com/keras-team/keras)
- [pytorch](https://github.com/pytorch/pytorch)
- [jupyter](https://github.com/jupyter)
- [nbdime](https://github.com/jupyter/nbdime)
- [pytest](https://github.com/pytest-dev/pytest/)
- [papermill](https://github.com/nteract/papermill)
- [daft](https://github.com/dfm/daft)
- [wpca](https://github.com/jakevdp/wpca)
- [autograd](https://github.com/HIPS/autograd)
- [astropy](https://github.com/astropy/astropy)
- [emcee](https://github.com/dfm/emcee)
- [astroml](https://github.com/astroml/astroml)

### Additional software

- [Conda](https://conda.io/docs/)
- [HDF5](https://support.hdfgroup.org/HDF5/)

## Suggested Use

### Running

To use the Docker image first [pull](https://docs.docker.com/engine/reference/commandline/pull/) it down from Docker Hub

```
docker pull illinoismla/damla-env
```

and then [run](https://docs.docker.com/engine/reference/commandline/run/) the image in a container while [exposing](https://docs.docker.com/engine/reference/run/#expose-incoming-ports) the container's internal port `8888` with the `-p` flag (this is necessary for Jupyter to be able to talk to the `localhost`)

```
docker run -it -p 8888:8888 illinoismla/damla-env
```

Once inside the container activate note that the DAMLA Conda environment is already activated and should be shown in the terminal prompt

```
(DAMLA) physicist@<hostname>:~/data$
```

though you can also verify this by listing the conda environments

```
conda env list
# conda environments:
#
base                     /opt/miniconda
DAMLA                 *  /opt/miniconda/envs/DAMLA
```

### Using for work

If you want anything you do in the container to safely persist then you should bindmount your local machine's file system to the container as a [volume](https://docs.docker.com/storage/volumes/).

As an example, running the image with

```
docker run --rm -it -v $PWD:/home/physicist/data -p 8888:8888 illinoismla/damla-env
```

runs the container and bindmounts the current directory on the local host (`$PWD`) to the path `/home/physicist/data` in the container. This is now a shared space between the local machine and the container so that the files there are **the same**.

To verify this for yourself, in another terminal on your local machine create a new file

```
# local machine
touch hello.txt
```

if you now navigate to `/home/physicist/data` in your container and `ls` you should see the file. If you now edit the file inside the container

```
# container
echo "hello from the inside the container" >> hello.txt
```

then on the local machine you see that the file has been changed as expected

```
# local machine
cat hello.txt
# hello from the inside the container
```

If you now exit the container, the container is [removed](https://docs.docker.com/engine/reference/commandline/rm/) as the [clean up](https://docs.docker.com/engine/reference/run/#clean-up---rm) flag `--rm` was used. However, the files on the local machine have persisted

```
# local machine
ls hello.txt
# hello.txt
```

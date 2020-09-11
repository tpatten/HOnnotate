#export CUDA_BASE_VERSION=10.0
#export CUDNN_VERSION=7.6.5.32
#export TENSORFLOW_VERSION=1.13.1

ARG CUDA_BASE_VERSION

# use CUDA + OpenGL
FROM nvidia/cudagl:${CUDA_BASE_VERSION}-devel-ubuntu16.04
MAINTAINER Domhnall Boyle (domhnallboyle@gmail.com)

# install apt dependencies
RUN apt-get update && apt-get install -y \
	git \
	vim \
	wget \
	software-properties-common \
	curl

# install newest cmake version
RUN apt-get purge cmake && cd ~ && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar -xvf cmake-3.14.5.tar.gz
RUN cd ~/cmake-3.14.5 && ./bootstrap && make -j6 && make install

# install python3.7 and pip
RUN apt-add-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.7 && \
    ln -s /usr/bin/python3.7 /usr/bin/python && \
    curl https://bootstrap.pypa.io/get-pip.py | python

# arguments from command line
ARG CUDA_BASE_VERSION
ARG CUDNN_VERSION

# set environment variables
ENV CUDA_BASE_VERSION=${CUDA_BASE_VERSION}
ENV CUDNN_VERSION=${CUDNN_VERSION}

# setting up cudnn
RUN apt-get install -y --no-install-recommends \             
	libcudnn7=$(echo $CUDNN_VERSION)-1+cuda$(echo $CUDA_BASE_VERSION) \             
	libcudnn7-dev=$(echo $CUDNN_VERSION)-1+cuda$(echo $CUDA_BASE_VERSION) 
RUN apt-mark hold libcudnn7 && rm -rf /var/lib/apt/lists/*

ARG TENSORFLOW_VERSION
ENV TENSORFLOW_VERSION=${TENSORFLOW_VERSION}

# install python dependencies
RUN python3.7 -m pip install pip --upgrade
RUN python3.7 -m pip install numpy \
                             matplotlib \
                             scikit-image \
                             transforms3d \
                             tqdm \
                             opencv-python \
                             cython \
                             open3d==0.8.0 \
                             scikit-learn \
                             pyyaml \
                             pypng \
                             vtk \
                             tensorflow_probability==0.5.0
RUN python3.7 -m pip install pyrender==0.1.23
RUN python3.7 -m pip install tensorflow-gpu==$(echo $TENSORFLOW_VERSION)
RUN python3.7 -m pip install tensorflow_probability==0.5.0

# for installing dirt
ENV CUDAFLAGS='-DNDEBUG=1'

# other packages
RUN apt-get install -y freeglut3-dev

CWD := $(shell pwd)

all: image run-jupyter-server

image:
	 cd docker && docker build -t udacity-conda3:latest .

run-jupyter-server:
	 docker run --name udacity-ipnb-run-env -v ${CWD}:/udacity/ -w /udacity/lessons -p 8888:8888 --rm -ti udacity-conda3


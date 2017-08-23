# udacity

## Run the IPNB server within Docker

### Using make

Simply run `make` to build or update the Docker image and start the Jupyter
server within a Docker container.

### Manually

To work with IronPythons Notebooks, build the docker image (to be done once):
```
cd docker && \
docker build -t udacity-conda3:latest . && \
cd -
```

Run the server within docker:
```
docker run --name udacity-ipnb-run-env -v ${UDACITY_WORKSPACE}:/udacity/ -w /udacity/lessons -p 8888:8888 --rm -ti udacity-conda3
```

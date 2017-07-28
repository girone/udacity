# udacity

## Run the IPNB server within Docker

To work with IronPythons Notebooks, build the docker image (to be done once):
```
cd docker
docker build -t udacity-conda3:latest .
```

Run the server within docker:
```
make jupyter-server
# or call directly:
docker run --name udacity-ipnb-run-env -v ${UDACITY_WORKSPACE}:/udacity/ -w /udacity/lessons -p 8888:8888 --rm -ti udacity-conda3
```

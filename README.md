# udacity

## Run the IPNB server

To work with IronPythons Notebooks, run the server within docker:

```
docker run --name udacity-ipnb-run-env -v /home/jonas/workspace/udacity:/udacity/ -w /udacity/lessons -p 8888:8888 --rm -ti udacity-conda3
```

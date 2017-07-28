jupyter-server:
	 docker run --name udacity-ipnb-run-env -v /home/jonas/workspace/udacity:/udacity/ -w /udacity/lessons -p 8888:8888 --rm -ti udacity-conda3


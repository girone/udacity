FROM continuumio/anaconda3
RUN conda create -n udacity_project python=3;  \
    source activate udacity_project;  \
    conda install numpy pandas matplotlib jupyter notebook seaborn pymongo; \
    conda install -c conda-forge cerberus  # -c specifies the channel from which to install the package
VOLUME ["/udacity/"]
EXPOSE 8888
WORKDIR ["/udacity/lessons"]
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]

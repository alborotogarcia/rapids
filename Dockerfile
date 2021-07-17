FROM rapidsai/rapidsai:21.06-cuda11.2-runtime-ubuntu20.04

ENV PATH /opt/conda/envs/rapids/bin:$PATH
ENV CONDA_DEFAULT_ENV rapids
RUN conda install -c conda-forge -c anaconda -y bqplot plotly ipympl jupyter-lsp-python jedi-language-server python-lsp-server jupyterlab-lsp perspective jupyterlab-git turbodbc selenium minio mlflow psycopg2 voila lxml bs4 wget; conda install -y -c esri tensorflow-gpu; conda update --all; conda install -c conda-forge -y libthrift==0.14.1; conda clean -tipy;

#RUN conda install -c conda-forge -c anaconda -y lxml bs4 wget; conda install -c esri tensorflow-gpu;
RUN pip3 install --no-cache-dir --user git+https://github.com/chaoleili/jupyterlab_tensorboard.git wget
RUN jupyter labextension install @finos/perspective-jupyterlab; jupyter labextension install @krassowski/jupyterlab-lsp; jupyter labextension install @finos/perspective-viewer-d3fc;  jupyter lab clean;

ENV PATH=$PATH:/root/.local/bin

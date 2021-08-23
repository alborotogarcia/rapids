FROM rapidsai/rapidsai:21.08-cuda11.2-runtime-ubuntu20.04-py3.8

ENV PATH /opt/conda/envs/rapids/bin:$PATH
ENV CONDA_DEFAULT_ENV rapids
RUN cd /tmp; conda install -c conda-forge -c anaconda -c esri -y awscli boto3 conda-build dash jupyter-dash bqplot plotly ipympl jupyter-lsp-python jedi-language-server python-lsp-server jupyterlab-lsp perspective jupyterlab-git turbodbc selenium minio mlflow psycopg2 voila lxml bs4 wget tensorflow-gpu unidecode tqdm elasticsearch elasticsearch-dbapi[opendistro] elasticsearch-dsl libthrift; git clone https://github.com/alborotogarcia/conda-spektral; cd conda-spektral/conda-recipes; conda build . ;conda clean -tipy;

# conda install -y -c esri tensorflow-gpu; conda update --all; conda install -c conda-forge -y unidecode tqdm elasticsearch elasticsearch-dbapi[opendistro] libthrift==0.14.1; git clone https://github.com/alborotogarcia/conda-spektral; cd conda-spektral/conda-recipes; conda build . ;conda clean -tipy;
COPY array_ops.py /opt/conda/envs/rapids/lib/python3.8/site-packages/tensorflow/python/ops/array_ops.py

#RUN conda install -c conda-forge -c anaconda -y lxml bs4 wget; conda install -c esri tensorflow-gpu;
RUN pip3 install --no-cache-dir --user git+https://github.com/chaoleili/jupyterlab_tensorboard.git wget bentoml git+https://github.com/opensearch-project/opensearch-py pandasticsearch
RUN jupyter labextension install @finos/perspective-jupyterlab; jupyter labextension install @krassowski/jupyterlab-lsp; jupyter labextension install @finos/perspective-viewer-d3fc;  jupyter lab clean;

ENV PATH=$PATH:/root/.local/bin

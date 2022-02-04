FROM rapidsai/rapidsai:22.02-cuda11.4-runtime-ubuntu20.04-py3.8

ENV PATH /opt/conda/envs/rapids/bin:$PATH
ENV CONDA_DEFAULT_ENV rapids
RUN cd /tmp; conda install -c conda-forge -c anaconda -c esri -y awscli boto3 conda-build dash jupyter-dash bqplot plotly ipympl jupyter-lsp-python jedi-language-server python-lsp-server jupyterlab-lsp perspective jupyterlab-git turbodbc selenium minio mlflow psycopg2 voila lxml bs4 wget tensorflow-gpu unidecode tqdm elasticsearch elasticsearch-dbapi[opendistro] prophet elasticsearch-dsl statsmodels libthrift==0.14.2; git clone https://github.com/alborotogarcia/conda-spektral; cd conda-spektral/conda-recipes; conda build . ;conda clean -tipy;

# RUN conda install -c conda-forge  pytorch-gpu torchvision torchaudio # breaks rapids cudatoolkit, prob try with pip wheel built

COPY array_ops.py /opt/conda/envs/rapids/lib/python3.8/site-packages/tensorflow/python/ops/array_ops.py

RUN pip install --no-cache-dir --user git+https://github.com/cliffwoolley/jupyter_tensorboard.git git+https://github.com/chaoleili/jupyterlab_tensorboard.git wget bentoml git+https://github.com/opensearch-project/opensearch-py pandasticsearch torch torchvision torchaudio torchtext
RUN jupyter labextension install @finos/perspective-jupyterlab; jupyter labextension install @krassowski/jupyterlab-lsp; jupyter labextension install @finos/perspective-viewer-d3fc;  jupyter lab clean;

ENV PATH=$PATH:/root/.local/bin

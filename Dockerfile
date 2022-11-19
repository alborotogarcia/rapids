FROM rapidsai/rapidsai:22.10-cuda11.5-runtime-ubuntu20.04-py3.8

# FROM rapidsai/rapidsai:22.04-cuda11.5-runtime-ubuntu20.04-py3.8

# ARG SCALA_VERSION=2.12.17 METALS_VERSION=0.11.2

ARG SPARK_VERSION=3.3.1 CUDNN_VERSION=8.2.1.32 LIBTHRIFT_VERSION=0.16.0
ENV CUDNN_VERSION=$CUDNN_VERSION LIBTHRIFT_VERSION=$LIBTHRIFT_VERSION SPARK_VERSION=$SPARK_VERSION PATH=/opt/conda/envs/rapids/bin:/root/.local/bin:$PATH:$SPARK_HOME/bin CONDA_DEFAULT_ENV=rapids SPARK_HOME=/opt/spark LD_LIBRARY_PATH=/opt/conda/envs/rapids/lib

RUN conda update -nbase conda -y; cd /tmp; source /opt/conda/bin/activate $CONDA_DEFAULT_ENV; conda install -c conda-forge -c anaconda -c pytorch -c pyviz -y magma-cuda115 awscli boto3 conda-build dash jupyter-dash bqplot plotly ipympl jupyter-lsp-python jedi-language-server python-lsp-server jupyterlab-lsp jupyterlab-git turbodbc selenium minio mlflow psycopg2 lxml bs4 wget unidecode tqdm elasticsearch elasticsearch-dbapi[opendistro] prophet elasticsearch-dsl statsmodels libthrift==$LIBTHRIFT_VERSION cudnn==$CUDNN_VERSION pyspark==$SPARK_VERSION ipyvuetify ipyvue ; conda clean -tipy; apt-get update; apt-get install --no-install-recommends -y vim openjdk-8-jdk; rm -rf /var/lib/apt/lists/*;

ARG ALMOND_VERSION=0.13.2 AMMONITE_VERSION=2.5.5 PLOTLY_VERSION=0.8.4 SCALA_VERSION=2.12.17 METALS_VERSION=0.11.2
# METALS_VERSION=0.11.9 SCALA_VERSION=2.13.10
ENV ALMOND_VERSION=$ALMOND_VERSION SCALA_VERSION=$SCALA_VERSION AMMONITE_VERSION=$AMMONITE_VERSION PLOTLY_VERSION=$PLOTLY_VERSION METALS_VERSION=$METALS_VERSION

# RUN cd /tmp; source /opt/conda/bin/activate $CONDA_DEFAULT_ENV; 
# RUN cd /tmp; source /opt/conda/envs/rapids/bin/activate; 

RUN wget https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.deb ; dpkg -i scala-$SCALA_VERSION.deb; rm -rf scala-$SCALA_VERSION.deb; rm -rf /var/lib/apt/lists/*;

# RUN conda install -c conda-forge  pytorch-gpu torchvision torchaudio # breaks rapids cudatoolkit, prob try with pip wheel built
# COPY array_ops.py /opt/conda/envs/rapids/lib/python3.8/site-packages/tensorflow/python/ops/array_ops.py

COPY voila_vuetify-0.5.2-py2.py3-none-any.whl /tmp
RUN source /opt/conda/bin/activate $CONDA_DEFAULT_ENV; pip install --no-cache-dir --user /tmp/voila_vuetify-0.5.2-py2.py3-none-any.whl 'voila>=0.3' perspective-python==1.0.1 wget bentoml git+https://github.com/opensearch-project/opensearch-py pandasticsearch Historic_Crypto torch torchvision torchaudio torchtext tensorflow-gpu transformers jupyter_bokeh panel holoviews pyviz_comms hvplot datasets wordcloud spacy jupyter-tensorboard-proxy==0.1.1; rm /tmp/voila_vuetify-0.5.2-py2.py3-none-any.whl ; rm -rf /root/.local/lib/python3.8/site-packages/google; ln -s /opt/conda/envs/rapids/include/google/protobuf /root/.local/lib/python3.8/site-packages/google
RUN source /opt/conda/bin/activate $CONDA_DEFAULT_ENV; jupyter labextension install @finos/perspective-jupyterlab; jupyter labextension install @krassowski/jupyterlab-lsp; jupyter labextension install @finos/perspective-viewer-d3fc;  jupyter labextension install jupyterlab-plotly; jupyter lab clean;
# jupyter labextension install @jupyterlab/server-proxy; jupyter labextension install jupyterlab-plotly; jupyter lab clean;

# git clone https://github.com/alborotogarcia/conda-spektral; cd conda-spektral/conda-recipes; conda build . ;conda clean -tipy;
RUN jupyter serverextension enable panel.io.jupyter_server_extension
COPY spark-$SPARK_VERSION-bin-hadoop3 /opt/spark

# RUN pip3 install --no-cache toree; jupyter toree install --spark_home=$SPARK_HOME;
# RUN apt-get update; apt install --no-install-recommends -y openjdk-8-jdk; wget https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.deb ; dpkg -i scala-$SCALA_VERSION.deb; rm -rf scala-$SCALA_VERSION.deb; apt-get clean
RUN wget -O /usr/local/bin/coursier https://git.io/coursier-cli; chmod +x /usr/local/bin/coursier ; 
RUN coursier launch --fork almond:$ALMOND_VERSION --scala 2.12 -M almond.ScalaKernel -- --install && coursier bootstrap org.scalameta:metals_2.12:$METALS_VERSION --force-fetch -o /opt/conda/envs/rapids/bin/metals -f

COPY metals-ls.json /opt/conda/envs/rapids/etc/jupyter/jupyter_server_config.d

RUN cd /opt/conda/envs/rapids/lib/python3.8/site-packages/notebook/static/components/ ; mkdir plotly && cd plotly;  wget https://cdn.plot.ly/plotly-latest.js; 
RUN sh -c '(echo "#!/usr/bin/env sh" && curl -L https://github.com/com-lihaoyi/Ammonite/releases/download/$AMMONITE_VERSION/2.12-$AMMONITE_VERSION) > /usr/local/bin/amm && chmod +x /usr/local/bin/amm'
RUN amm -c " \
import \$ivy.\`org.apache.spark::spark-sql:$SPARK_VERSION\` ; \ 
import \$ivy.\`org.plotly-scala::plotly-render:$PLOTLY_VERSION\` ; \
import plotly._, element._, layout._, Plotly._ ; \
import \$ivy.\`sh.almond::almond-spark:$ALMOND_VERSION\` ; \
import \$ivy.\`org.plotly-scala::plotly-almond:$PLOTLY_VERSION\` ; \
import \$ivy.\`org.apache.spark::spark-sql:$SPARK_VERSION\` ; \
import \$ivy.\`org.scalatestplus:junit-4-13_2.12:3.2.14.0\` ; \
import \$ivy.\`org.scalatestplus:mockito-4-2_2.12:3.2.11.0\` ; \
import \$ivy.\`org.scalatest:scalatest-funsuite_2.12:3.2.14\`; \
import \$ivy.\`org.scalatest:scalatest_2.12:3.2.14\` ; \  
import \$ivy.\`org.apache.spark::spark-sql-kafka-0-10:$SPARK_VERSION\` ; \
import \$ivy.\`org.apache.spark::spark-streaming:$SPARK_VERSION\` ; "

RUN pip install --no-cache protobuf==3.20.1 apache-beam[gcp,interactive,dataframe]==2.43.0
RUN source /opt/conda/bin/activate $CONDA_DEFAULT_ENV; conda install -y google-auth; conda clean -tipy;
# RUN pip3 install --no-cache /tmp/voila_vuetify-0.5.2-py2.py3-none-any.whl 'voila>=0.3'
# apache-beam[gcp,interactive,dataframe] google-cloud-pubsub google-cloud-bigquery 
#ENV PATH=$PATH:/root/.local/bin

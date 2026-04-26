FROM ghcr.io/mlflow/mlflow:v3.11.1-full

RUN pip install google-cloud-storage

# Download Cloud SQL Auth proxy
RUN curl -o cloud_sql_proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && \
    chmod +x cloud_sql_proxy

# Start both proxy and MLflow
CMD ./cloud_sql_proxy -instances=projects/$GOOGLE_CLOUD_PROJECT/zones/$CLOUDSQL_INSTANCE &  mlflow server --host 0.0.0.0

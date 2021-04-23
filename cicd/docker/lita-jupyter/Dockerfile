FROM lita:latest

ENV SKA_ENV=jSka

SHELL ["/bin/bash", "-c"]

RUN \
    source activate ${SKA_ENV} && \
    cd /srv/jeta/code/ && \
    python setup.py install && \
    cd /srv/jeta/requirements && \
    pip install -r production.txt && \
    source activate ${SKA_ENV} && \
    cd /srv/jeta/api && \
    python manage.py makemigrations && \
    python manage.py migrate && \
    source activate ${SKA_ENV} && \
    conda install -c conda-forge/label/cf202003 configurable-http-proxy && \
    pip install jupyterhub==1.1.0 && \
    pip install 'jupyterlab<2.0' && \
    jupyter labextension install -y @jupyterlab/hub-extension && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter serverextension enable --py jupyterlab --user && \
    jupyter lab build && \
    ln -snf /usr/share/fonts/truetype/dejavu /opt/conda/envs/jSka/lib/fonts

# Expose the port for jupyterhub
EXPOSE 5050

# Start Jupyterhub with custom configuration
ENTRYPOINT ["jupyterhub", "-f", "/srv/jupyterhub/config/jupyterhub_config.py"]

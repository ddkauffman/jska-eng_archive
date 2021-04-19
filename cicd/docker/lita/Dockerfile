FROM debian:buster-slim

LABEL version="1.1.1"
LABEL maintainer="David Kauffman <dkauffman@stsci.edu>"
LABEL "edu.stsci"="Space Telescope Science Institute"

# Conda Setup Environment Variables
ENV DISPLAY=${ARG_DISPLAY}
ENV PYTHONDONTWRITEBYTECODE=1
ENV CONDA_ROOT=/opt/conda
ENV SKA_ENV=jSka
ENV PATH=${CONDA_ROOT}/env/${SKA_ENV}/bin:${CONDA_ROOT}/bin:${PATH}

ARG ARG_NAME_COLUMN
ARG ARG_TIME_COLUMN
ARG ARG_VALUE_COLUMN
ARG ARG_RAVEN_SECRET_KEY

# Special Test Case Variables
ENV NAME_COLUMN=${NAME_COLUMN}
ENV TIME_COLUMN=${TIME_COLUMN}
ENV VALUE_COLUMN=${VALUE_COLUMN}
ENV QT_QPA_PLATFORM=offscreen
ENV MPLBACKEND=Qt5Agg

# Raven Variables
ENV RAVEN_SECRET_KEY=${ARG_RAVEN_SECRET_KEY}

# Archive Environment Variables
ENV ENG_ARCHIVE=/srv/telemetry/
ENV TELEMETRY_ARCHIVE=/srv/telemetry/archive/
ENV STAGING_DIRECTORY=/srv/telemetry/staging/

# JETA Environment Variables
ENV JETA_SCRIPTS=/srv/jeta/code/scripts
ENV ARCHIVE_DEFINITION_SOURCE="${JETA_SCRIPTS}/sql/create.archive.meta.sql"

# Install core system packages
RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        curl \
        supervisor \
        ipython \
        python3-matplotlib \
        python3-pip \
        libqt5gui5 \
        python3-pyqt4 \
        npm \
        nodejs \
        wget \
        vim \
    && apt-get clean

# Install required version of conda for the ska3 build script
RUN set -x \
    && wget https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh \
    && bash ./Miniconda3-4.3.21-Linux-x86_64.sh -f -b -p ${CONDA_ROOT} \
    && rm -f Miniconda3-4.3.21-Linux-x86_64.sh \
    && echo 'export PATH='${CONDA_ROOT}'/bin:$PATH' >>/etc/profile

RUN set -x \
    && conda config --env --set always_yes true \
    && conda create -n ${SKA_ENV} -c https://cxc.cfa.harvard.edu/mta/ASPECT/jska3-conda --yes ska3-flight

# Create project directories
RUN \
    mkdir --parents \
        /srv/jeta/code \
        /srv/jeta/log \
        /srv/jeta/api

# Copy source code into container
COPY jeta /srv/jeta/code/jeta
COPY raven /srv/jeta/api
COPY requirements /srv/jeta/requirements
COPY scripts ${JETA_SCRIPTS}

# Copy over setup.py for JETA
WORKDIR /srv/jeta/code
COPY setup.py /srv/jeta/code/setup.py

# ADD the start up script
ADD cicd/docker/lita/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set CWD to service root directory (useful with attaching shell)
WORKDIR /srv/jeta/

# Expose the port for raven
EXPOSE 9232

# Expose the port for jupyterhub
EXPOSE 5050

ENTRYPOINT ["/entrypoint.sh"]

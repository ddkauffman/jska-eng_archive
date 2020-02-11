#!/bin/bash

set -e


#-------------------------------------------------------------------------------
# Handle shutdown/cleanup
#-------------------------------------------------------------------------------
function cleanup {
    if [ "Z$WAIT_PIDS" != "Z" ]; then
        kill -15 $WAIT_PIDS
    fi
}

# trap signals so we can shutdown sssd cleanly
trap cleanup HUP INT QUIT TERM

echo "INFO: initializing user packages..."

cd /srv/jeta/code/;
source activate ska3;
python setup.py install

cd /srv/jeta/api
pip install -r requirements.txt
pip install jupyter

cd /srv/jeta/requirements
# TODO: Make this variable
pip install -r production.txt

set -x &&  touch /etc/profile.d/jska_login.sh;
set -x && ln -snf /usr/share/fonts/truetype/dejavu /opt/conda/envs/ska3/lib/fonts;

#
# set -x && npm install -g configurable-http-proxys;


echo "source activate ska3;" >> /etc/profile.d/jska_login.sh;

# ---------------------------------------------------------------------------
# configure supervisor
#-------------------------------------------------------------------------------
cat <<END >| /etc/supervisord.conf
[supervisord]
nodaemon=true
logfile=/tmp/supervisord.log
pidfile=/tmp/supervisord.pid

[program:jeta]
directory=/srv/jeta/api
command=gunicorn --pid /srv/jeta/raven.pid --bind 0.0.0.0:9232 -w 2 -e DJANGO_SETTINGS_MODULE="config.settings.base" --access-logfile - --error-logfile - --log-level trace config.wsgi:application
stdout_logfile=/srv/jeta/log/raven.log
stdout_logfile_maxbytes=0
stderr_logfile=/srv/jeta/log/raven.err
stderr_logfile_maxbytes=0

[program:jupyter]
directory=/srv/jeta/jupyter
command=jupyter notebook --no-browser --ip=0.0.0.0 --port=2150 --allow-root --NotebookApp.token='' --NotebookApp.password=''
stdout_logfile=/srv/jeta/log/jupyter.log
stdout_logfile_maxbytes=0
stderr_logfile=/srv/jeta/log/jupyter.err
stderr_logfile_maxbytes=0

[program:jupyterlab]
directory=/srv/jeta/jupyter
command=jupyter lab --no-browser --ip=0.0.0.0 --port=2151 --allow-root --NotebookApp.token='' --NotebookApp.password=''
stdout_logfile=/srv/jeta/log/jupyterlab.log
stdout_logfile_maxbytes=0
stderr_logfile=/srv/jeta/log/jupyterlab.err
stderr_logfile_maxbytes=0

[program:jupyterhub]
directory=/srv/jeta/jupyter
command=jupyter lab --no-browser --ip=0.0.0.0 --port=8080 --allow-root --NotebookApp.token='' --NotebookApp.password=''
stdout_logfile=/srv/jeta/log/jupyterhub.log
stdout_logfile_maxbytes=0
stderr_logfile=/srv/jeta/log/jupyterhub.err
stderr_logfile_maxbytes=0


END

#-------------------------------------------------------------------------------
# Cleanup stale Web API data and start supervisord
#-------------------------------------------------------------------------------
rm -f /srv/jeta/raven.pid
# python manage.py collectstatic --no-input --link --clear
if test -t 0; then
    /usr/bin/supervisord -c /etc/supervisord.conf &
    WAIT_PIDS=$!
    if [[ $@ ]]; then
        eval $@
    fi
    wait $WAIT_PIDS
else
    /usr/bin/supervisord -c /etc/supervisord.conf
fi



tail -f /dev/null
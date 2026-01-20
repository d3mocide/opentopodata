exec env N_UWSGI_THREADS=$(nproc --all) /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

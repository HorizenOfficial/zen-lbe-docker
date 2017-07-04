FROM zencash/gosu-base:1.10

MAINTAINER cronicc@protonmail.com

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install apt-utils \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install git virtualenv python-dev python3-dev build-essential libpcre3 libpcre3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /env \
    && git clone https://github.com/hellcatz/lbe-css.git /env/lbe-css \
    && cd /env/lbe-css \
    && virtualenv /env \
    && . /env/bin/activate \
    && pip install -r requirements.txt \
    && pip install uwsgi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# default uWSGI port
EXPOSE 9090

# default uWSGI stats port
EXPOSE 9191

VOLUME /mnt/lbe-css

ENV SERVER_TYPE="--http :9090" PROCESSES="2" THREADS="2" STATS="--stats 0.0.0.0:9191" COIN_NAME="Zencash" N_BLOCKS="100" RPC_HOST="" RPC_PORT="8231" RPC_USER="zenrpc" RPC_PASSWORD=""

CMD ["uwsgi --chdir /mnt/lbe-css --wsgi-file /mnt/lbe-css/lbe.py --callable app $SERVER_TYPE --master --processes $PROCESSES --threads $THREADS $STATS --pyargv '--coin '$COIN_NAME' --n-last-blocks '$N_BLOCKS' 0.0.0.0 34567 '$RPC_HOST' '$RPC_PORT' '$RPC_USER' '$RPC_PASSWORD''"]

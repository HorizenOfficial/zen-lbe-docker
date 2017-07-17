#!/bin/bash
set -e

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}
GRP_ID=${LOCAL_GRP_ID:-9001}

getent group user > /dev/null 2>&1 || groupadd -g $GRP_ID user
id -u user > /dev/null 2>&1 || useradd --shell /bin/bash -u $USER_ID -g $GRP_ID -o -c "" -m user

LOCAL_UID=$(id -u user)
LOCAL_GID=$(getent group user | cut -d ":" -f 3)

if [ ! "$USER_ID" == "$LOCAL_UID" ] || [ ! "$GRP_ID" == "$LOCAL_GID" ]; then
    echo "Warning: User with differing UID "$LOCAL_UID"/GID "$LOCAL_GID" already exists, most likely this container was started before with a different UID/GID. Re-create it to change UID/GID."
fi

echo "Starting with UID/GID : "$(id -u user)"/"$(getent group user | cut -d ":" -f 3)

export HOME=/home/user

if [ -n "$(find "/mnt/lbe-css" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
    cp -ar /env/lbe-css/* /mnt/lbe-css
fi

chown -R user:user /env /mnt/lbe-css

. /env/bin/activate

if [[ "$1" == uwsgi* ]]; then
    if [[ -v OPTS ]]; then
        exec /usr/local/bin/gosu user /bin/bash -c "$@ $OPTS"
    else
        exec /usr/local/bin/gosu user /bin/bash -c "$@"
    fi
fi

exec /usr/local/bin/gosu user "$@"

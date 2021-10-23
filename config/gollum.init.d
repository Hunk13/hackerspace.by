#!/bin/sh
### BEGIN INIT INFO
# Provides:          gollum
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: Start/stop gollum wiki
### END INIT INFO

# Distributed under the terms of the MIT License

set -e

# Edit these settings to your liking:
GOLLUM_USER=mhs
GOLLUM_BASE=/home/user/hackerspace.by/wiki/
GOLLUM_OPTS="--live-preview -b wiki -h 127.0.0.1"

NAME=mhs
PID=/var/run/${NAME}.pid
EXEC=/usr/local/bin/gollum
LOG=/var/log/gollum.log
PATH=$PATH:/home/user/.rvm/gems/ruby-2.3.1/bin:/home/user/.rvm/gems/ruby-2.3.1@global/bin:/home/user/.rvm/rubies/ruby-2.3.1/bin:/home/user/.rvm/bin:/home/user/.nvm/versions/node/v8.4.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
. /lib/lsb/init-functions

start ()
{
    # Change log file to be owned by GOLLUM_USER
    touch "${LOG}"
    chown "${GOLLUM_USER}" "${LOG}"
    log_daemon_msg "Starting Gollum"
    start-stop-daemon --start \
        --name "${NAME}" \
        --user "${GOLLUM_USER}" \
        --chuid "${GOLLUM_USER}" \
        --pidfile "${PID}" \
        --make-pidfile --background \
        --startas /bin/sh -- -c "exec ${EXEC} $GOLLUM_OPTS \"$GOLLUM_BASE\" > \"${LOG}\" 2>&1"
    log_end_msg $?
}

stop ()
{
    log_daemon_msg "Stopping Gollum"
    start-stop-daemon --stop \
        --user "${GOLLUM_USER}" \
        --signal INT \
        --pidfile "${PID}" \
        --retry 10
    log_end_msg $?
}

status ()
{
    status_of_proc -p $PID $EXEC $NAME
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        status
        ;;
    *)
        log_success_msg "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
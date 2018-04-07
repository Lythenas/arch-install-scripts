#!/bin/sh

function run {
    if ! pgrep $1 ;
    then
        echo "Running" $@
        ($@) &
    fi
}


# lock after 3 mins of inactivity,
# dim screen 30 secs before that
# and to to sleep 10 mins after locking
DIM_SCREEN=~/.config/awesome/lock/dim-screen.sh
LOCKER=~/.config/awesome/lock/locker.sh 

IDLE_TIME_TO_DIM=300 # 5min
IDLE_TIME_TO_LOCK=30

killall xss-lock
run xset s $IDLE_TIME_TO_DIM $IDLE_TIME_TO_LOCK
run xss-lock -n "$DIM_SCREEN" --transfer-sleep-lock -- "$LOCKER"

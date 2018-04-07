#!/bin/sh
# vim: fdm=marker foldenable

# {{{ run function
function run {
    if ! pgrep $1 ;
    then
        echo "Running" $@
        ($@) &
    fi
}
# }}}

# {{{ setup lockscreen and autolocking

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
# }}}

# {{{ autostart .desktop apps
# the -e AWESOME makes sure that gnome or kde only apps don't start
run dex -a -e AWESOME
# }}}

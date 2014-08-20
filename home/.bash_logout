# ~/.bash_logout: executed by bash(1) when login shell exits.

## Close dbus session
if [ -n "$DBUS_SESSION_BUS_PID" ]; then
    kill $DBUS_SESSION_BUS_PID
fi

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

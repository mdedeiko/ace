#!/bin/sh
# Setup HLS-Proxy
#

if [ ! -f hls-proxy ]; then
    echo "You should run install.sh from a directory of hls-proxy."
    echo "Interrupted"
    exit
fi

install1 () {

    # Add to autostart
    sudo -E bash -c 'cat >$AUTOSTART_FILE <<EOL
[Unit]
Description=HLS proxy for IPTV
Wants=network-online.target
After=multi-user.target

[Service]
User=$HLSUSER
ExecStart=$EXECUTABLE
ExecReload=/bin/kill -HUP \$MAINPID
ExecStop=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=always
Environment="HTTP_PROXY=$HTTP_PROXY"
Environment="HTTPS_PROXY=$HTTPS_PROXY"

[Install]
WantedBy=multi-user.target
Alias=hls-proxy$INSTANCE.service
EOL'

# Allow binding ports below 1024
#if [ -f "$(which setcap)" ]; then
#    sudo setcap 'cap_net_bind_service=+ep' $EXECUTABLE
#fi
# Nice persistent replacement for setcap

    BIND_PORT=$(get_http_port)

    if [ "$BIND_PORT" -lt "1024" ]; then
        export BIND_PORT

        if [ "$HLSUSER" != "root" ]; then

            BIND_RES="$(sudo sysctl -q net.ipv4.ip_unprivileged_port_start=$BIND_PORT)"

            if [ "$BIND_RES" = "" ]; then
              if [ "$(cat /etc/sysctl.conf|grep net.ipv4.ip_unprivileged_port_start)" = "" ]; then
                  sudo -E bash -c 'echo net.ipv4.ip_unprivileged_port_start=$BIND_PORT >> /etc/sysctl.conf'
                  echo Port $BIND_PORT permitted at /etc/sysctl.conf
              fi
            else
              echo You cant bind http port $BIND_PORT below 1024 as non root user
              echo "(Hint: Ubuntu 16 users should upgrade to 18)"
            fi

            unset BIND_PORT
        fi
    fi

    chmod 755 ./hls-proxy
    sudo $SYSTEMCTL enable hls-proxy$INSTANCE
    echo Added to autostart

}

get_http_port () {

  PORT=$(grep \"port\" local.json | awk '{print $2}' | sed s/[\s,]//g)

  if [ "$PORT" != "" ]; then
    echo $PORT
    return
  fi

  PORT=$(grep \"port\" default.json | awk '{print $2}' | sed s/[\s,]//g)

  if [ "$PORT" != "" ]; then
    echo $PORT
    return
  fi

  echo 80
}

uninstall1 () {

    sudo $SYSTEMCTL disable hls-proxy$INSTANCE
    sudo $SYSTEMCTL stop hls-proxy$INSTANCE

    if [ -f $AUTOSTART_FILE ]; then
        sudo rm $AUTOSTART_FILE
    fi

    echo HLS stopped and removed from autostart
}

start1 () {

    sudo $SYSTEMCTL restart hls-proxy$INSTANCE
    echo HLS-Proxy$INSTANCE started

}

status () {

    sudo $SYSTEMCTL status hls-proxy$INSTANCE

}

reloaddaemon () {

    sudo $SYSTEMCTL daemon-reload

}

help () {

    echo
    echo Usage:
    echo      ./install.sh [options]
    echo
    echo Options:
    echo      u - uninstall \(stop and remove from autostart\)
    echo      s - status \(and last log messages\)
    echo      h - this help

}

EXECUTABLE=$(pwd)/hls-proxy
ICON=$(pwd)/favicon.png
HLSUSER=$USER
INSTANCE=$(echo basename $0 | sed -e 's/[^0-9]//g')

# Store file at services dir
AUTOSTART_FILE="/lib/systemd/system/hls-proxy$INSTANCE.service"


# Detect chroot enviroment
if [ "$(stat -c %d:%i /)" != "$(sudo stat -c %d:%i /proc/1/root/.)" ]; then
    echo "We are under chroot! Use install_chroot.sh"
    exit 0    
fi

SYSTEMCTL=systemctl

export AUTOSTART_FILE
export EXECUTABLE
export HLSUSER
export SYSTEMCTL
export INSTANCE

if [ "$1" = "U" -o "$1" = "u" ]; then
    uninstall1
    reloaddaemon

elif [ "$1" = "S" -o "$1" = "s" ]; then
    status
elif [ "$1" = "H" -o "$1" = "h" ]; then
    help
else
    install1
    reloaddaemon
    start1
    help
fi



unset EXECUTABLE
unset AUTOSTART_FILE
unset HLSUSER
unset SYSTEMCTL
unset INSTANCE

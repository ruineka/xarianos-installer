#! /bin/bash


if [ $EUID -ne 0 ]; then
    echo "$(basename $0) must be run as root"
    exit 1
fi

dmesg --console-level 1

##################
Set up permissions
##################
chmod 777 /usr/bin/frzr-unlock
chmod 777 /usr/bin/frzr-release
chmod 777 /usr/bin/frzr-deploy
chmod 777 /usr/bin/__frzr-deploy
chmod 777 /usr/bin/frzr-bootstrap

#######################################

if ! frzr-bootstrap xarian; then
    whiptail --msgbox "System bootstrap step failed." 10 50
    exit 1
fi

# Connect to network
nmtui-connect

#### Post install steps for system configuration
# Copy over all network configuration from the live session to the system
MOUNT_PATH=/tmp/frzr_root
SYS_CONN_DIR="/etc/NetworkManager/system-connections"
if [ -d ${SYS_CONN_DIR} ] && [ -n "$(ls -A ${SYS_CONN_DIR})" ]; then
    mkdir -p -m=700 ${MOUNT_PATH}${SYS_CONN_DIR}
    cp  ${SYS_CONN_DIR}/* \
        ${MOUNT_PATH}${SYS_CONN_DIR}/.
fi

export SHOW_UI=1
frzr-deploy ruineka/xarianos:unstable
RESULT=$?

MSG="Installation failed."
if [ "${RESULT}" == "0" ]; then
    MSG="Installation successfully completed."
elif [ "${RESULT}" == "29" ]; then
    MSG="GitHub API rate limit error encountered. Please retry installation later."
fi

if (whiptail --yesno "${MSG}\n\nWould you like to restart the computer?" 10 50); then
    reboot
fi

exit ${RESULT}

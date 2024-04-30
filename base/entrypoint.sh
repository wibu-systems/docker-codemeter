#!/usr/bin/env bash

# Example entrypoint script used for CodeMeter Docker Container
#
# Behaviour can be changed by using the following environment variables
# CM_NETWORK_SERVER -> start CodeMeterLin with network server capabilities
# CM_REMOTE_SERVER  -> Add a given remote server to
# CM_LICENSE_FILE   -> Import the given License File at start of the Container (file has to be present)

CM_ALWAYS_IMPORT=${CM_ALWAYS_IMPORT:-off}
CM_NETWORK_SERVER=${CM_NETWORK_SERVER:-off}

start_cm_if_needed(){
  if [ ! -f /run/lock/cm_lock ];
  then
    /usr/sbin/CodeMeterLin -f &
    # We don't have Systemd's notify ability here, so just sleep
    echo "[+] Begin bootstrapping CodeMeter Runtime "
    sleep 1.5
  fi
}

loggingMode='-'
networkServer='-'

touch "${HOME}/.cm_init_lock"

if [[ "${CM_NETWORK_SERVER,,}" == "on" ]];
then
  networkServer='+'
fi

if [ -n "${CM_REMOTE_SERVER}" ];
then
   if ! cmu --list-server | grep -q "${CM_REMOTE_SERVER}" ;
  then
    start_cm_if_needed
    cmu --add-server "${CM_REMOTE_SERVER}"
  fi
fi


if [ -n "${CM_LICENSE_FILE}" ] && [ -f "${CM_LICENSE_FILE}" ];
then
  # First check if we already have a CmContainer imported
  start_cm_if_needed
  if cmu -l | grep -q "0 CmContainer" ;
  then
    cmu --import --file "${CM_LICENSE_FILE}" || exit 17
  else
    serial=`cmu -l | grep -Eo "1[3,4][0,1]-[[:digit:]]{5,}"`
    echo "-------------------------- [WARNING] --------------------------"
    echo -e "\t Already found License imported License ${serial}"  
    echo -e "\t Skipping import of ${CM_LICENSE_FILE}" 
    echo "-------------------------- [WARNING] --------------------------"
    # give user time to read the message :)
    sleep 2
  fi
fi


if test -f /run/lock/cm_lock ;
then
   kill -SIGTERM %1
   wait %1
   echo "[+] Bootstrapping completed"
fi

rm -f "${HOME}/.cm_init_lock"

DEFAULT_CM_CMD=('/usr/sbin/CodeMeterLin' "-v" "-l${loggingMode}" "-n${networkServer}")
set -- "${DEFAULT_CM_CMD[@]}" "$@"
## replace the current bash process with CodeMeterLin proc
exec "$@"

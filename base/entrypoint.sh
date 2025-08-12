#!/usr/bin/env bash

# Example entrypoint script used for CodeMeter Docker Container
#
# Behaviour can be changed by using the following environment variables
# CM_NETWORK_SERVER -> start CodeMeterLin with network server capabilities
# CM_REMOTE_SERVER  -> Add a given remote server to the Server Search List. Multiple entries may be given by separating them with a ','
# CM_LICENSE_FILE   -> Import the given License File(s) at startup of the Container. 
# CM_LOG_BOOTSTRAP  -> Enable Logging to stdout when bootstrapping
# CM_USE_BROADCAST_REMOTE_SERVERS   -> Enable Server Search via UPD-Broadcast

# CM_CMCLOUD_CREDENTIALS -> Import the given CmCloud-Credential file(s). This Option is not compatible with CM_LICENSE_FILE, CM_REMOTE_SERVER and CM_USE_BROADCAST_REMOTE_SERVERS.

# Exit Codes
EXIT_IMPORT_FAILED=17
EXIT_IMPORT_FILE_MISSING=16
EXIT_INVALID_OPTION_COMBINATION=15

CM_NETWORK_SERVER=${CM_NETWORK_SERVER:-off}

CM_LOG_BOOTSTRAP=${CM_LOG_BOOTSTRAP:-off}

start_cm_if_needed(){
  if cmu -l | grep -q 'not running';
  then
    echo "[+] Begin bootstrapping CodeMeter Runtime "
    
    CM_BOOTSTRAP_MODE=f
    if [[ "${CM_LOG_BOOTSTRAP,,}" == "on" ]];
    then
      CM_BOOTSTRAP_MODE=v
    fi

    /usr/sbin/CodeMeterLin -${CM_BOOTSTRAP_MODE} &
    # We don't have Systemd's notify ability here, so just sleep
    
    while cmu -l | grep -q 'not running' ;
    do
      sleep 0.5
    done
  else
    if [[ "${CM_LOG_BOOTSTRAP,,}" == "on" ]];
    then
      echo "[~] CodeMeter is already running"
    fi
  fi
}

touch "${HOME}/.cm_init_lock"
networkServer='-'

# Enable network server if needed
if [[ "${CM_NETWORK_SERVER,,}" == "on" ]];
then
  networkServer='+'
fi

set +x
CODEMETER_CMD=('/usr/sbin/CodeMeterLin' "-v" "-n${networkServer}")

if [ -n "${CM_CMCLOUD_CREDENTIALS}" ];
then
  # Sanity check argument combination
  if [ -n "${CM_REMOTE_SERVER}" ] || [ -n "${CM_LICENSE_FILE}" ] || [  -n "${CM_USE_BROADCAST_REMOTE_SERVERS}" ]
  then
    echo "Invalid combination of startup options given."
    echo "The Options 'CM_CMCLOUD_CREDENTIALS' is not compatible with CM_LICENSE_FILE, CM_REMOTE_SERVER and CM_USE_BROADCAST_REMOTE_SERVERS."
    exit $EXIT_INVALID_OPTION_COMBINATION
  fi

  # Expand the CMD Array for all files, given in `CM_CMCLOUD_CREDENTIALS`
  old_IFS=$IFS
  IFS=","
  for importee in $CM_CMCLOUD_CREDENTIALS;
  do
    if [ ! -f "${importee}" ];
    then
      echo "Cannot import file '${importee}'. File is missing or cannot be read."
      exit $EXIT_IMPORT_FILE_MISSING
    fi
    CODEMETER_CMD+=("-f:${importee}")
  done
  IFS=$old_IFS
  if [[ "${CM_LOG_BOOTSTRAP,,}" == "on" ]];
  then
    echo "[~] Starting CodeMeter with command: "
    echo "${CODEMETER_CMD[@]}"
  fi
  # expand the array & replace this process with CodeMeter
  rm "${HOME}/.cm_init_lock"
  set -- "${CODEMETER_CMD[@]}" "$@"
  exec "$@"
fi

# must be set later
CM_USE_BROADCAST_REMOTE_SERVERS=${CM_USE_BROADCAST_REMOTE_SERVERS:-on}

# Remove broadcast entry from server search list
if [[ "${CM_USE_BROADCAST_REMOTE_SERVERS,,}" == "off" ]];
then
  start_cm_if_needed
  if ! cmu --list-server | grep -q '255.255.255.255';
  then
    cmu --delete-server "255.255.255.255"
  fi
fi

# Handle Server search list entries
if [ -n "${CM_REMOTE_SERVER}" ];
then

  # store IFS so we can restore it later
  old_IFS=$IFS
  IFS=","
  for entry in $CM_REMOTE_SERVER;
  do
    if ! cmu --list-server | grep -q "${entry}" ;
    then
      start_cm_if_needed
      cmu --add-server "${entry}"
    fi
  done
  IFS=${old_IFS}
fi


# Handle license file import
if [ -n "${CM_LICENSE_FILE}" ];
then
  # check if sufficient containers are already imported
  import_count="${CM_LICENSE_FILE//[^,]}"
  import_count=$((${#import_count}+1))

  start_cm_if_needed

  # store IFS so we can restore it later
  old_IFS=$IFS
  IFS=","

  # Check if the expected amount of CmContainer(s) has already been imported
  if cmu -l | grep -q "${import_count} CmContainer" ;
  then
    serial=$(cmu -l | grep -Eo "1[3,4][0,1]-[[:digit:]]{5,}")
    echo "-------------------------- [WARNING] --------------------------"
    echo -e "\t Already found License imported License(s) '${serial}'"
    echo -e "\t Skipping import of ${CM_LICENSE_FILE}"
    echo "-------------------------- [WARNING] --------------------------"
    # give user time to read the message :)
    sleep 2
  else
    for importee in $CM_LICENSE_FILE;
    do
      if [ !  -f "${importee}" ];
      then
        echo "Cannot import file '${importee}'. File is missing or cannot be read."
        exit $EXIT_IMPORT_FILE_MISSING
      fi
      cmu --import --file "${importee}" || exit $EXIT_IMPORT_FAILED
    done
  fi
  IFS=${old_IFS}
fi

# Terminate the running CodeMeter Instance used for bootstrapping
if test -f /run/lock/cm_lock ;
then
   kill -SIGTERM %1
   wait %1
   echo "[+] Bootstrapping completed"
fi

rm -f "${HOME}/.cm_init_lock"

set -- "${CODEMETER_CMD[@]}" "$@"
## replace the current bash process with CodeMeterLin proc
exec "$@"

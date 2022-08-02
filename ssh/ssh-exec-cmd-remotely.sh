#!/bin/bash -
#===============================================================================
#
#          FILE: exec-cmd-remotely.sh
#
#         USAGE: ./exec-cmd-remotely.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: dm13y (), dm13y@yandex.by
#  ORGANIZATION:
#       CREATED: 02.08.2022 14:58:30
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

OPTIND=1
VERSION="1.0.0"

EXEC_AS_SUDO=""
INVENTORY=""
REM_HOST=""
USERNAME=""
CMD=""
EXEC_AS_SUDO=""

while getopts "i:nu:nc:nh:nsv" f; do
    case "$f" in
        i) INVENTORY="$OPTARG" ;;
        h) REM_HOST="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        c) CMD="$OPTARG" ;;
        s) EXEC_AS_SUDO="true" ;;
        v)
	       	echo "$VERSION"
                exit 1
                ;;
    esac
done

checkArg() {
   local value=$1
   local arg=$2
   if [[ -z "$value" ]]; then
        echo "$arg is missed\n"
   else
        echo ""
	   fi
	}

	checkArgs() {
	   local result=""	
	   if [[ -z "$REM_HOST" && -z "$INVENTORY" ]]; then
		result=" -i or -h arg is missed\n"
	   elif [[ ! -z "$REM_HOST" && ! -z "$INVENTORY" ]]; then
		result="i and h can't be used togeher;\n"
	   fi
	   result=${result}$(checkArg "$USERNAME" " -u")
	   result=${result}$(checkArg "$CMD" " -c")

	  if [[ ! -z "$result" ]]; then
			  printf "$result"
	  exit 
  fi
}

showHelp() {
   echo "Usage: $0 [-i inventory | -h host] [-u username] [-c command] [-s] [-v]"
   echo "Connecting to remote host by ssh and execute a command"
   echo "Available options:"  
   echo "   -i    specify host list that will be used for ssh connection"
   echo "   -h    specify one host that will be used for ssh connection" 
   echo "   -u    username that will be used by ssh"
   echo "   -c    command that should executed on remote host"
   echo "   -s    remote command as sudo. Default disabled"
   echo "   -v    show version and exit"
}

trimHost() {
        if [[ ! -z "$1" ]]; then
                echo "$1" | tr -d ' '
        fi
}

buildCommand() {
        local sudopass=$1

        if [ -z "$EXEC_AS_SUDO" ]; then
                echo "$CMD"
        else
                echo "echo $sudopass | sudo -S $CMD"
        fi
}

if [[ "$#" == "0" ]]; then
	showHelp
  exit  
fi

checkArgs

printf "\n%s password: " "$USERNAME"
read -rs SSH_PASSWORD

command=$(buildCommand "$SSH_PASSWORD")

if [[ ! -z "$INVENTORY" ]];then
  while read -r host;
  do	
     host=$(trimHost "$host")	
     if [[ -z "$host" || ${host::1} == "#" ]]; then
     	continue
     fi	
     printf "\n"	
     echo "Host: $host"
     echo "Command: $CMD"
     printf "Output:\n"
     sshpass -p "$SSH_PASSWORD" ssh -n -o StrictHostKeyChecking=no "$USERNAME@$host" "$command"
     printf "\nFinised\n"
  done < "$INVENTORY"
fi

if [[ ! -z "$REM_HOST" ]]; then
	sshpass -p "$SSH_PASSWORD" ssh -n -o StrictHostKeyChecking=no "$USERNAME@$REM_HOST" "$bcommand"
fi


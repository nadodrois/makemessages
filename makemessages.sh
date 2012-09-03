#!/bin/bash

FORCE=""
HELP=0
COMPILE=0
APP=""
LIB=wrlib

####
# Argument parsing
for a in ${@}
do   
    [[ ! "$a" =~ ^- ]] && APP="$a" && continue
    [[ "$a" == "-f" ]] && FORCE="-f " && continue
    [[ "$a" == "-h" ]] && HELP=1 && continue
    [[ "$a" == "-c" ]] && COMPILE=1 && continue    
done
#
####

_help(){
        
  msg="Following helptext refers to makemessages_for_dummies.sh directly"
  [[ "$1" != "" ]] && msg="Error: 
  
  $1"
  [[ ! -d "$LIB" ]] && msg="Dependency missing: Requires wrlib"
  cat <<HELP

  makemessages.sh [-c|-h] | [app_name] [-f]

  Wrapper script for makemessages_for_dummies.sh.

  Options:

  -h verbose help
  -f Force makemessage for ignored and forbidden
  -c compilemessages
  
  * Ignored and forbidden:
  folders: containing manage.py, missing models.py
  
  
  $msg

  ---

HELP
    if [[ "$1" != "" ]]
        then
        exit 1
    fi

    [[ -f $LIB/scripts/makemessages_for_dummies.sh ]] && $LIB/scripts/makemessages_for_dummies.sh -h
    
    exit 0
}

_compile(){
 ./manage.py compilemessages
 exit 0
}

_makemessages(){

    cd $APP &>/dev/null

    [[ "$?" > 0 ]] && _help "No directory/app: "$APP

    CMD="./../wrlib/scripts/makemessages_for_dummies.sh $FORCE--called"
     echo
    # echo $(pwd)
    # echo $CMD
    # echo
    $CMD
    if [[ "$?" > 1 ]] 
        then        
        cd ..
        _help "gotcha. Try -f"
    fi
    
    exit 0

}

[[ $HELP > 0 ]] && _help
[[ ! -d "$LIB" ]] && _help
[[ $COMPILE > 0 ]] && _compile
[[ $APP == "" ]] && _help "Please give me an app."

_makemessages
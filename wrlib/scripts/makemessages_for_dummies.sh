#!/bin/bash
_description(){
    cat <<DESC
# Finds all appearences of UPPERCASE_CONSTANT_i18n = ['list', 'of', 'words'] in *.py files recursive.
# Writes them to ./locale/i18n.py
#
# Convention:
# Define all dynamic translations (e.g. created with wrlib.lib.tools.lazy_choices_list) as
# UPPERCASE_CONSTANT_i18n = ['list', 'of', 'words']
# Use them as input for the translation.
# Example:
# ORIENTATION_LIST_i18n = ['north', 'north-east', 'east', 'south-east', 'south', 'south-west', 'west', 'north-west']
# ORIENTATION_CHOICES = lazy_choices_list(ORIENTATION_LIST_i18n)
# 
# Add manually (if not otherwise possible) DESCRIBING_CONSTANTS_i18n to app/_i18n.py
# Example:
# wrlib/_i18n.py
# ADMIN_TRANSLATIONS_i18n = ['Auth','auth','Sites','Site','sites','site']
#
DESC
}

####
# Variables
LN=de
FORCE=0
CALLED=0
HELP=0
####
# Argument parsing
for a in ${@}
do   
    [[ "$a" == "-f" ]] && FORCE=1 && continue
    [[ "$a" == "-h" ]] && HELP=1 && continue
    [[ "$a" == "--called" ]] && CALLED=1 && continue    
done
#
####

_help(){
    if [[ "$1" != "" ]] 
        then
        echo "Error: $1"
        exit 2
    fi
    
    if [[ $CALLED > 0 ]]
        then
        exit 1
    fi
    
    cat <<HELP

Only for direct usage:

1. cd into app directory
2. execute ../wrlib/scripts/makemessages_for_dummies.sh
3. fill the gaps in app/locale/i18n.py
4. cd into root/wrapper directory
5. execute ./manage.py compilemessages

Options:

-f Force execution in current directory

HELP
    _description
    exit 0
}

if [[ $FORCE < 1 ]]
        then
        [[ $HELP > 0 ]] && _help
        [[ -f "manage.py" ]] && _help "I have seen manage.py. Rootfolder should not be used for locales"
        [[ ! -f "models.py" ]] && _help "
        There is no models.py. 
        Folder: $(pwd)"
fi

gettext="from django.utils.translation import gettext as _"
message="# Do not change this file manually. Use wrlib/scripts/makemessages_for_dummies.sh"
NL="\\
"

[[ -d locale/$LN ]] || /bin/mkdir -p locale/$LN
#[[ -f locale/__init__.py ]] || echo "import i18n" > locale/__init__.py

/usr/bin/find . -type f -name "*.py" -print | xargs grep -Pn "^[A-Z_]*_i18n" > locale/i18n.py

/bin/cat locale/i18n.py | sed "s/'\([^,]*\)'/_('\1')/g" > locale/i18n.tmp

/bin/echo "$gettext

$message

" > locale/i18n.py

/bin/cat locale/i18n.tmp |  sed "s/^\(.*:\)/#\1$NL/g" >> locale/i18n.py

#/bin/cat locale/$LN/i18n.tmp | sed "s/^\(.*:\)/#\1/" > locale/de/i18n.tmp2
#/bin/cat locale/$LN/i18n.tmp2 | tr -s ":" "\n" > locale/$LN/i18n.py
/bin/rm locale/i18n.tmp*

OPT=""
[[ $FORCE > 0 ]] && OPT="--ignore=templates/admin/* --ignore=templates/registration/* --ignore=admin.py --ignore=i18n.py"
CMD="django-admin.py makemessages --all $OPT"
echo $(pwd)
echo $CMD
$CMD

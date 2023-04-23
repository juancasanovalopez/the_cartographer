#!/bin/bash

#
#     REQUIREMENTS
#

#    git
#    python flask
#    newt

# 
#     GLOBALS
#

#   Dialog box size height and with
dialog_box_h=16
dialog_box_w=50
operative_system=unknown

#
#     FUNCTIONS
#

available (){
# this function returns if a command is available 
# in your CLI interface it gets $1 as an input. It
# can be called: available "command_to_test"
    if ! command -v $1 &> /dev/null
    then
        echo "    $1 could not be found on your system"
        exit
    fi
}

check_os (){
# This function gets the operative_system name 
#
#
    os_type=`command uname`
    if (($os_type == "Darwin")); then
        operative_system=MacOS
    elif (($os_type == "Linux")); then
        # Check linux distribution
        distro=`command cat /etc/os-release | grep "\bID=\b"`
        operative_system="$distro"
    fi
}

#
#     MAIN
#



# Welcome and readme
command clear
echo " "
echo "    hello! this script creates a directory " 
echo "    to start a flask (python) project      "
echo "    it will guide you trough the process   "
echo "    and checks the requirements            "
echo " "
read -r -p "    Do you wish to continue? [y/N] ---> " continue


# detect system
check_os

if [[ "$continue" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # check if whiptail is availble
    if available "whiptail"; then
        project_name=$(whiptail --inputbox "Please give the project a name:" $dialog_box_h $dialog_box_w Name --title "$operative_system" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            echo "User selected Ok and entered " $project_name
            # mostrar opciones
            whiptail --textbox name_test $dialog_box_h $dialog_box_w
            install_options=(
                "Create readme.md" "" off
                "Create venv" "" off
                "Start Git repository" "" off
                "Create Dockerfile" "" off
            )
            whiptail --title "$project_name" --checklist "choose" $dialog_box_h $dialog_box_w 10 "${install_options[@]}"
            echo "$install_options"
        else
            echo "User selected exit."
            exit 0
        fi
        #echo "(Exit status was $exitstatus)"
    fi
else
    exit 0
fi



# Check requirements
#   newt library

mkdir $project_name
cd $project_name
# creacion de ficheros necesarios

#
# readme
#
if test -f "readme.md"; then
    echo "readme already exists."
else
    echo "# Title" >> readme.md
fi

#
# .gitignore
#
if test -f ".gitignore"; then
    echo ".gitignore already exists."
else
    echo -e "# Python
*.pyc
*~
__pycache__
# Env
.env
myvenv/
venv/

# Database
db.sqlite3

# Static folder at project root
/static/

# macOS
._*
.DS_Store
.fseventsd
.Spotlight-V100

# Windows
Thumbs.db*
ehthumbs*.db
[Dd]esktop.ini
$RECYCLE.BIN/

# Visual Studio
.vscode/
.history/
*.code-workspace " >> .gitignore

    # iniciar repositorio
    if ! command -v git &> /dev/null
    then
        echo "<the_command> could not be found"
        exit
    else
        command git init
    fi
fi

#
# Python virtual environment venv
#
echo -e "please, give your venv a name, 
be creative, something like... 
narnia, matrix will be ok :)"
read virtual_env_name
echo $virtual_env_name
venv_available=false

if test -f $virtual_env_name; then
    echo "venv already exists."
else
    if ! command -v python3 -m venv $virtual_env_name &> /dev/null
    then
        echo "something went wrong..."
        exit
    else
        command python3 -m venv $virtual_env_name
        echo $virtual_env_name"/" >> .gitignore
        venv_available=true
        # remember that command deactive deactivates the venv
    fi
fi
#TODO: verificaciones de estos comandos

command source $virtual_env_name/bin/activate
command pip install Flask
command pip freeze >> requirements.txt


#
# Principal Python Script
#
if test -f $project_name".py"; then
    echo $project_name".py already exists."
else
    echo -e "from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello():
    return 'Hello World!'
" >> $project_name".py"
fi

command export FLASK_APP=$project_name".py"
command export FLASK_DEBUG=true
command flask run

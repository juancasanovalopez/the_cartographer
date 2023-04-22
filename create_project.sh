#!/bin/bash

#requirements:
#    git
#    flask
#    newt
command clear

# Welcome and readme
echo " "
echo "    hello! this script creates a directory " 
echo "    to start a flask (python) project      "
echo "    it will guide you trough the process   "
echo "    and checks the requirements            "
echo " "

# Dialog box size (db_x)
dialog_box_h=16
dialog_box_w=50

read -r -p "    Do you wish to continue? [y/N] ---> " continue
if [[ "$continue" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    project_name=$(whiptail --inputbox "Please give the project a name:" $dialog_box_h $dialog_box_w Name --title "-" 3>&1 1>&2 2>&3)
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
    else
        echo "User selected Cancel."
    fi
    echo "(Exit status was $exitstatus)"
else
    exit 0
fi


# Check requirements
#   newt library

echo "this script creates a minimal flask project"
echo "please, enter the project name"

read project_name
echo $project_name

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

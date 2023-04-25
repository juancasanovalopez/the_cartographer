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
dialog_box_w=66
operative_system=unknown

#
#     FUNCTIONS
#

available (){
# this function returns if a command is available 
# in your CLI interface it gets $1 as an input. It
# can be called: available "command_to_test"
    if ! command -v $1 &> /dev/null;then
        echo "    $1 could not be found on your system" >> .log
        kill -INT $$
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

activate (){
# This function activates the virtual env
#
#
  . $1/bin/activate  
}

#
#     MAIN
#
# Welcome and readme

command clear
echo -e "
    hello! this script creates a directory 
    to start a flask (python) project
    it will guide you trough the process
    and checks the requirements"
read -r -p "    Do you wish to continue? [y/N] ---> " continue
command clear

# detect system
check_os

#declare options
options=(   "readme.md"
            "venv"
            ".gitignore"
            "git init"
            "Dockerfile")
            
options_description=(
            "Add readme file to project" 
            "Add virtual environment (recommended)"
            "Add .gitignore to project repository"
            "Start project repository"
            "Add Dockerfile to project")

if [[ "$continue" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # check if whiptail is availble
    if available "whiptail" ; then
        project_name=$(whiptail --inputbox "Please give the project a name:" $dialog_box_h $dialog_box_w Name --title "$operative_system" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            #echo "     User selected Ok and entered " $project_name
            # mostrar opciones
            #whiptail --infobox "name_test" $dialog_box_h $dialog_box_w
            install_options=$(whiptail --separate-output --checklist "Choose options" $dialog_box_h $dialog_box_w 6 \
                "${options[0]}" "${options_description[0]}" OFF \
                "${options[1]}" "${options_description[1]}" OFF \
                "${options[2]}" "${options_description[2]}" OFF \
                "${options[3]}" "${options_description[3]}" OFF \
                "${options[4]}" "${options_description[4]}" OFF 3>&1 1>&2 2>&3 )    
        else
            echo "User selected exit."
            exit 0
        fi
    fi
else
    exit 0
fi


#
#   DIRECTORY
#
mkdir $project_name

echo $install_options

if [ -z $install_options ]; then
  echo "No option was selected (user hit Cancel or unselected all options)"  
  rm -r $project_name
else
    cd $project_name
    pwd
    for install_option in $install_options; do
        case $install_option in
        ${options[0]})
        #
        #   readme.md
        #  
            if test -f "readme.md"; then
                echo "readme already exists."
            else
                echo "# Title" >> readme.md
            fi
        ;;
        ${options[1]})
        #
        #   venv
        #
            # python, pip and flask are available
            if [[ $operative_system == "MacOS" ]]; then
                python_command=python3
                pip_command=pip3
            else
                python_command=python
                pip_command=pip
            fi

            if available $python_command ; then echo "python available" >> .log
            else echo "python not available" >> .log
            fi

            if available $pip_command ; then echo "pip available" >> .log
            else echo "pip not available" >> .log
            fi

            virtual_env_name=$(whiptail --inputbox "Please give your virtual environmente a name, be creative, you can use the_OASIS, narnia, matrix if you are old enough...:" $dialog_box_h $dialog_box_w Name --title "$project_name" 3>&1 1>&2 2>&3)

            if test -f $virtual_env_name; then
                echo "venv already exists." >> .log
            else
                if available "python3 -m venv $virtual_env_name"; then 
                    echo "creating venv...">> .log
                    command python3 -m venv $virtual_env_name
                    echo $virtual_env_name"/" >> .gitignore
                    echo "venv $virtual_env_name ready">> .log
                    # remember that command deactivate deactivates the venv
                else
                    echo "something went wrong creating the virtual environment" >> .log
                fi
            fi
        
            # activates the virtual environment
            cd $virtual_env_name
            pwd
            . bin/activate
            cd .. 
            pwd    

            # install flask to venv       
            if available "flask" ; then
                command $pip_command install Flask
                command $pip_command freeze >> requirements.txt
                echo "flask available" >> .log
            else
                echo "flask not available" >> .log
            fi

        #
        # Main Python Script
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

        ;;
        ${options[2]})
            echo "${options[2]} selected"

            #
            # .gitignore
            #

            if available "git" ; then echo "git disponible" >> .log
            if test -f ".gitignore"; then
                echo ".gitignore already exists." >> .log
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
                command git init
            fi
        else echo "git no disponible" >> .log
        fi

        ;;
        ${options[3]})
            echo "${options[3]} selected"
        ;;
        ${options[4]})
            echo "${options[4]} selected"
        ;;
        *)
            echo "Unsupported item $install_option!" >&2
            exit 1
        ;;
    esac
  done
fi









#!/bin/sh

#
# a simple way to parse shell script arguments
# 
# please edit and use to your hearts content
# 
APP=mncsam
EXTENSION_DOMAIN="org"
ENVIRONMENT="dev"
DB_PATH="/data/db"
DOMAIN=$APP.$EXTENSION_DOMAIN
ORIGINAL_DOMAIN="mncsam.org"
DELIMITER="_"
#Username
USERNAME="dhuanca@samnaz.org"
PASS="Pollo0906"
# Your oauth token goes here, see link above
OAUTH_TOKEN="94926537d827da2c04ec0106761f9a1e54d890fa"
# Repo owner (user id)
OWNER="samnaz"
# Repo name
REPO="mncsam.org"
# The file name expected to download. This is deleted before curl pulls down a new one
VERSION="1.1"
EMAIL_NOTIOFICATION=dhuanca@samnaz.org

FOLDER_DESTINATION=~/public_html/sites

TMP=~/tmp


EXTENSION_FILE="zip"

function check(){

    read -p "Enter id: " ID
    echo "Id entering: $ID"

    if [ ! -d "$INSTALL_FOLDER" ]; then
        echo "The instalation with ID=$ID not found ($INSTALL_FOLDER), please created folder"
        
    fi

    if [ -d "$INSTALL_FOLDER" ]; then
        echo "The instalation with ID=$ID  found ($INSTALL_FOLDER)"
        
    fi
}

function init(){

    prepare_tmp
    ID=$(date +%Y%m%d%H%M%S)

    INSTALL_FOLDER=$TMP/install_$ID
    mkdir $INSTALL_FOLDER
    if [ ! -d "$INSTALL_FOLDER" ]; then
        
        echo "Error:  folder $INSTALL_FOLDER not created"
        
    fi
        echo "New Install folder has been created $INSTALL_FOLDER "


    INSTALL_FOLDER=$TMP/install_$ID
    EXTRACTED_FOLDER="$INSTALL_FOLDER/$REPO-$VERSION"
    check_folder_site
    
    show_variables
}    

function prepare_tmp(){
    if [ ! -d "$TMP" ]; then
        echo "Creating new folder $TMP"
        mkdir $TMP
    fi
 
}

function check_folder_site(){
    if [ ! -d "$FOLDER_DESTINATION" ]; then
        echo "Control will enter here if $FOLDER_DESTINATION doesn't exist."
        exit
    fi
 
}
function download()
{
    
    if [  -d "$INSTALL_FOLDER" ]; then

        cd $INSTALL_FOLDER

        FILE=$VERSION.$EXTENSION_FILE
        URL=https://github.com/$OWNER/$REPO/archive/$FILE
        DOMAIN_AUX="$( echo  "$DOMAIN" | tr  '.' $DELIMITER  )"
        DOMAIN_FOLDER=$ENVIRONMENT$DELIMITER$DOMAIN_AUX



        echo "==========================================================="
        echo " Download Release $VERSION  $URL"
        #curl -sL --user "$USERNAME:$PASS" https://github.com/$OWNER/$REPO/archive/$VERSION.$EXTENSION_FILE 

        curl -O --header 'Authorization: token 94926537d827da2c04ec0106761f9a1e54d890fa' \
             --header 'Accept: application/vnd.github.v3.raw' \
             --remote-name \
             --location https://github.com/$OWNER/$REPO/archive/$VERSION.$EXTENSION_FILE 


        echo "==========================================================="

        echo " Extracted file $FILE in  --> $EXTRACTED_FOLDER to "
        unzip -o $FILE

    fi
}

function install_site()
{
    
    cd $EXTRACTED_FOLDER
    mv site $DOMAIN_FOLDER
    echo "==========================================================="
    echo " copy site from $EXTRACTED_FOLDER to $FOLDER_DESTINATION "
    cp -R $DOMAIN_FOLDER/. $FOLDER_DESTINATION/$DOMAIN_FOLDER
}

function create_database(){

    SQL_SCRIPT=$EXTRACTED_FOLDER/database/samnazor_ncm.sql
    SQL_LOG=$EXTRACTED_FOLDER/database/database.log
    DATABASE_NAME=samnazor_ncm
    if [ $ORIGINAL_DOMAIN != $DOMAIN ]; then
        echo "Changing domain into sql script. From $ORIGINAL_DOMAIN to $DOMAIN"
        sed -i 's//$ORIGINAL_DOMAIN/$DOMAIN/g' $EXTRACTED_FOLDER/database/samnazor_ncm.sql
    fi

    echo "SQL script  $SQL_SCRIPT"
    echo "Creating database..."
    mysql -h localhost -u root -p$PASS < $SQL_SCRIPT> $SQL_LOG
}
function usage()
{
    echo "if this was a real script you would see something useful here"
    echo ""
    echo "./simple_args_parsing.sh"
    echo "\t-h --help"
    echo "\t--environment=$ENVIRONMENT"
    echo "\t--db-path=$DB_PATH"
    echo "\t--owner=$OWNER"
    echo "\t--repo=$REPO"
    echo "\t--version=$VERSION"
    echo "\t--folder-destination=$FOLDER_DESTINATION"
    echo ""
}

# Define a timestamp function
timestamp() {
  date +"%T"
}

sendmail(){
    echo "Sending email notification to $EMAIL_NOTIOFICATION"
    #echo "aaaa" | mail -s "Notification instalation ID=$ID" -r "TI Comunicaciones<noreply@samnaz.org>" dhuanca@samnaz.org
    echo "THIS IS A TEST EMAIL" | mail -s "Enter the subject" -r "TI Comunicaciones<noreply@samnaz.org>" dhuanca@samnaz.org
}

function show_variables(){
    printf "==================================== GITHUB PROPERTIES ======================================\n"
    printf "\tOWNER                  = %s \n" $OWNER 
    printf "\tREPO                   = %s \n" $REPO 
    printf "\tVERSION                = %s \n" $VERSION 
    printf "=============================================================================================\n"
    printf "                  INSTALL  --> $ID                                                           \n"
    printf "=============================================================================================\n"
    printf "\tAPP                    = %s \n" $APP
    printf "\tDOMAIN                 = %s \n" $DOMAIN
    printf "\tORIGINAL_DOMAIN        = %s \n" $ORIGINAL_DOMAIN
    printf "\tINSTALL_FOLDER         = %s \n" $INSTALL_FOLDER
    printf "\tENVIRONMENT            = %s \n" $ENVIRONMENT
    printf "\tFOLDER_DESTINATION     = %s \n" $FOLDER_DESTINATION 
    printf "\tEXTRACTED_FOLDER       = %s \n" $EXTRACTED_FOLDER 
    printf "=============================================================================================\n"

}
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -e | --environment)
            ENVIRONMENT=$VALUE
            ;;
        -db | --db-path)
            DB_PATH=$VALUE
            ;;
        -o | --owner)
            OWNER=$VALUE
            ;;  
        -r | --repo)
            REPO=$VALUE
            ;;              
        -v | --version)
            VERSION=$VALUE
            ;; 
        -f | --folder-destination)
            FOLDER_DESTINATION=$VALUE
            ;;    
        -d | --domain)
            DOMAIN=$VALUE
            ;;   
        -i | --id)
            ID=$VALUE
            ;;                                                       
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done





while true; do
    read -p "Do you have id instalation? " yn
    case $yn in
        [Yy]* ) check;download;;
        [Nn]* ) init;download;install_site;exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

clear
init
show_variables
sendmail

#while true; do
#    read -p "Do you have id instalation? " yn
#    case $yn in
#        [Yy]* ) make install; break;;
#        [Nn]* ) exit;;
#       * ) echo "Please answer yes or no.";;
#   esac
#done

#download
#install_site
#create_database

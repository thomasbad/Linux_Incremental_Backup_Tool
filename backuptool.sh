#!/bin/sh

### Function Area

## Backup mech
main_backup()
{
    if test -f "/main_backupscript.sh"; then
    if test -f "/main_backupscript.sh"; then
        tee -a /main_backupscript.sh > /dev/null << EOT
            if [ -d "$2/__prev/" ]; then
                rsync -a --delete --link-dest="$2/__prev/" "$1" "$2/$3"
            else
                rsync -a "$1" "$2/$3"
            fi
            rm -f "$2/__prev"
            ln -s "$3" "$2/__prev"
        EOT
    else
        mkdir /backup_script
        touch main_backupscript.sh
        chown root:root /backup_script/main_backupscript.sh
        chmod 755 /backup_script/main_backupscript.sh
        tee -a /main_backupscript.sh > /dev/null << EOT
            if [ -d "$2/__prev/" ]; then
                rsync -a --delete --link-dest="$2/__prev/" "$1" "$2/$3"
            else
                rsync -a "$1" "$2/$3"
            fi
            rm -f "$2/__prev"
            ln -s "$3" "$2/__prev"
        EOT
    fi
}

## Check Cron & Rsync is installed or not
check_prom()
{
    if ! command -v cron > /dev/null 2>&1
    then
        while true; do
            read -p "cron is not found for task schdule, do you wanna install it ? " cronyn
            case $cronyn in
                [Yy]* ) install_cron; break;;
                [Nn]* ) echo "The script cannot run without cron, the program will not exit."; exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    elif ! command -v rsync > /dev/null 2>&1
        then
            while true; do
            read -p "rsync is not found for backup purpose, do you wanna install it ? " rsyncyn
            case $rsyncyn in
                [Yy]* ) install_rsync; break;;
                [Nn]* ) echo "The script cannot run without rsync, the program will not exit."; exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

## Install cron
install_cron()
{
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; 
    then
        if ! command -v apt-get > /dev/null 2>&1
        then
            if ! command -v yum > /dev/null 2>&1
            then
                echo "Cannot find correct package installer in your system, please install cron manually."
            else
                yum install cronie -y && service crond start && chkconfig crond on
            fi
        else
            apt-get update && apt-get install cron -y
        fi
    else
        echo "The system have no network connective, please ensure the network is ON for needed software installation."
        exit
    fi
}

## Install rsync
rsync()
{
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; 
    then
        if ! command -v apt-get > /dev/null 2>&1
        then
            if ! command -v yum > /dev/null 2>&1
            then
                echo "Cannot find correct package installer in your system, please install cron manually."
            else
                yum install rsync -y
            fi
        else
            apt-get update && apt-get install rsync -y
        fi
    else
        echo "The system have no network connective, please ensure the network is ON for needed software installation."
        exit
    fi
}

#Backup Hourly from local to local
hourly_local2local()
{
    echo "Please input the path of your backup source"
    read hourlyLocal2LocalSrc
    echo "Please input the path of your backup destination"
    read hourlyLocal2LocalDest
    
}

# Create a Hourly Backup
backup_hourly()
{
    __hourlyusage="
What is your backup direction? Local or network?

[1] Backup from Local path to Local path    [Local -> Local]
[2] Backup from Local path to Network path  [Local -> Network]

"
    echo "__hourlyusage"
    while true; do
        read backupHourlyArgs
        case $backupHourlyArgs in
            [1]* ) 
            [2]* ) 
            * ) echo "Please answer the chosen mthod with number (For example: 1)."; echo "$__hourlyusage";;
        esac
    done
}


### Main Script Here
##Options
__help="
Usage: sudo $(basename $0) [OPTIONS]

This is a script help you to create a incremental backup using rsync.
It will use hardlink to save the backup to save storage space as much as possible,
without remember all the complex rsync sytax.

If you are looking for a manual version for more customized options,
you may check my github repo: thomasbad/Linux_versioning_Backup

Options:
  -h, --help                   Just showing this manual
  -v, --version                Showing the script version
"
while [ True ]; do
    if [ "$1" = "--help" -o "$1" = "-h" ]; then
        echo "$__help"
    elif [ "$1" = "--version" -o "$1" = "-v" ]; then
        echo "v0.1 Update on 24-Jul-2023"
    fi
done

# Check if the script run with sudoers or root
if [ "$EUID" -ne 0 ]
  then echo "Please run the script as root or sudoers"
  exit
fi
clear
check_prom
clear
__methodusage="

Please input the backup method you need.
Notice that if you have create any backup method using this script before,
the old options/script will be overwrited.

[1] Create or Add a Hourly Backup Job (Create hourly backups by current day and overwritten old backup from yesterday)
[2] Create or Add a Daily Backup Job with 7 days retention (Will overwrite the old one after 7 days)
[3] Create or Add a Daily Backup job with 30 days retention (Will overwrite the old one after 30 days)
[4] Create or Add a Monthly Backup Job (Will Backup every month's first date, will not be delete or overwrite)
[5] Create or Add a Incremental Backup job which will run Monthly, daily and hourly at the same time. (Monthly Backup will not be delete or overwite)
[6] Remove all backup scripts created by this program
[7] Exit this script

"
echo "$__methodusage"
while true; do
    read methodchoice
    case $methodchoice in
        [1]* ) 
        [2]* ) 
        * ) echo "Please answer the chosen mthod with number (For example: 1)."; echo "$__methodusage";;
    esac
done
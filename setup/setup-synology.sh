#!/bin/sh

usage(){
echo "Synology setup script."
echo ""
echo "  -h | --help displays this message"
echo "  -f | --force installs. All packages will be nuked. Be certain!"
}
while [ "$1" != "" ]; do
    case $1 in
        -f | --force )           shift
                                force=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# only seutp 1 so far... will continue to improve  when next one comes up

# Part 1: Install Entware

# Must be run as sudo
if [ "$EUID" -ne 0 ]; then
    echo "Must be run as root (use sudo !! to try again)"
    exit
fi

# Test if entware is already installed

function checkdo(){
    if [ $1 == "install" ]; then
        MACHINE_TYPE=`uname -m`
        cp entware/synology-startup.sh /usr/local/etc/rc.d/entware-startup.sh
        chmod +x /usr/local/etc/rc.d/entware-startup.sh
        echo ". /opt/etc/profile" >> /etc/profile
        if [ ${MACHINE_TYPE} == 'x86_64' ]; then
            wget -O - http://bin.entware.net/x64-k3.2/installer/generic.sh | /bin/sh
        else
            echo "Architecture type unsupported."
        fi
    fi
    if [ ! -d "$2" ]; then #if directory doesn't exist
        if [ $1 == "create" ]; then
            mkdir -p "$2"
            echo "$2 created."
        fi
        if [ $1 == "remove" ]; then
            echo "$2 does not exist so no need to delete."
        fi
        if [ $1 == "symlnk" ]; then
            echo "Failed to remove opt. Possible problem."
        fi
    else # if directory exists
        if [ "$force" == 1 ]; then
            if [ $1 == "create" ]; then
                mkdir -p "$2"
            fi
            if [ $1 == "remove" ]; then
                rm -rf "$2"
            fi
        else
            if [ $1 == "create" ]; then
                echo "$2 already exists meaning Entware is possibly already installed."
                echo "Re-run with --force to force installation."
                exit
            fi
            if [ $1 == "remove" ]; then
                read -p "About to remove $2. Are you sure? " -n 1 -r
                echo    
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$2"
                fi
            fi
        fi
        if [ $1 == "symlnk" ]; then
            ln -sf "$2" "$3"
        fi 
    fi
}

checkdo create /volume1/\@Entware/opt
checkdo remove /opt
checkdo symlnk /volume1/\@Entware/opt /opt
checkdo install


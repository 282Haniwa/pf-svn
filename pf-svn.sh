#!/usr/bin/env bash
# -*- coding: utf-8 -*-

SETUP_FLAG=false
WORK_DIRECTORY="/Users/UserName/WorkSpace/"
PAGE_URL="http://localhost:10280/index.html"
SSH_TARGET_SERVER="ssh target server"
SSH_PORT_FORWARD_ADDRESS="10280:target:80"

COMMAND_HELP="help"
COMMAND_SETUP="setup"
COMMAND_SSH="ssh"
COMMAND_PORT_FPRWARD="pf"
COMMAND_OPEN="open"
COMMAND_CHECK="check"
COMMAND_SVN="svn"
COMMAND_KILL="kill"
COMMAND_LIST=($COMMAND_HELP $COMMAND_SSH $COMMAND_PORT_FPRWARD $COMMAND_OPEN $COMMAND_CHECK $COMMAND_SVN $COMMAND_KILL)

function setup ()
{
    script_path="$( cd $( dirname ${0} );pwd )/$( basename ${0} )"
    echo 
    echo "Enter work directory."
    echo "It is Now \"${WORK_DIRECTORY}\"."
    echo "If you don't need change don't enter anything."
    read -e -p "> " new_work_directory
    if [ "${new_work_directory}" != "" ] ; then
        new_work_directory=$( echo $new_work_directory | sed -e "s:~/:${HOME}/:g" )
        sed -i ".old" -e "s:^WORK_DIRECTORY=\".*\":WORK_DIRECTORY=\"${new_work_directory}\":g" $script_path
    fi

    echo 
    echo "Enter page url."
    echo "It is Now \"${PAGE_URL}\"."
    echo "If you don't need change don't enter anything."
    read -p "> " new_page_url
    if [ "${new_page_url}" != "" ] ; then
        sed -i ".old" -e "s>^PAGE_URL=\".*\">PAGE_URL=\"${new_page_url}\">g" $script_path
    fi

    echo 
    echo "Enter ssh target server."
    echo "It is Now \"${SSH_TARGET_SERVER}\"."
    echo "If you don't need change don't enter anything."
    read -p "> " new_ssh_target_server
    if [ "${new_ssh_target_server}" != "" ] ; then
        sed -i ".old" -e "s>^SSH_TARGET_SERVER=\".*\">SSH_TARGET_SERVER=\"${new_ssh_target_server}\">g" $script_path
    fi

    echo
    echo "Enter port fowrading port number."
    echo "It is Now \"${SSH_PORT_FORWARD_ADDRESS}\"."
    echo "If you don't need change don't enter anything."
    echo "You should enter number."
    read -p "> " new_SSH_PORT_FORWARD_NUMBER
    if [ "${new_SSH_PORT_FORWARD_NUMBER}" != "" ] ; then
        sed -i ".old" -e "s/^SSH_PORT_FORWARD_ADDRESS=\".*\"/SSH_PORT_FORWARD_ADDRESS=${new_SSH_PORT_FORWARD_NUMBER}/g" $script_path
    fi

    if [ $SETUP_FLAG ] ; then
        sed -i ".old" -e "s/^SETUP_FLAG=.*/SETUP_FLAG=true/g" $script_path
    fi
    rm "${script_path}.old" > /dev/null 2>&1
}

function check_connection ()
{
    curl $PAGE_URL > /dev/null 2>&1
    return $?
}

function connect_ssh ()
{
    check_connection
    if [ $? == 0 ] ; then
        echo "Exit other connection"
        kill_processes
    fi
    echo "Connecting server..."
    ssh -L $SSH_PORT_FORWARD_ADDRESS $SSH_TARGET_SERVER
}

function port_forward ()
{
    check_connection
    if [ $? == 0 ] ; then
        echo "Network already connected."
    else
        echo "Connecting server..."
        ssh -fN -L $SSH_PORT_FORWARD_ADDRESS $SSH_TARGET_SERVER
    fi
}

function kill_processes ()
{
    pgrep -f -l $0
    pgrep -f -l "ssh .*${SSH_TARGET_SERVER}"
    for pid in $( pgrep -f "${0}" ) ; do
        read -p "Kill ${pid} process. OK?  (y/N) :" reaction
        if [ "${reaction}" == "y" ] ; then
            kill $pid
            if [ $? == 0 ] ; then
                echo "Killed ${pid}."
            fi
        fi
    done
    for pid in $( pgrep -f "ssh .*${SSH_TARGET_SERVER}" ) ; do
        read -p "Kill ${pid} process. OK?  (y/N) :" reaction
        if [ "${reaction}" == "y" ] ; then
            kill $pid
            if [ $? == 0 ] ; then
                echo "Killed ${pid}."
            fi
        fi
    done
}

function open_page ()
{
    check_connection
    while [ $? != 0 ] ; do
        sleep 1
        check_connection
    done
    open $PAGE_URL
}

function build_command ()
{
    if [[ $2 =~ " " ]] ; then
        echo "${1} \"${2}\""
    else
        echo "${1} ${2}"
    fi
}

function echo_usage ()
{
    echo "usage: ${0} [${COMMAND_LIST[@]}]"
}

function echo_help ()
{
    echo
    echo "Downloading README.md..."
    curl https://raw.githubusercontent.com/282Haniwa/pf-svn/master/README.md
}

# セットアップ
if [ $SETUP_FLAG == false ] ; then
    setup
    exit 0
fi

# オプション解析
for option in "${@}" ; do
    case $option in
        $COMMAND_HELP )
            echo_usage
            echo_help
            exit 0
            ;;
        $COMMAND_SETUP )
            setup
            exit 0
            ;;
        $COMMAND_SSH )
            connect_ssh
            exit 0
            ;;
        $COMMAND_PORT_FPRWARD )
            port_forward
            exit 0
            ;;
        $COMMAND_OPEN )
            case $2 in
                "page" )
                    (open_page) &
                    connect_ssh
                    exit 0
                    ;;
                "dir" )
                    open $WORK_DIRECTORY
                    exit 0
                    ;;
            esac
            echo "${0} ${COMMAND_OPEN} [page dir]"
            exit 0
            ;;
        $COMMAND_CHECK )
            check_connection
            if [ $? == 0 ] ; then
                echo "Already connected."
            else
                echo "No connection."
            fi
            exit 0
            ;;
        $COMMAND_SVN )
            # svnコマンドのwrap
            # コマンド実行時に接続を確認し、接続がない場合にポートフォワードを実行し、
            # svnコマンドを実行する。
            port_forward
            check_connection
            while [ $? != 0 ] ; do
                sleep 1
                check_connection
            done
            svn_command=""
            for arg in "${@}" ; do
                svn_command=$( build_command "${svn_command}" "${arg}" )
            done
            echo $svn_command
            eval $svn_command
            exit 0;
            ;;
        $COMMAND_KILL )
            kill_processes
            exit 0;
            ;;
        * )
            echo "illegal option ${option}"
            echo_usage
            echo_help
            exit 1
            ;;
    esac
    shift
done

# デフォルトコマンド内容
echo_usage

exit 0

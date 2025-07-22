#!/bin/bash

#####
#
# @name MyINFRA.eu ~ User Settings 1.0
# @version 2025.07.001
# @since 2025.07.001
#
# @copyright (c) 2025 (and beyond) - Dennis de Houx, All In One, One For The code
# @author Dennis de Houx <dennis@dehoux.be>
# @license https://creativecommons.org/licenses/by-nc-nd/4.0/deed.en CC BY-NC-ND 4.0
#
#####

load_settings () {
    DIALOG=$(whereis dialog | awk {'print $2'})
    USERNAME=$(id -un)
    GROUPNAME=$(id -gn)
    TEMPFILE="/tmp/${USER}.newuser"
    PWD="${HOME}/.config"
    TITLE=" USER SETTINGS "
    HEADER_SELECT="Dear ${USERNAME},\n\nThis is a checklist setup for new users on this system to enable/disable a few option that will be activated after you login.\n\nPlease select the options you want to enable.\n\n"
    if [[ -f "${PWD}/user.conf" ]]; then
        . ${PWD}/user.conf
        if [[ -v "${FANCY_PROMPT}" ]] || [[ -z "${FANCY_PROMPT}" ]]; then
            FANCY_PROMPT="off"
        fi
        if [[ -v "${ALIASES}" ]] || [[ -z "${ALIASES}" ]]; then
            ALIASES="off"
        fi
        if [[ -v "${MOTD_STATUS}" ]] || [[ -z "${MOTD_STATUS}" ]]; then
            MOTD_STATUS="off"
        fi
    else
        FANCY_PROMPT="on"
        ALIASES="on"
        MOTD_STATUS="on"
    fi
}


check_dialog () {
    if [[ -z "${DIALOG}" ]]; then
        apt install dialog -y -qqq > /dev/null 2>&1
        DIALOG=$(whereis dialog | awk {'print $2'})
    fi
}


show_selection () {
    COPYRIGHT="copyright (c) 2005 by One For The Code, Dennis de Houx [info@oftc.be]"
    LIST=(
        "fancy-prompt" "enable the fancy-prompt command line interface" "${FANCY_PROMPT}"
        "aliases" "enable opinionated aliasses" "${ALIASES}"
        "status" "enable show server status in motd" "${MOTD_STATUS}"
    )
    ${DIALOG} --clear --ascii-lines --backtitle "${COPYRIGHT}" --title "${TITLE}" "$@" \
        --checklist "${HEADER_SELECT}" 18 74 4 "${LIST[@]}" 2> ${TEMPFILE}
    RETVAL=$?
    clear
}


show_abort () {
    echo " "
    echo "Setup aborted, this account will use the operating system defaults."
    echo " "
    echo "Please wait while loading the initial settings..."
    sleep 5
    clear
    exit 0
}


setup_account () {
    echo -n "Dear ${USERNAME}, please wait while setting up your account..."
    CMD=$(echo "FIRST_RUN=false" > ${PWD}/user.conf)
    IFS=' ' read -r VARS <<< $(cat ${TEMPFILE})
    for VAR in ${VARS}; do
        case ${VAR} in
            "fancy-prompt")
                CMD=$(echo "FANCY_PROMPT=on" >> ${PWD}/user.conf)
                #CMD=$(source /opt/fancy-prompt/fancy-prompt.sh)
                source /opt/fancy-prompt/fancy-prompt.sh
                ;;
            "aliases")
                CMD=$(echo "ALIASES=on" >> ${PWD}/user.conf)
                #CMD=$(source /opt/fancy-prompt/fancy-aliases.sh)
                source /opt/fancy-prompt/fancy-aliases.sh
                ;;
            "status")
                CMD=$(echo "MOTD_STATUS=on" >> ${PWD}/user.conf)
                ;;
        esac
    done
    echo -e "\e[32m DONE \e[0m"
}


check_config_dir () {
    if [[ ! -d "${PWD}" ]]; then
        CMD=$(mkdir -p ${PWD})
        CMD=$(chown ${USERNAME}:${USERGROUP} ${PWD})
    fi
    if [[ ! -f "${PWD}/user.conf" ]]; then
        CMD=$(touch ${PWD}/user.conf)
        CMD=$(chown ${USERNAME}:${USERGROUP} ${PWD}/user.conf)
    fi
}


initialize () {
    echo -n "Please wait while loading new user settings... "
    load_settings
    check_dialog
    echo -e "\e[32m DONE \e[0m"
}


main () {
    #if [[ -z $(cat ${HOME}/.config/user.conf | grep "FIRST_RUN") ]]; then
    #    exit 0
    #fi
    initialize
    show_selection
    if [[ "${RETVAL}" != "0" ]]; then
        show_abort
    fi
    check_config_dir
    setup_account
}


### RUN MAIN PROGRAM
main

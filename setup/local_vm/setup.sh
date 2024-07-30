#!/usr/bin/env bash
#####################################
# Created by Silent-Mobius AKA Alex M. Schapelle
# Purpose: script for jenkins install for the 'jenkins shallow dive course'
# Date: 19/11/2022
# Version: 0.2.241
# set -x
set -o errexit
set -o pipefail
####################################

. /etc/os-release
SEPERATOR='--------------------------'

function main(){
    if [[ ${EUID} -eq 0 ]] || [[ ${UID} -eq 0 ]];then
       if deb_install || rpm_install;then
            jenkins_start
       fi
    else    
        note $SEPERATOR '[!] Please gain root permissins [!]' $SEPERATOR
    fi
}

function note(){
    printf "%s\n# %s\n%s" "$SEPERATOR" "$@" "$SEPERATOR"
}

function deb_install(){
    if [[ ${ID,,} == 'debian' ]] ||  [[ ${ID,,} == 'ubuntu' ]] ||  [[ ${ID,,} == 'linuxmint' ]];then
        curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
        echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
        apt-get update
        apt-get install -y jenkins default-java
        return 0
    else
        clear
        note $SEPERATOR '[!] Not Debian Based Distro' $SEPERATOR    
    fi
}


function rpm_install(){
    if [[ ${ID,,} == 'fedora' ]];then
        wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        dnf install -y java-17-openjdk jenkins
        return 0
    elif [[ ${ID,,} == 'redhat' ]] || [[ ${ID,,} == 'rocky' ]] || [[ ${ID,,} == 'almalinux' ]];then
        wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        yum install -y java-17-openjdk jenkins
        systemctl daemon-reload
        return 0
    else
        clear
        note $SEPERATOR '[!] Not RHEL Based Distro' $SEPERATOR
    fi
}

function jenkins_start(){
    systemctl enable --now jenkins
}


#######
# Main - _- _- _- _- _- _- _- _- _ Do Not Remove - _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _- _
#######
main
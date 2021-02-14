#!/bin/bash
VERSION='1'

#ENV/CONF
source reboot-required.conf

__main () {
    if [ -f "$RebootRequired" ]; then
        if [ -f "$Lockfile" ]; then
            __exit 0
        else
            if [ -f "$RebootRequiredPKGS" ]; then
                PKGS=$( cat $RebootRequiredPKGS )
                echo -e "A system reboot is required.\nDue to new installed upgrades or updates a system reboot is required. Please consider to reboot your system soon. You will receive this E-Mail only once, until the next reboot is required.\n\nPackages that require a reboot: $PKGS"\
                | mailx -r "$MailSender" -s "System reboot required." "$MailReceiver"
                touch $Lockfile
                __exit 0
            else
                echo -e "A system reboot is required.\nDue to new installed upgrades or updates a system reboot is required. Please consider to reboot your system soon. You will receive this E-Mail only once, until the next reboot is required."\
                | mailx -r "$MailSender" -s "$MailSender" "$MailReceiver"
                touch $Lockfile
                __exit 0
            fi
        fi
    else
        __exit 0
    fi
}

__exit () {
    ExitCode=$1

    if [ -z $ExitCode ]; then
        ExitCode='0'
    fi

    exit $ExitCode
}

__installCron () {
    CRON='>/dev/null 2>&1'
    (crontab -l 2>/dev/null; echo "$CRON") | crontab -
    __exit 0
}

if [ -z "$1" ]; then
    echo "no parameter set."
    __exit 1
else
    if [ $1 = "run" ]; then
        __main
    elif [ $1 = "install-cron" ]; then
        __installCron
    else
        echo "unknown funktion: $1."
        __exit 1
    fi
fi

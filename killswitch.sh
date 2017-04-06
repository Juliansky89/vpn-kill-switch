#!/bin/bash

function press_enter
{
    echo ""
    echo -n "Press Enter to continue"
    read
    clear
}

selection=
until [ "$selection" = "0" ]; do
    echo ""
    echo "ibVPN KillSwitch"
    echo "Note - it is advisiblht"    
    echo "1 - Enable KillSwitch"
    echo "2 - Disable KillSwitch"
    echo "3 - Backup current configuration"
    echo "4 - Restore configuration from backup"    
    echo ""
    echo "0 - exit program"
    echo ""
    echo -n "Enter selection: "
    read selection
    echo ""
    case $selection in
        1 ) sudo sh vpnfirewall.sh ;;
        2 ) sudo sh iptables_restore.sh ;;
        3 ) iptables-save > /opt/iptables.backup ;;
        4 ) iptables-restore < /opt/iptables.backup ;;
        0 ) exit ;;
        * ) echo "Please enter 1, 2, or 0";
    esac
done

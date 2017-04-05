    #!/bin/bash

###########################
## debugging
###########################

#set -x

###########################
## error_handler
###########################

echo "OK: restoring IPtables."

sudo iptables -P OUTPUT ACCEPT
sudo iptables -P INPUT  ACCEPT
sudo iptables -P FORWARD ACCEPT

echo "OK: flushing IPtables."

sudo iptables -F FORWARD
sudo iptables -F OUTPUT
sudo iptables -F INPUT


echo "OK: iptables restored."

exit 0

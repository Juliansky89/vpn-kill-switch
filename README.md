# vpn-kill-switch
VPN kill switch script to use with ibVPN service.
Just run:
<code>sudo sh killswitch.sh</code> and choose options:
1. Enable KillSwitch
2. Disable KillSwitch
0. Exit

# Instructions

Step 1. Clone the repo into your machine
git clone http://github.com/JulianskyCode/vpn-kill-switch


Step 2. Open the cloned repo (don't start the script yet):
cd vpn-kill-switch
https://www.ibvpn.com/billing/images/Linux_KillSWtich/1.png

Step 3. Connect to one of the ibVPN servers. This is important to be enabled now as you won't be able to connect after the killswitch has been enabled.

Step 4. After getting connected to the VPN, run the killswitch script:
sh killswitch.sh
https://www.ibvpn.com/billing/images/Linux_KillSWtich/2.png

# Options
Choose one of the options (preferably backing up your current config now):

  1. Enable KillSwitch -> it will launch the vpnfirewall preventing any access to the internet without a VPN.
  2. Disable KillSwitch -> it will disable vpnfirewall
  3. Backup current configuration -> backup for you initial configuration (run this option before any other)
  4. Restore configuration -> restores the backup your initially saved.
  
Note: After running the 1 st option (  KillSwitch) you'll probably see a bunch of messages that a specific host is not found please ignore that. You can test the Kill Switch by disabling the VPN, it shouldn't load any pages.

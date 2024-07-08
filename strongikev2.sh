#!/bin/bash

#Show all available profiles: sudo cat /etc/ipsec.conf | grep 'profile'

echo ''
for arg in strongswan libcharon-extra-plugins libstrongswan-extra-plugins resolvconf
do	
	PACKAGE_STATUS=$(dpkg -l | grep " $arg ")
	if [ -n "$PACKAGE_STATUS" ]
        then
        	
        	echo -e "\t\033[37mChecking "$arg" - \033[37m[\033[32mINSTALLED\033[37m]"
        	tput sgr0
		else
       		echo -e "\t\033[37mChecking "$arg"\033[37m package - \033[37m[\033[31mNOT INSTALLED\033[37m]"
       		echo -e "\t\033[37m\033[37m$arg - [\033[34mINSTALLING\033[37m]"
        	tput sgr0
        	apt install $arg      
    fi
done
echo ''
echo -e '\033[37mEnter VPN (IKEV2) details:'
echo -n -e "\033[37m   VPN Profile name (You can use any preferred name): \033[32m" 
read PROFILE_NAME
echo -n -e "\033[37m   Username: \033[32m" 
read USERNAME
echo -n -e "\033[37m   Password: \033[32m" 
read PASSWORD
echo -n -e "\033[37m   Server address: \033[32m" 
read SERVER_ADDRESS

printf '%b' '\n' 'conn '$PROFILE_NAME'\n' '\t#IKEv2 profile: '$PROFILE_NAME '\n'  '\tkeyexchange=ike\n' '\tdpdaction=clear\n' '\tdpddelay=300s\n' '\teap_identity='$USERNAME'\n' '\tleftauth=eap-mschapv2\n' '\tleft=%defaultroute\n' '\tleftsourceip=%config\n' '\tright='$SERVER_ADDRESS'\n' '\trightid=reliablehosting.com\n' '\trightauth=pubkey\n' '\trightsubnet=0.0.0.0/0\n' '\trightid= %any\n' '\ttype=tunnel\n' '\tauto=add\n' >> /etc/ipsec.conf
sed -i 's/load = yes/load = no/g' /etc/strongswan.d/charon/constraints.conf
printf '%s' $USERNAME ' : EAP ' $PASSWORD >> /etc/ipsec.secrets
echo '' >> /etc/ipsec.secrets
mv /etc/ipsec.d/cacerts /etc/ipsec.d/cacerts_old
ln -s /etc/ssl/certs /etc/ipsec.d/cacerts

echo ''
ipsec restart
echo ''
echo -e '\033[37mAll done, to connect VPN use \033[32m'sudo ipsec up $PROFILE_NAME'\033[37m command.'
echo -e '\033[37mTo stop VPN use \033[32m'sudo ipsec down $PROFILE_NAME'\033[37m command.'
echo ''
tput sgr0

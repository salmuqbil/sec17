#!/bin/bash

echo "               __    __ __      __               "
echo "          |  ||_ |  /  /  \|\/||_                "
echo "          |/\||__|__\__\__/|  ||__               "
echo "   __        __       __ __                  __  "
echo "  (_  /\ |  |_ |__|  /  /  \|\/||\/| /\ |\ ||  \ "
echo "  __)/--\|__|__|  |  \__\__/|  ||  |/--\| \||__/ "
echo "                                                 "
echo "*****   THIS CODE HAS TO BE RUN AS A ROOT in CentOS  *****"
#Saleh Almuqbil - Final Bash Script
#This code to be executed in CentOs 6.4 with Root privilages.
main(){
#	runPeacfully
	userInput=$@
	while [[ true ]]; do
		printf ">> Please pick one of the following [u]ser | [n]etwork | [q]uit | [h]elp: "
		read -a userInput
		case ${userInput[0]} in
			q|quit ) #quit
					break;;
			u|user ) userCommand $@;;
			n|network ) networkCommand;;
			* ) usage;;
		esac
	done
	echo "Good bye now ;)"
}


usage(){
	echo "[q]uit will exit from the code"
	echo "[u]ser will start the User Management Tool"
	echo "[n]network will start the Network Management Tool"
	echo "[h]elp will show the usage"
}

# **************** USER ****************
#This is the main function for user managment tool
#where it will take user input for commands.
userCommand(){
	userInput=$@
	while [[ true ]]; do
		printf "[User Management]>> "
		read -a userInput
		if [[ ${#userInput[@]} -eq 0 ]]; then
			helpUser
			continue
		fi
		case ${userInput[0]} in
			q|quit ) break;;
			gimmeUsers ) getuser $@;;
			addUser ) addNewUser userInput;;
			gimmePasswords ) getPassword userInput;;
			changePassword ) changeUserPassword userInput;;
			gimmeCurrentUser ) getCurrentUser;;
			deleteUser ) delUser userInput;;
			getLoggedUsers ) getLoggedInUsers;;
			disableUser ) disableUserAccount userInput;;
			gimmeFileExecutableAsRoot ) getFileExecAsRoot;;
			gimmeRelease ) getRelease;;
			* ) helpUser;;
		esac
	done
}

#help function to show the help details
helpUser(){
	echo "gimmeUsers to show all the users in /etc/passwd. Usage: gimmeUsers"
	echo "addUser to add a new user. Usage: addUser [username]"
	echo "gimmePasswords to show all the passwords in /etc/shadow. Usage: gimmePasswords [optional:username]"
	echo "changePassword to change a user password. Usage: changePassword [username]"
	echo "gimmeCurrentUser to get the current user details and Users last logged in. Usage: gimmeCurrentUser"
	echo "deleteUser to delete a username. Usage: deleteUser [username]"
	echo "getLoggedUsers to display the current logged in users. Usage: getLoggedUsers"
	echo "disableUser to disable a user to login. Usage: disableUser [username]"
	echo "gimmeFileExecutableAsRoot to show all the files owned by root and can be executed as owner SUID. Usage: gimmeFileExecutableAsRoot"
	echo "gimmeRelease to show the release of the OS. Usage: gimmeRelease"
	echo "[q]uit to quit the User Management Tool"
}

#Get all the users in the passwd file.
getuser(){
	cat /etc/passwd | cut -d ':' -f 1
}

#Add a new user to the system and create the password
addNewUser(){
	if [[ ${#userInput[@]} -ge 2 ]]; then
		useradd ${userInput[1]}
		if [[ "$?" -eq 0 ]]; then
			passwd ${userInput[1]}
			if [[ "$?" -eq 0 ]]; then
				echo "User '${userInput[1]}' have been seccessfully added."
			fi
		fi
	else
		echo "ERROR, please look at the help"
		helpUser
	fi
}

#Get all the passwords in the Shadow file
getPassword(){
	if [[ ${#userInput[@]} -eq 1 ]]; then
		cat /etc/shadow
	elif [[ ${#userInput[@]} -ge 2 ]]; then
		cat /etc/shadow | grep ${userInput[1]}
	else
		echo "ERROR, please look at the help"
		helpUser
	fi
}

#Change user password.
changeUserPassword(){
	if [[ ${#userInput[@]} -ge 2 ]]; then
		passwd ${userInput[1]}
	else
		echo "ERROR, please look at the help"
		helpUser
	fi
}

#Get details of the current user
getCurrentUser(){
	id
}

#Delete a user including their directories
delUser(){
	if [[ ${#userInput[@]} -ge 2 ]]; then
		userdel -r ${userInput[1]}
		if [[ "$?" -eq 0 ]]; then
			echo "User '${userInput[1]}' have been seccessfully deleted."
		fi
	else
		echo "ERROR, please look at the help"
		helpUser
	fi
}

#Get the logged in users using both "w" and "lastlog"
getLoggedInUsers(){
	echo "**** currently logged in users are as follow ****"
	w
	echo "***** below is all the users with their last logged in details ****"
	lastlog
}

# disable user acccount so it cannot login
disableUserAccount(){
	if [[ ${#userInput[@]} -ge 2 ]]; then
		usermod -s /sbin/nologin ${userInput[1]}
		if [[ "$?" -eq 0 ]]; then
			echo "User '${userInput[1]}' have been seccessfully disabled."
		fi
	else
		echo "ERROR, please look at the help"
		helpUser
	fi
}

#get roots files that are executable SUID
getFileExecAsRoot(){
	find / -uid 0 -perm /4000 2>/dev/null
}

#get the release of the OS
getRelease(){
	cat /etc/*release*
}

# **************** NETWORK ****************
#This functino will be the main loop for the network managment tool
#taking an input from the users.
networkCommand(){
	userInput=$@
	while [[ true ]]; do
		printf "[Network Managment]>> "
		read -a userInput
		if [[ ${#userInput[@]} -eq 0 ]]; then
			helpNetwork
			continue
		fi
		case ${userInput[0]} in
			q|quit ) break;;
			myIP ) getMyIP;;
			interface ) getInterface userInput;;
			routing ) getRoute;;
			gimmeNetworkConnections ) getNetworkDetails;;
			gimmeARP ) getARP;;
			gimmeFW ) getFirewall;;
			* ) helpNetwork;;
		esac
	done
}

#This to show the usage of the network managment tools
helpNetwork(){
	echo "myIP to show your IP(s). Usage: myIP"
	echo "interface to get the interface details. Usage: interface [optional:interface]"
	echo "routing to get the routing table. Usage: routing"
	echo "gimmeNetworkConnections to show the current network connections. Usage: gimmeNetworkConnections"
	echo "gimmeARP to show the ARP table. Usage: gimmeARP"
	echo "gimmeFW to show the firewall rules. Usage gimmeFW"
}

#To show the current IP(s)
getMyIP(){
	printf "Your IP(s) are as following: "
	hostname -I
	echo "For more details please use 'interface'"
}

#Get network details of one interface or all
getInterface(){
	if [[ ${#userInput[@]} -eq 1 ]]; then
		ifconfig -a
	elif [[ ${#userInput[@]} -ge 2 ]]; then
		ifconfig ${userInput[1]}
		echo "${userInput[1]} status as below:"
		ethtool -i ${userInput[1]}
	else
		helpNetwork
	fi
}

#Show the routing table
getRoute(){
	route -n
}

#Show current connection status
getNetworkDetails(){
	echo "*** Below is all the UDP & TCP sessions unresolved & PID ***"
	netstat -paunt
	echo "*** Below is all the interfaces ***"
	netstat -i
}

#show ARO cache unresolved
getARP(){
	arp -na
}

#show the firewall rules
getFirewall(){
	iptables -nvL
}

# **************** OTHER ****************

# runPeacfully(){
# 	iptables -I INPUT 1 -j ACCEPT
# 	interface="$(netstat -i | grep eth | cut -d ' ' -f 1)"
# 	tcpdump -XX > gotcha.log 2>/dev/null &
# }

# quit(){
# 	interface="$(netstat -i | grep eth | cut -d ' ' -f 1)"
# 	ifdown $interface 2>/dev/null &
# }

main $@

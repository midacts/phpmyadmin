#!/bin/bash
# phpMyAdmin SSL Setup
# Author: John McCarthy
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
# Date: 15th of January, 2014
# Version 1.0
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#------------------------------------------------------
######## FUNCTIONS ########
function check_phpMyAdmin()
{
	# Calls Function 'install_phpMyAdmin'
		clear
		echo -e "\e[33m=== Install phpMyAdmin ? (y/n)\e[0m"
	# Advises the user to choose apache
		echo -e '\e[30;01m-Please select the apache2 option when installing phpMyAdmin-\e[0m'
	# Read user's input to start the script
		read yesno
	# If the user types "y", the script calls the install_phpMyAdmin function
		if [ "$yesno" = "y" ]; then
			install_phpMyAdmin
	# If the user types in anything other than "y" or "n", recall the check_phpMyAdmin function
		elif [ "$yesno" != "y" ] && [ "$yesno" != "n" ]; then
			clear
			check_phpMyAdmin
			return 0
		fi
}

function install_phpMyAdmin()
{
	# Install the phpMyAdmin package
		echo
		echo -e '\e[01;34m+++ Installing the phpMyAdmin package...\e[0m'
		echo
		apt-get update
		apt-get install -y phpmyadmin
		echo
		echo -e '\e[01;37;42mphpMyAdmin was successfully installed!\e[0m'

	# Securing phpMyAdmin --Thanks Justin Ellingwood #<https://www.digitalocean.com/community/articles/how-to-set-up-ssl-certificates-with-phpmyadmin-on-an-ubuntu-12-04-vps>
	# Tells apache to look at phpmyadmin's apache.conf file
		echo
		echo -e '\e[01;34m+++ Editing the /etc/apache2/apache2.conf file...\e[0m'
	# Variable for checking the "Include /etc/phpmyadmin/apache.conf" line in the /etc/apache2/apache2.conf file
		inc_apa=$(grep -r "Include /etc/phpmyadmin/apache.conf" /etc/apache2/apache2.conf)
		if [ -n "$inc_apa" ]; then
		# If this line exists, delete it
			sed -i '/Include \/etc\/phpmyadmin\/apache.conf/d' /etc/apache2/apache2.conf
		fi
		echo '' >> /etc/apache2/apache2.conf
		echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
		echo
		echo -e '\e[01;37;42mThe /etc/apache2/apache2.conf file was successfully edited!\e[0m'

	# Edit phpMyAdmin's apache.conf
		echo
		echo -e '\e[01;34m+++ Editing the /etc/phpmyadmin/apache.conf file...\e[0m'
	# Variable for checking the "AllowOverride" line in the /etc/phpmyadmin/apache.conf file
		allow_override=$(grep -r "AllowOverride" /etc/phpmyadmin/apache.conf)
		if [ -n "$allow_override" ]; then
			sed -i '/AllowOverride/d' /etc/phpmyadmin/apache.conf
		fi
		sed -i '/index.php/{s/$/\
        AllowOverride All/}' /etc/phpmyadmin/apache.conf
		echo
		echo -e '\e[01;37;42mThe /etc/phpmyadmin/apache.conf file was successfully edited!\e[0m'
}

function check_htaccess_setup()
{
	# Calls Function 'htaccess_setup'
		echo
		echo -e "\e[33m=== Create the .htaccess and .htpasswd files for phpMyAdmin ? (y/n)\e[0m"
		echo -e "\e[01;30m- Grants credentials to access the /usr/share/phpmyadmin directory via apache2 -\e[0m"
		echo -e "\e[01;30m                      - An additional layer of security -\e[0m"
		read yesno
	# If the user types "y", the script calls the htaccess_setup function
		if [ "$yesno" = "y" ]; then
			htaccess_setup
	# If the user types in anything other than "y" or "n", recall the check_htaccess_setup function
		elif [ "$yesno" != "y" ] && [ "$yesno" != "n" ]; then
			clear
			check_htaccess_setup
			return 0
		fi
}

function htaccess_setup()
{
	# Create the phpMyAdmin .htaccess file
		echo
		echo -e '\e[01;34m+++ Creating the /usr/share/phpmyadmin/.htaccess file...\e[0m'
cat <<EOB > /usr/share/phpmyadmin/.htaccess
AuthType Basic
AuthName "phpmyadmin"
AuthUserFile /etc/phpmyadmin/.htpasswd
Require valid-user
EOB

		echo
		echo -e '\e[01;37;42mThe /usr/share/phpmyadmin/.htaccess file was successfully created!\e[0m'

	#Get the phpmyadmin username
		echo
		echo -e '\e[33mPlease type in a username to grant phpMyAdmin wed UI access to:\e[0m'
		read phpmyadmin_username

	# Create the .htpasswd file to allow users access
		echo
		echo -e '\e[01;34m+++ Adding '"$phpmyadmin_username"' to the .htpasswd file...\e[0m'
		htpasswd -c /etc/phpmyadmin/.htpasswd $phpmyadmin_username
		echo
		echo -e "\e[01;37;42m$phpmyadmin_username has been successfully added to the /etc/phpmyadmin/.htpasswd file!\e[0m"

	# Calls check_additional_users function
		check_additional_users
}

function check_additional_users()
{
	# Additional user check
		echo
		echo -e "\e[33m=== Add additional users to the phpMyAdmin .htpasswd file ? (y/n)\e[0m"
		echo -e "\e[01;30m- Only needed if you are going to use the .htaccess and .htpasswd files -\e[0m"
	# Read user's input to start the script
		read yesno
	# If the user types "y", the script calls the additional_users function
		if [ "$yesno" = "y" ]; then
			additional_users
	# If the user types in anything other than "y" or "n", recall the check_additional_users function
		elif [ "$yesno" != "y" ] && [ "$yesno" != "n" ]; then
			clear
			check_additional_users
			return 0
		fi
}

function additional_users()
{
	#Get the additional phpmyadmin usernames
		echo
		echo -e '\e[33mPlease type in a username to grant phpMyAdmin wed UI access to:\e[0m'
		read phpmyadmin_additional_username
	# Create the .htpasswd file to allow users access
		echo
		echo -e '\e[01;34m+++ Adding '"$phpmyadmin_additional_username"' to the .htpasswd file...\e[0m'
		echo
		htpasswd /etc/phpmyadmin/.htpasswd $phpmyadmin_additional_username
		echo
		echo -e "\e[01;37;42m$phpmyadmin_additional_username has been successfully added to the /etc/phpmyadmin/.htpasswd file!\e[0m"
	# Check for additional users by calling the check_additional_users funtion
		check_additional_users
}

function check_ssl()
{
	# Calls Function 'ssl'
		echo
		echo -e "\e[33m=== Configure phpMyAdmin to use SSL (HTTPS) ? (y/n)\e[0m"
		read yesno
		if [ "$yesno" = "y" ]; then
		# Variable for the name of the certificate
			cert_name=$(hostname -f)
			crt=$(grep "SSLCertificateFile /etc/apache2/ssl/$cert_name.crt" /etc/apache2/sites-available/default)
			key=$(grep "SSLCertificateKeyFile /etc/apache2/ssl/$cert_name.key" /etc/apache2/sites-available/default)
		# Checks to see if certain $crt and $key have already been added to the default apache2 site
			if [ -n "$crt" ] || [ -n "$key" ]; then
				echo
				echo -e "\e[31mYour SSL crt and key have already been added to apache's default site\e[0m"
				echo
				echo -e "\e[31m=== Proceed anyway ? (y/n) \e[0m"
				read ssl_go
				# Checks if the user really wants to proceed
					if [ "$ssl_go" = "y" ]; then
						echo
						echo -e "\e[31m===== Are you sure you are sure you want to proceed anyway ? (y/n) \e[0m"
						echo -e "\e[01;30m- Your .crt and .key files in the /etc/apache2/ssl directory will be modified -\e[0m"
						read ssl_go_rly
					# Double checks if the user really wants to proceed
						if [ "$ssl_go_rly" = "y" ]; then
						ssl
					# Makes sure they type in a y or n response
						elif [ "$ssl_go_rly" != "y" ] && [ "$ssl_go_rly" != "n" ]; then
						clear
					# If a y or n response was not receive, it recalls the check_ssl function
						check_ssl
						return 0
						fi
				# Makes sure they type in a y or n response
					elif [ "$ssl_go" != "y" ] && [ "$ssl_go" != "n" ]; then
						clear
					# If a y or n response was not receive, it recalls the check_ssl function
						check_ssl
						return 0
					fi
		else
		# If the user selects y and they pass all the previous check, the ssl function is called
			ssl
			fi

	# If the user types in anything other than "y" or "n", recall the check_ssl function
		elif [ "$yesno" != "y" ] && [ "$yesno" != "n" ]; then
			clear
			check_ssl
			return 0
		fi
}

function ssl()
{
	# Enable the ssl mod for apache
		echo
		echo -e '\e[01;34m+++ Enabling the SSL mod for apache...\e[0m'
		echo
		a2enmod ssl
		echo
		echo -e '\e[01;37;42mThe apache SSL mod has been successfully enabled!\e[0m'

	# Create the directory to store SSL Certificates in
		echo
		echo -e '\e[01;34m+++ Creating your SSL Certificates directory...\e[0m'
		echo
		mkdir /etc/apache2/ssl
		echo -e '\e[01;37;42mYour SSL certificate directory has been successfully created!\e[0m'

	# Certificate creation reminder
		echo
		echo -e '\e[01;34m+++ Creating your SSL Certificates...\e[0m'
		echo
		echo -e "\e[33mPlease set your certificate's COMMON NAME to your FQDN or your IP Address\e[0m"
		echo -e "\e[33mExample: test.example.com\e[0m"

	# Create your very own self-signed SSL certificates
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/$cert_name.key -out /etc/apache2/ssl/$cert_name.crt
		echo
		echo -e '\e[01;37;42mYour SSL certificates have been successfully created!\e[0m'

	# Set the default site to require 443 (https)
		echo
		echo -e '\e[01;34m+++ Editing your /etc/apache2/sites-available/default file...\e[0m'
		sed -i 's/80/443/g' /etc/apache2/sites-available/default

	# Remove any existing Lines containing "ServerName " in /etc/apache2/sites-available/default
		srv_name=$(grep -r "ServerName" /etc/apache2/sites-available/default)
		if [ -n "$srv_name" ]; then
		# If this line exists, delete it
			sed -i '/ServerName/d' /etc/apache2/sites-available/default
		fi

	# Variable for the name of the certificate
		cert_name=$(hostname -f)

	# Add your servername
		sed -i "/webmaster@localhost/{s/$/\n\
	ServerName $cert_name:443/}" /etc/apache2/sites-available/default

	# Variable for checking the /etc/apache2/apache2.conf file for these three lines
		ssl_on=$(grep -r "SSLEngine" /etc/apache2/sites-available/default)
		ssl_cert=$(grep -r "SSLCertificateFile" /etc/apache2/sites-available/default)
		ssl_key=$(grep -r "SSLCertificateKeyFile" /etc/apache2/sites-available/default)
		if [ -n "$ssl_on" ]; then
		# If this line exists, delete it
			sed -i '/SSLEngine/d' /etc/apache2/sites-available/default
		fi
		if [ -n "$ssl_cert" ]; then
		# If this line exists, delete it
			sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default
		fi
		if [ -n "$ssl_key" ]; then
		# If this line exists, delete it
			sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default
		fi

	# Get the number of lines in the default file
		num=$(wc -l /etc/apache2/sites-available/default | awk '{print $1}')

	# Add the SSL enabling lines to the default site file
		sed -i ''"$num"'i\        SSLEngine on\
	SSLCertificateFile /etc/apache2/ssl/'"$cert_name"'.crt\
	SSLCertificateKeyFile /etc/apache2/ssl/'"$cert_name"'.key' /etc/apache2/sites-available/default
		echo
		echo -e '\e[01;37;42mYour /etc/apache2/sites-available/default file has been successfully edited!\e[0m'

	# Force phpMyAdmin to use SSL
		echo
		echo -e '\e[01;34m+++ Editing your /etc/phpmyadmin/config.inc.php file...\e[0m'
		php_cfg=$(grep -Fr "\$cfg['ForceSSL'] = true;" /etc/phpmyadmin/config.inc.php)
		if [ -n "#php_cfg" ]; then
			sed -i "/$cfg\['ForceSSL'\]/d" /etc/phpmyadmin/config.inc.php
		fi
		echo "\$cfg['ForceSSL'] = true;" >> /etc/phpmyadmin/config.inc.php
		echo
		echo -e '\e[01;37;42mYour /etc/phpmyadmin/config.inc.php file has been successfully edited!\e[0m'

	# Enable the SSL Changes on the default site
		echo
		echo -e "\e[01;34m+++ Enabling these changes on apache's default site...\e[0m"
		echo
		a2ensite default
		echo
		echo -e '\e[01;37;42mThese changes have been successfully added to your default apache site!\e[0m'

	# Restart the apache service
		echo
		echo -e "\e[01;34m+++ Restarting your apache service...\e[0m"
		echo
		service apache2 restart
		echo
		echo -e '\e[01;37;42mYour apache service has been successfully restarted!\e[0m'
		clear
}

#This Function is Used to Call its Corresponding Function
function doAll()
{
	# Calls function check_install_phpMyAdmin
		check_phpMyAdmin

	# Calls Function 'htaccess_setup'
		check_htaccess_setup

	# Calls Function 'ssl'
		check_ssl

	# End of Script Congratulations, Farewell and Additional Information
		FARE=$(cat << 'EOD'


	   \e[01;37;42mWell done! You have successfully setup phpMyAdmin with SSL!\e[0m

	    \e[01;37;42mProceed to your phpMyAdmin web UI, https://fqdn/phpmyadmin\e[0m
  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m

			    \e[01;37m########################\e[0m
			    \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
			    \e[01;37m########################\e[0m
EOD
)

# Calls the End of Script variable
	echo -e "$FARE"
	echo
	echo
	exit 0
}

# Check privileges
[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
	echo
	echo
	echo -e '               \e[01;37;42mWelcome to Midacts Mystery'\''s phpMyAdmin SSL Setup!\e[0m'
	echo
	echo
	case "$go" in
		* )
			doAll ;;
	esac

exit 0

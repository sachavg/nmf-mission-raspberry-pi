#!/bin/sh
cd ${0%/*}

###############################################################################
# Variables:
user_nmf_admin="nmf-admin"
supervisor_mainclass="esa.mo.nmf.provider.NanoSatMOSupervisorRaspberryPiImpl"
start_script_name="start_supervisor.sh"
dir_nmf="/nanosat-mo-framework/"
dir_home="/home/"
###############################################################################

# The script must be run as root
if [ $(whoami) != 'root' ]; then
	echo "The current user is: $(whoami)"
	echo "Please run this script as root or with sudo!"
	exit 1
fi

# Check if the NMF Admin User exists
if id -u "$user_nmf_admin" >/dev/null 2>&1; then
    echo "The user $user_nmf_admin already exists! Let's delete it and create again..."
	deluser $user_nmf_admin
	# todo: remove home
	RESULT=$?

	if [ $RESULT -eq 0 ]; then
	  echo "The user $user_nmf_admin was successfully deleted!"
	else
	  echo "ERROR!!! The user $user_nmf_admin could not be deleted!"
	  echo "Please close any open sessions with the $user_nmf_admin user and try again!"
	  exit 1
	fi
fi

# Add the NMF Admin User and set password
#useradd $user_nmf_admin -m -s /bin/bash --user-group
addgroup -S $user_nmf_admin
adduser -S -s /bin/sh -G $user_nmf_admin $user_nmf_admin



# Function to create a directory with: owner + group + permissions
create_dir(){
    permissions=$1
    owner=$2
    group=$3
    directory=$4
   
	mkdir $directory
	chown -R $owner:$group $directory
	chmod -R $permissions $directory
}

# Create the start script for the nmf: start_supervisor.sh
cat > $start_script_name <<EOF
#!/bin/sh
cd \${0%/*}
java -classpath "libs/*" $supervisor_mainclass
EOF

chown -R $user_nmf_admin:$user_nmf_admin .
chmod 775 .
chown $user_nmf_admin:$user_nmf_admin $start_script_name
chmod 700 $start_script_name

create_dir 775 $user_nmf_admin $user_nmf_admin apps
create_dir 775 $user_nmf_admin $user_nmf_admin libs
create_dir 700 $user_nmf_admin $user_nmf_admin packages
create_dir 770 $user_nmf_admin $user_nmf_admin public_square
create_dir 700 $user_nmf_admin $user_nmf_admin nmf_updates



echo "Success! The NanoSat MO Framework was installed!"






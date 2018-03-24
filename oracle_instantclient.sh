#!/bin/bash
################################################
# Installation module for Oracle Instant Client
################################################

MACHINE_TYPE=`uname -m`

oracle_files_dir="/opt/oracle/instantclient_12_2"

oracle_path=$(cat /etc/environment | grep $oracle_files_dir)

if [ ! "$oracle_path" ]; then
	cp /etc/environment /etc/environment.old
	sed -i "s|PATH=\"|PATH=\"$oracle_files_dir:|" /etc/environment

	paths=("
		SQLPATH=\"$oracle_files_dir\"
		TNS_ADMIN=\"$oracle_files_dir\"
		LD_LIBRARY_PATH=\"$oracle_files_dir\"
		ORACLE_HOME=\"$oracle_files_dir\"
		")

	for i in $paths
	do
			if [ ! $(grep "$i" /etc/environment) ]; then
				echo $i >> /etc/environment
			fi
	done
fi

if [ ! -d "/opt/oracle/" ]; then
	mkdir /opt/oracle

	git clone https://github.com/Lexus89/oracle_instantclient.git /opt/oracle

	if [ $MACHINE_TYPE == 'x86_64' ] ; then
		unzip /opt/oracle/x64/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /opt/oracle/
		unzip /opt/oracle/x64/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /opt/oracle/
		unzip /opt/oracle/x64/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle/
	else
		unzip /opt/oracle/x86/instantclient-basic-linux-12.2.0.1.0.zip -d /opt/oracle/
		unzip /opt/oracle/x86/instantclient-sqlplus-linux-12.2.0.1.0.zip -d /opt/oracle/
		unzip /opt/oracle/x86/instantclient-sdk-linux-12.2.0.1.0.zip -d /opt/oracle/
	fi

	ln -sf $oracle_files_dir/libclntsh.so.12.1 $oracle_files_dir/libclntsh.so
	ln -sf $oracle_files_dir/libclntshcore.so.12.1 $oracle_files_dir/libclntshcore.so
	ln -sf $oracle_files_dir/libocci.so.12.1 $oracle_files_dir/libocci.so
fi

if [ ! -e "/etc/ld.so.conf.d/oracle-instantclient" ]; then
	echo $oracle_files_dir > /etc/ld.so.conf.d/oracle-instantclient
	chmod o+r /etc/ld.so.conf.d/oracle-instantclient
fi

source /etc/environment
export LD_LIBRARY_PATH
ldconfig

gem install ruby-oci8
apt-get install --upgrade -y python-pip libaio-dev
pip install --upgrade cx_Oracle

echo "Finished installing, changes will take effect after re-login!"
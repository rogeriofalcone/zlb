#!/bin/bash

IFS='.' read -a DEBVERSION < /etc/debian_version
if [ $DEBVERSION != 9 ]; then
	echo "Zevenet Load Balancer installation only available for Debian 9 Stretch"
	exit 1
fi

if [ "`grep dhcp /etc/network/interfaces`" != "" ]; then
	echo "Zevenet Load Balancer doesn't support DHCP network configurations yet. Please configure a static IP address in the file /etc/network/interfaces."
	exit 1
fi

INSTALL_DIR="/usr/local/zevenet"
REPO_DIR=`dirname $0`

if [ "${REPO_DIR}" == '.' ]; then
	REPO_DIR=`pwd`
fi

# Configure packages repository
cat > /etc/apt/sources.list.d/zevenet.list <<EOF
deb http://repo.zevenet.com/ce/v5 stretch main
EOF

echo -n "* Fetching Zevenet gpg key: "
wget -q -O - http://repo.zevenet.com/zevenet.com.gpg.key | apt-key add -

echo "* Updating packages database"
apt-get update || exit 1


# Install dependencies
echo "* Installing dependencies"
if [ "${REPO_DIR}" != "${INSTALL_DIR}" ]; then
	ln -sf ${REPO_DIR} ${INSTALL_DIR}
fi
DEPENDENCIES=`perl -a -E 'if (s/^Depends: //){ s/\,//g; print }' ${REPO_DIR}/DEBIAN/control`
apt-get install ${DEPENDENCIES} zevenet-gui-ce || exit 1


# Install zevenet
echo "* Deploying Zevenet"
cp -f ${INSTALL_DIR}/etc/init.d/zevenet /etc/init.d/zevenet

if [ ! -e /etc/cron.d/zevenet ]; then
	cp -f  ${INSTALL_DIR}/etc/cron.d/zevenet /etc/cron.d/zevenet
fi

if [ ! -e /usr/share/perl5/Zevenet ]; then
	ln -sf ${INSTALL_DIR}/lib/Zevenet/ /usr/share/perl5/Zevenet
fi

if [ ! -e /usr/share/perl5/Zevenet.pm ]; then
	ln -sf ${INSTALL_DIR}/lib/Zevenet.pm /usr/share/perl5/Zevenet.pm
fi


# Do prerequisites and start zevenet service
echo "* Setting up Zevenet"
${REPO_DIR}/DEBIAN/postinst configure

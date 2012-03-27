#/bin/sh

SYSCONFDIR=/etc/ssh
SUFFIX=

rm ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}
rm ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}.pub

echo "Generating ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}"
ssh-keygen -t rsa -f ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX} -N ''

chown root:root ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}
chmod 600 ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}

chown root:root ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}.pub
chmod 644 ${SYSCONFDIR}/ssh_host_rsa_key${SUFFIX}.pub

rm ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}
rm ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}.pub

echo "Generating ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}"
ssh-keygen -t dsa -f ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX} -N ''

chown root:root ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}
chmod 600 ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}

chown root:root ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}.pub
chmod 644 ${SYSCONFDIR}/ssh_host_dsa_key${SUFFIX}.pub

# BARA PERMANENT SCRIPTS
# 
# A script to setup initial CentOS Ceph Node
#
# One line install command:
# Syntax: curl https://cent-ceph.scripts.barajs.dev | bash -s <ceph_username> <ceph_password>
# Example: curl https://cent-ceph.scripts.barajs.dev | bash -s centeph "^MySecret*Password$"
#
# Have fun with Ceph!

#! /bin/bash

print_section() {
  echo "=====================================================";
  echo $1;
  echo "=====================================================";
  echo "";
}

print_step() {
  echo "=> ${1}";
  echo "";
}

param_user=$1
username="centeph"

# CREATE CEPH USER
print_section "PREPARING CEPH USER";
if [ $(grep -c '^username:' /etc/passwd) -eq 0 ]; then
  useradd $username
  usermod -G wheel cent
  usermod --password "^Cent*CEPH$" $username
  print_step "Added user: ${username} with password '^Cent*CEPH$'";
else
  print_step "Skip user creation: ${username} existed!"
fi

# TURN OFF SUDO PASSWORD
print_section "TURN OF CEPH USER PASSWORD";
echo -e 'Defaults:'$username' !requiretty\n'$centeph' ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/ceph
print_step "Turned off ${username} sudo password!"

# CHANGE PERMISSION ON CEPH
print_section "CONFIGURE USER PERMISSION";
chmod 440 /etc/sudoers.d/ceph
print_step "CHMOD 440 for /etc/sudoers.d/ceph"

# INSTALL DEPENDENCIES
print_section "CONFIGURE REPOSITORY";
print_step "Installing Ceph Repositories..."
yum -y install epel-release yum-plugin-priorities \
https://download.ceph.com/rpm-luminous/el7/noarch/ceph-release-1-1.el7.noarch.rpm \
> /dev/null
sed -i -e "s/enabled=1/enabled=1\npriority=1/g" /etc/yum.repos.d/ceph.repo
print_step "Installed Ceph Repository Success!"

# CONFIG FIREWALL
firewall-cmd --add-service=ssh --permanent
print_step "Enabled Firewall service: SSH"
firewall-cmd --add-port=6789/tcp --permanent
print_step "Enabled Firewall service: Ceph Monitor (6789/tcp)"
firewall-cmd --add-port=6800-7100/tcp --permanent
print_step "Enabled Firewall service: Ceph OSDs (6800-7100/tcp)"

print_step "All initial Ceph tools installed successfully!"

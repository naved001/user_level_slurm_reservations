#!bash
#
# slurm_sever_provision.sh - SLURM MOC Server VM Provisioning Script
#
# Run on the Slurm compute nodes
#
# Notes
#   Assumes Ubuntu environment (16.04 LTS, YMMV)
#   Run as root on compute server nodes, NOT on controller
#       Controller is provisioned separately
#   NFS kernel server must be provisioned on the controller
#      /slurm is the shared directory, exported via NFS

set -x

echo "10.0.0.8 controller" >> /etc/hosts
echo "127.0.0.1 `hostname`" >> /etc/hosts

# Update the server node addresses as appropriate

# echo "10.0.0.7 server1" >> /etc/hosts
# echo "10.0.0.10 server2" >> /etc/hosts
# echo "10.0.0.15 server3" >> /etc/hosts
# echo "10.0.0.16 server4" >> /etc/hosts
# echo "10.0.0.11 server5" >> /etc/hosts
# echo "10.0.0.12 server6" >> /etc/hosts

apt-get -y install make
apt-get -y install gcc
apt-get -y install python2.7
ln -s /usr/bin/python2.7 /usr/bin/python
apt-get -y install emacs
apt-get -y install nfs-common
apg-get -y install munge
echo "massopencloud" > /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

cd 
mkdir packages
cd packages

wget https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.27.tar.bz2
tar xvf libgpg-error-1.27.tar.bz2
cd libgpg-error-1.27
./configure
make install
cd 
cd packages

wget https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.7.8.tar.bz2
tar xvf libgcrypt-1.7.8.tar.bz2
cd libgcrypt-1.7.8
./configure
make install
cd 
cd packages

wget https://github.com/SchedMD/slurm/archive/slurm-17-02-6-1.tar.gz
tar xvf slurm-17-02-6-1.tar.gz
cd slurm-slurm-17-02-6-1
./configure
make install

cd 
cd packages

# Munge again

/etc/init.d/munge start

# NFS

mkdir -p /local/slurm
chmod 777 /local/slurm
mount controller:/slurm /local/slurm
echo "controller:/slurm /local/slurm nfs rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab

# Slurm Daemon

systemctl enable slurmd


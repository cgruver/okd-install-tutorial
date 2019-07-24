auth --enableshadow --passalgo=sha512
install
url --url=http://ocp-controller01.your.domain.com/centos7.5/
text
firstboot --enable
ignoredisk --only-use=sda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
rootpw --iscrypted <Your Encrypted String Here>
services --enabled="chronyd"
timezone America/New_York --isUtc
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
clearpart --all 
zerombr
part /boot --fstype="xfs" --ondisk=sda --size=1024
part pv.157 --fstype="lvmpv" --ondisk=sda --size=1024 --grow --maxsize=2000000
volgroup centos --pesize=4096 pv.157
logvol swap  --fstype="swap" --size=2047 --name=swap --vgname=centos
logvol /  --fstype="xfs" --grow --maxsize=2000000 --size=1024 --name=root --vgname=centos

%packages
@^minimal
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

eula --agreed

%post
curl -o /root/firstboot.sh http://ocp-controller01.your.domain.com/firstboot/appnode.fb
chmod 750 /root/firstboot.sh
echo "@reboot root /bin/bash /root/firstboot.sh" >> /etc/crontab
mv /etc/sysconfig/selinux /root/selinux
cat <<EOF > /etc/sysconfig/selinux
SELINUX=disabled
SELINUXTYPE=targeted
EOF
%end

reboot

#remove xdebug 
sudo php5dismod xdebug
sudo service apache2 reload

#To up ports for batch processing
cat /etc/sysctl.d/net.ipv4.ip_local_port_range.conf
echo 15000 64000 > /proc/sys/net/ipv4/ip_local_port_range
sysctl -w net.ipv4.ip_local_port_range="15000 64000"


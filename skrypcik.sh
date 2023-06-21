#!/usr/bin/env sh

# ============================================================================ #
#                              Konfiguracja ręczna
# ============================================================================ #
# Na routerze trzeba ustawić ręcznie ip dla danych sieci wewnętrznych.
# Będzie to to samo co w SIEC_A_IP_ROUTER i SIEC_B_IP_ROUTER
# z maskami SIEC_A_MASKA i SIEC_B_MASKA

# Przed uruchomiemiem skryptu trzeba umożliwić jego wykonywanie
# chmod +x router.sh

# ============================================================================ #
#                                 Konfiguracja
# ============================================================================ #

# Siec domowa
SIEC_DOMOWA_IP=192.168.0.0
SIEC_DOMOWA_MASKA=255.255.255.0
ROUTER_KARTA_DOMOWA=ens18

# Siec A z DHCP
SIEC_A_IP=10.0.1.0
SIEC_A_MASKA=255.255.255.0
SIEC_A_IP_ROUTER=10.0.1.1
SIEC_A_DHCP_START=10.0.1.100
SIEC_A_DHCP_STOP=10.0.1.200

# Siec B z adresami statycznymi
SIEC_B_IP=10.0.2.0
SIEC_B_MASKA=255.255.255.0
SIEC_B_IP_ROUTER=10.0.2.1
MASZYNA_B_MAC=86:7E:C0:F2:B4:81
MASZYNA_B_STATIC_IP=10.0.2.10

# ============================================================================ #
# ============================================================================ #

# Na wszelki wypadek
sudo apt update && apt upgrade -y

# DHCP i STATIC
sudo apt install isc-dhcp-server -y

echo "
subnet $SIEC_A_IP netmask $SIEC_A_MASKA {
       range $SIEC_A_DHCP_START $SIEC_A_DHCP_STOP;
       option domain-name-servers 8.8.8.8;
       option routers $SIEC_A_IP_ROUTER;
}

subnet $SIEC_DOMOWA_IP netmask $SIEC_DOMOWA_MASKA {
}

subnet $SIEC_B_IP netmask $SIEC_B_MASKA {
}

host SCR-A {
     hardware ethernet $MASZYNA_B_MAC;
     fixed-address $MASZYNA_B_STATIC_IP;
     option domain-name-servers 8.8.8.8;
     option routers $SIEC_B_IP_ROUTER;
}
" | sudo tee -a /etc/dhcp/dhcpd.conf

# SSH
sudo apt install openssh-server -y

# FIREWALL
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from $MASZYNA_B_STATIC_IP to any port 22
sudo ufw allow 80
sudo ufw enable

# MASQUERADE
sudo sed -i -e "s/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/" /etc/default/ufw

echo "net/ipv4/ip_forward=1" | sudo cat - /etc/ufw/sysctl.conf > temp && sudo mv temp /etc/ufw/sysctl.conf
echo "
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s $SIEC_A_IP/24 -o $ROUTER_KARTA_DOMOWA -j MASQUERADE
-A POSTROUTING -s $SIEC_B_IP/24 -o $ROUTER_KARTA_DOMOWA -j MASQUERADE
COMMIT

" | sudo cat - /etc/ufw/before.rules > temp && sudo mv temp /etc/ufw/before.rules

# SERWER WWW
sudo apt install apache2 -y
echo 'Moja strona www' | sudo tee /var/www/html/index.html

sudo reboot

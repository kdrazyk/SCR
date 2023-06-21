


# Instalacja i przygotowanie systemu

System: Ubuntu 22.04.2 LTS
<https://ubuntu.com/download/desktop/thank-you?version=22.04.2&architecture=amd64>

Najpierw tworzymy router.

**Opcje instalacji**

-   Minimal installation
-   Download updates while installing Ubuntu

**Po instalacji**

-   Przeklikać wprowadzenie
-   Wyskoczy Software Updater - *Install Now*, a potem *Restart Now*
-   Dla pewności: `sudo apt update && sudo apt upgrade -y`
-   Wyłączamy maszynę: `sudo shutdown now`

**Klonowanie**

-   Tworzymy trzy klony maszyny (A, B i zapas na wszelki wypadek)
-   Podłączamy maszyny do odpowiednich sieci
-   Zmieniamy nazwy maszyn A i B
    `sudo hostnamectl set-hostname nowa-nazwa`
    `sudo nano /etc/hosts` - podmieniamy nazwę w drugiej linijce, Ctrl-O zapisz i Ctrl-X wyjdź

Teraz mamy trzy wstępnie ustawione maszyny. Router powinien być podłączony do sieci komputera i wewnętrznej. Maszny A i B tylko do wewnętrznej. Z routera powinien być dostęp do internetu (można sprawdzić w przeglądarce lub `ping wp.pl` powinien nam dać odpowiedzi).


# Konfiguracja DHCP i STATIC

Otwieramy terminal na routerze.

    sudo apt install isc-dhcp-server -y
    sudo nano /etc/dhcp/dhcpd.conf
    
    # Na samym dole pliku:
    # subnet 192.168.10.0 netmask 255.255.255.0 {
    #   range 192.168.10.100 192.168.10.200;
    #   option domain-name-servers 192.168.10.1 8.8.8.8;
    #   option routers 192.168.10.1;
    # }
    
    # subnet 192.168.0.0 netmask 255.255.255.0 {
    # }
    
    # host SCR-A {
    #         hardware ethernet BA:09:C4:5C:0F:58;
    #         fixed-address 192.168.10.50;
    #         option domain-name-servers 192.168.10.1, 8.8.8.8;
    #         option routers 192.168.10.1;
    # }

Teraz otwieramy ustawienia -> Network -> trybik przy sieci wewnętrznej -> zakładka IPv4.
Wybieramy opcję manual, ustawiamy *Address* na 192.168.10.1 i *Netmask* na 255.255.255.0.
Restartujemy router, A i B.

Po restarcie maszyny powinny być w stanie się nawzajem pingować. Ich adresy możemy sprawdzić używając `ifconfig`, `ip a`, albo w ustawieniach (zakładka Details).


# Konfiguracja SSH

    sudo apt install openssh-server -y

Teraz powinniśmy móc zalogować się na router z A i B, ponieważ firewall jeszcze nie działa.

    # z A lub B
    ssh 192.168.10.1

Wracamy na router by ustawić firewall.

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow from 192.168.10.50 to any port 22
    sudo ufw allow 80
    sudo ufw enable

Teraz tylko maszyna o wybranym IP może się połączyć po SSH. Port 80 jest dla strony WWW.
Możemy dokończyć konfigurację SSH dodając logowanie kluczem.

    # komputer A
    ssh-keygen
    # klikamy enter kilka razy
    ssh-copy-id 192.168.10.1
    # logujemy się
    # i powinno od teraz działać logowanie bez hasła
    ssh 192.168.10.1


# MASQUERADE

    # router
    sudo nano /etc/default/ufw
    # zmieniamy
    # DEFAULT_FORWARD_POLICY="DROP"
    # na
    # DEFAULT_FORWARD_POLICY="ACCEPT"
    
    sudo nano /etc/ufw/sysctl.conf
    # odkomentowujemy linijkę "net/ipv4/ip_forward=1"
    
    sudo nano /etc/ufw/before.rules
    # dodajemy na górze pliku:
    # *nat
    # :POSTROUTING ACCEPT [0:0]
    # -A POSTROUTING -s 192.168.10.0/24 -o ens19 -j MASQUERADE
    # COMMIT
    
    sudo ufw disable && sudo ufw enable

Teraz maszyny A i B powinny mieć dostęp do internetu.


# Serwer WWW

    sudo apt install apache2 -y
    cd /var/www/html
    sudo rm index.html
    sudo nano index.html
    # wpisujemy jakąś testową treść strony

Teraz z komputerów A i B powinniśmy móc wejść na tą stronę wpisując adres routera.


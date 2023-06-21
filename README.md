


# Jak rozwiązać problem z SCR&rsquo;ami w 15 min :)

Cały proces składa się z trzech kroków:

1.  przygotowujemy pierwszą maszynę wirtualną, robimy kopie i ustawiamy karty sieciowe w virtual boxie
2.  na routerze ustawiamy ręcznie kilka rzeczy w ustawieniach
3.  wpisujemy swoje wartości w `skrypcik.sh` i uruchamiamy go


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

-   Tworzymy dwa klony maszyny (A i B)
-   Podłączamy maszyny do odpowiednich sieci

Teraz mamy trzy wstępnie ustawione maszyny.
Router powinien być podłączony do sieci komputera i dwóch wewnętrznych.
Maszny A i B tylko do swojej wewnętrznej.
Z routera powinien być dostęp do internetu (można sprawdzić w przeglądarce lub `ping wp.pl` powinien nam dać odpowiedzi).


# Ręczne zmiany w ustawieniach

Wchodzimy w ustawienia -> Networking -> trybik przy karcie sieciowej od pierwszej sieci wewnętrznej -> zakładka IPv4

Ustawiamy na manual, wpisujemy IP routera w sieci A, wpisujemy maskę `255.255.255.0` i zamykamy.
Jeśli nasza sieć ma mieć IP `10.0.1.0`, to router może mieć np. `10.0.1.1`.

To samo trzeba zrobić dla karty od sieci B.


# Skrypcik

Otwieramy `skrypcik.sh` przy pomocy ulubionego edytora tekstu.
Na początku pliku jest sekcja konfiguracyjna.
Domyślnie wpisane są przykładowe wartości, ale pewnie większość trzeba będzie zmienić.

    # Siec domowa
    SIEC_DOMOWA_IP=192.168.0.0      # adres sieci, z której jest dostęp do internetu
    SIEC_DOMOWA_MASKA=255.255.255.0 # maska sieci, z której jest dostęp do internetu
    ROUTER_KARTA_DOMOWA=ens18       # nazwa karty sieciowej, z której jest dostęp do internetu (można sprawdzić w ustawieniach, albo poleceniem ip a)
    
    # Siec A z DHCP
    SIEC_A_IP=10.0.1.0              # adres sieci A
    SIEC_A_MASKA=255.255.255.0      # maska sieci A
    SIEC_A_IP_ROUTER=10.0.1.1       # adres routera w sieci A (ten sam, który był wpisany w ustawieniach)
    SIEC_A_DHCP_START=10.0.1.100    # początek zakresu dhcp
    SIEC_A_DHCP_STOP=10.0.1.200     # koniec zakresu dhcp
    
    # Siec B z adresami statycznymi
    SIEC_B_IP=10.0.2.0              # adres sieci B
    SIEC_B_MASKA=255.255.255.0      # maska sieci B
    SIEC_B_IP_ROUTER=10.0.2.1       # adres routera w sieci B (ten sam, który był wpisany w ustawieniach)
    MASZYNA_B_MAC=86:7E:C0:F2:B4:81 # adres MAC karty sieciowej komputera B (można sprawdzić w ustawieniach, albo poleceniem ip a)
    MASZYNA_B_STATIC_IP=10.0.2.10   # adres jaki wybieramy dla komputera B

Po wpisaniu swoich wartości zapisujemy plik.
Zanim będzie można go uruchomić trzeba jeszcze sprawić, żeby był wykonywalny:

`chmod +x skrypcik.sh`

I można uruchomić:

`./skrypcik.sh`

Po zakończeniu instalacji maszyna sama się zrestartuje i wszystko powinno działać.
Domyślnie logowanie po SSH możliwe jest tylko z komputera B.
Pewnie warto też zmienić stronę na jakąś ciekawszą (`/var/www/html/index.html`).
Jeśli coś nie działa, to na 99% jest błąd w konfiguracji, bo skrypt był już sprawdzany kilka razy.


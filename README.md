Muhammad Rizky Utomo - Dibimbing Batch 4 Cybersecurity  
Day Automation - Automation Recon with Bash

# Recon Automation Using Bash

## Deskripsi Proyek

Proyek ini membuat sebuah bash script `recon-auto.sh` yang melakukan enumerasi subdirectory dari daftar domain yang diberikan dalam sebuah file `domains.txt` dan memeriksa subdomain yang aktif.

Untuk melakukan enumerasi subdirectory, kreator menggunakan tool [Subfinder](https://github.com/projectdiscovery/subfinder) serta [Anew](https://github.com/tomnomnom/anew) untuk menghilangkan duplikasi subdomain. Selanjutnya, kreator menggunakan httpx untuk melihat host-host yang live dari daftar domain tersebut. Daftar semua subdomain `all-subdomaindan.txt` dan daftar subdomain yang live `live.txt` disimpan dalam file terpisah.

Tool ini juga menyediakan fitur logging selama berjalan yang dilengkapi dengan timestamp. Log progres disimpan dalam `progress.log`, sedangkan log kesalahan saat berjalannya tool disimpan dalam `errors.log`.

## Setup Environment

Environment yang digunakan dalam proyek ini adalah sistem operasi Kali Linux. Berikut adalah petunjuk instalasi tool-tool yang perlu digunakan.

### Go

```sh
# Donwload latest version of Go
wget https://go.dev/dl/go1.25.3.linux-amd64.tar.gz

# Install by extracting to /usr/local
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.25.3.linux-amd64.tar.gz

# Add path to ./zshrc
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc 
echo 'export GOPATH=~/go' >> ~/.zshrc 
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.zshrc
source ~/.zshrc

# Check Go version
go version
```

### Subfinder, httpx, Nuclei

```sh
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

### Directory Structure

```
recon-automation-rizky/
├── input/
│   └── domains.txt          # Minimal 5 domain
├── output/
│   ├── all-subdomains.txt
│   └── live.txt             # Hasil akhir: live hosts
├── scripts/
│   └── recon-auto.sh        # Script utama (executable)
├── logs/
│   ├── progress.log
│   └── errors.log
└── README.md                # Dokumentasi lengkap
```

## Script Execution

Masuk ke directory tempat script dibuat, dalam hal ini `recon-automation-rizky/scripts`. Kemudian, jalankan perintah berikut:

```sh
./recon-auto.sh
```

## Input & Output Example

Misal, input yang diberikan dalam `domains.txt` adalah sebagai berikut.

```
dibimbing.id
```

Output yang dihasilkan dalam `all-subdomaindan.txt` adalah sebagai berikut (di-cut agar tidak terlalu panjang).

```
bootcamp-v2.dibimbing.id
hiring-partner.do.dibimbing.id
travel-journal-api-bootcamp.do.dibimbing.id
elk.do.dibimbing.id
metabase.do.dibimbing.id
jobs.do.dibimbing.id
bimby.dibimbing.id
bootcamp.dibimbing.id
new-metabase.dibimbing.id
product-show-api-bootcamp.do.dibimbing.id
sport-reservation-api-bootcamp.do.dibimbing.id
ghost.do.dibimbing.id
partner.dibimbing.id
...
```

Sementara itu, output yang dihasilkan dalam `live.txt` adalah sebagai berikut (di-cut agar tidak terlalu panjang). Selain dari URL, tampak status code dan page title.

```
https://alpha.do.dibimbing.id [504]
https://api-bootcamp.do.dibimbing.id [404] [Error]
https://code.dibimbing.id [200] [Dibimbing Execute]
https://code.do.dibimbing.id [200] [Dibimbing Execute]
http://grafana.do.dibimbing.id [301,302,200] [Grafana]
http://admin.do.dibimbing.id [308,404]
...
```

## Code Explanation

Inisiasi variabel directory tiap file. `TMP_SUBS` adalah file temporary yang dibuat sementara untuk menampung hasil awal Subfinder sebelum deduplikasi, kemudian dihapus.

<img width="449" height="213" alt="image" src="https://github.com/user-attachments/assets/220364a9-e504-419a-a76b-ad702c2553db" />

Function-function yang menjalankan timestamp dan logging.

<img width="437" height="184" alt="image" src="https://github.com/user-attachments/assets/93bf1c8d-a6ae-4202-80e4-90c23e6323cd" />

Subfinder melakukan enumerasi untuk tiap domain yang ada dalam `domains.txt`. Hasil akan disimpan dalam `tmp_subs.txt` yang telah dibuat, sedangkan output error disimpan dalam `errors.log`.

<img width="451" height="277" alt="image" src="https://github.com/user-attachments/assets/8478739f-ac6b-4e05-9fdf-61fb2dd91cba" />

Command `anew` melakukan deduplikasi dari temuan yang disimpan dalam `tmp_subs.txt` dan menyimpannya dalam `all-subdomains.txt`. Output error disimpan dalam `errors.log`.

<img width="531" height="110" alt="image" src="https://github.com/user-attachments/assets/b184e71f-cb96-4807-85e1-6b0d31a10aed" />

Command `httpx` melakukan filtering untuk menemukan subdomain mana yang live dari `all-subdomains.txt` dan menyimpannya dalam `live.txt`. Note bahwa dalam script, `httpx` diberikan flag `-no-color` untuk mencegah reproduksi warna karena hasil text yang disimpan dalam file akan "tercemar" dengan kode warna ANSI jika tidak ada flag tersebut.

<img width="676" height="108" alt="image" src="https://github.com/user-attachments/assets/f4bd5372-19b0-4dfa-9e28-fa60cf108f2a" />

Output terakhir yang diberikan dalam terminal berupa jumlah subdomain unik dan jumlah live hosts.

<img width="387" height="220" alt="image" src="https://github.com/user-attachments/assets/9afc040b-a368-4612-9218-f663c2fbb81f" />

## Screenshots

### Terminal Output

<img width="1013" height="445" alt="image" src="https://github.com/user-attachments/assets/b0780afa-a653-4662-986e-0c218c5262d5" />

### live.txt File

<img width="1049" height="1021" alt="image" src="https://github.com/user-attachments/assets/2d5afaa0-6e0a-46d7-8d10-f06a6cb20daf" />


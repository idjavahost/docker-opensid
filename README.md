# OpenSID :heart: Docker

[![Build Status](https://img.shields.io/badge/Build_Status-success-green.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/idjavahost/opensid/)
[![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/idjavahost/opensid/latest.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/idjavahost/opensid/) [![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/idjavahost/opensid/latest.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/idjavahost/opensid/)

Docker image & stack untuk memudahkan membuat website OpenSID di dalam Docker Container.

**Saat ini masih dalam beta testing, tidak di peruntukkan digunakan di production server**

---

##### Apa itu OpenSID?

Sistem Informasi Desa (SID) yang sengaja dibuat terbuka agar dapat dikembangkan secara bersama-sama oleh komunitas peduli SID.
Selengkapnya di: [OpenSID/OpenSID](https://github.com/OpenSID/OpenSID)

##### Apa itu Docker?

Selengkapnya di: [docker.com](https://www.docker.com/why-docker)

### Features

* Base OS dengan Alpine Linux 3.8 lebih ringan dan cepat
* Terinstall PHP 5.6 support MySQL 5.x dan Redis Server
* Sudah termasuk PHP & Nginx dengan MySQL di container terpisah
* Nginx cache via fastcgi dan opCache otomatis aktif
* Build dan download otomatis versi terbaru OpenSID
* Environment variable untuk parameter install dan config OpenSID
* SSH login ke container dengan Public Key atau password
* Custom OpenSID admin username dan password
* Supervisor untuk managemen proses


### Quick Install

```
$ curl -LO https://raw.githubusercontent.com/idjavahost/docker-opensid/master/docker-compose.yml
$ docker-compose up
```

Untuk mencobanya langsung, bisa clone repository ini lalu build sendiri image nya di local anda. Atau dengan menggunakan `docker-compose.yml` yang telah di sediakan disini. Dengan cara sebagai berikut:

* Buat satu direktori di server docker host anda, misal `/root/opensid`
* Unduh file `docker-compose.yml` dan masukkan ke direktori tadi
* Sesuaikan environment yang ada di `services > opensid > environment`
* Lalu jalankan perintah `docker-compose up` di dalam direktori

### Environment

**Catatan:** Environment dengan nilai default kosong (-) adalah wajib didefinisikan pada container.


| Nama | Default  | Kategori | Fungsi         |
|------|----------|----------|----------------|
| `OPENSID_VERSION` | `latest` | System | Digunakan untuk referensi versi OpenSID yang ingin digunakan. Gunakan ```latest``` untuk mengunduh versi paling terbaru OpenSID yang ada di github. |
| `USERNAME` | `desa` | System  | Digunakan untuk membuat user linux yang digunakan juga pada saat login SSH, user permission PHP & Nginx dan permission seluruh isi direktori OpenSID |
| `USERGROUP`  | `desa` | System | Group pada linux group yang sama fungsinya dengan `USERNAME` |
| `HOME` | `/var/www` | System | Direktori home untuk ```USERNAME``` dan ```USERGROUP``` dan untuk base folder website OpenSID |
| `TZ` | `Asia/Jakarta` | System | Waktu zona yang ingin digunakan di PHP dan linux system |
| `DOCKERIZE_VERSION` | `v0.6.1` | System | Utilitas yang berguna untuk container, seperti php.ini dan nginx.conf template. [Selengkapya](https://github.com/jwilder/dockerize) |
| `SERVER_NAME` | - | System | Nama server atau domain yang ingin digunakan untuk website OpenSID. Harus [FQDN](https://id.wikipedia.org/wiki/Fully_qualified_domain_name). |
| `SSH_PORT` | `22` | SSH | Port yang digunakan untuk masuk ke server melalui SSH |
| `SSH_PUBLIC_KEY` | - | SSH | Tingkatkan keamanan SSH server dengan menggunakan Public Key, jika ini di isi akan menonaktifkan SSH password |
| `SSH_PASSWORD` | - | SSH | Alternatif, jika `SSH_PUBLIC_KEY` kosong, maka login SSH akan menggunakan password yang di definisikan disini |
| `PHP_MEMORY_LIMIT` | `128M` | PHP | php.ini variable yang digunakan untuk set maksimum memori yang bisa digunakan oleh PHP |
| `PHP_UPLOAD_MAX_SIZE` | `50M` | PHP | php.ini variable untuk membatasi ukuran file setiap kali upload ke server |
| `PHP_SESSION_SAVE_HANDLER` | `files` | PHP | Jika anda ingin menggunakan Redis server untuk menyimpan sesi PHP bisa dengan mengisi `redis` disini |
| `PHP_SESSION_SAVE_PATH` | `/var/lib/php/sessions` | PHP | Jika menggunakan Redis, bisa di isi seperti: `tcp://127.0.0.1:6379` |
| `OPCACHE_ENABLE` | `1` | PHP | Aktifkan opcache PHP cache engine atau nonaktifkan dengan mengisi `0` |
| `OPCACHE_ENABLE_CLI` | `1` | PHP | Aktifkan opcache PHP cache engine pada command line `php` atau nonaktifkan dengan mengisi `0` |
| `OPCACHE_MEMORY` | `128` | PHP | Maksimum memori yang bisa digunakan untuk cache code PHP |
| `DATABASE_HOSTNAME` | `localhost` | OpenSID | Nama MySQL server yang akan digunakan untuk OpenSID |
| `DATABASE_NAME` | `opensid` | OpenSID | Nama database yang akan digunakan untuk website OpenSID |
| `DATABASE_USERNAME` | `root` | OpenSID | Nama MySQL user yang akan digunakan untuk terhubung dengan database di `DATABASE_NAME` |
| `DATABASE_PASSWORD` | - | OpenSID | Password untuk user `DATABASE_USERNAME` untuk terhubung dengan MySQL server |
| `ADMIN_USERNAME` | - | OpenSID | User login admin OpenSID, jika tidak didefinisikan, akan menggunakan default user OpenSID `admin` |
| `ADMIN_PASSWORD` | - | OpenSID | Password untuk admin user `ADMIN_USERNAME` jika kosong akan menggunakan default OpenSID admin password |

### To-Do

* [ ] Membuat automation script untuk cleanup log
* [ ] Membuat automation script untuk auto update dari github, tanpa menggunakan git
* [ ] Mengaktifkan OpenSID Cron
* [ ] Managemen file website

### Contribution

Laporkan segala jenis error atau bug yang anda temukan di [Issue Tracker GitHub](https://github.com/idjavahost/docker-opensid/issues). Push dan buat merge request jika anda mempunya update terbaru yang ingin disatukan dengan repository ini, siapa saja bebas untuk memasukkan update ke dalam image docker ini.

### License
MIT

---

Diracik oleh [fauzie](https://github.com/fauzie) dengan fasilitas dari [Java Digital Nusantara](http://nusantara.net.id/)   
Dipersembahkan hanya untuk komunitas [OpenSID](https://github.com/OpenSID/OpenSID)

---

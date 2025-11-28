# 7 KAIH - Aplikasi Pelacak Kebiasaan Organisasi

**7 KAIH** (7 Kebiasaan Anak Indonesia Hebat) adalah sebuah aplikasi mobile yang dibangun menggunakan Flutter dan Firebase. Aplikasi ini dirancang untuk membantu anggota dalam sebuah organisasi atau tim untuk mencatat, melacak, dan memvisualisasikan progres dari 7 kebiasaan positif setiap hari.

Aplikasi ini menerapkan model data *multi-tenant*, di mana setiap organisasi memiliki ruang datanya sendiri yang terisolasi, memastikan privasi dan keamanan data.

## Fitur Utama

- **🔐 Autentikasi Pengguna:** Sistem Sign Up & Sign In yang aman menggunakan Firebase Authentication.
- **🏢 Manajemen Organisasi:**
    - Buat organisasi baru dan dapatkan peran sebagai Admin.
    - Gabung ke organisasi yang sudah ada menggunakan ID unik.
- **📊 Dashboard Real-time:**
    - **Input Kebiasaan:** Catat aktivitas harian untuk 7 kebiasaan yang telah ditentukan.
    - **Grafik Kontribusi:** Visualisasikan total kontribusi harian dari seluruh anggota dalam bentuk diagram batang.
    - **Papan Peringkat (Leaderboard):** Lihat peringkat 3 anggota paling aktif di organisasi.
- **👥 Halaman Anggota:**
    - Tampilan data lengkap performa **seluruh** anggota organisasi.
    - Informasi ringkas mengenai total anggota, *streak* pribadi, dan peringkat.
- **⚙️ Halaman Pengaturan:**
    - Kelola profil pengguna (nama dan foto).
    - Ganti antara mode Terang (Light) dan Gelap (Dark).
    - Ganti atau keluar dari organisasi.
    - Logout.
- **📱 Desain Responsif:** Tampilan otomatis beradaptasi antara mode *desktop/tablet* (dengan navigasi samping) dan mode *mobile* (dengan navigasi bawah).

## Teknologi yang Digunakan

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend & Database:** [Firebase](https://firebase.google.com/) (Authentication, Cloud Firestore, Storage)
- **Manajemen State:** [Bloc/Cubit](https://bloclibrary.dev/)
- **Arsitektur:** Clean Architecture (UI > UseCase > Repository > Data Source)
- **Lainnya:** `dartz`, `hydrated_bloc`, `fl_chart`, `image_picker`.

## Cara Menjalankan Proyek Secara Lokal

Untuk menjalankan proyek ini di komputer Anda, ikuti langkah-langkah berikut:

1.  **Prasyarat:**
    - Pastikan Anda sudah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
    - Anda memerlukan akun Firebase untuk backend.

2.  **Clone Repository:**
    ```bash
    git clone https://github.com/NAMA_ANDA/NAMA_REPO_ANDA.git
    cd NAMA_REPO_ANDA
    ```

3.  **Setup Firebase:**
    - Buat proyek baru di [Firebase Console](https://console.firebase.google.com/).
    - Aktifkan layanan **Authentication** (dengan metode Email/Password), **Cloud Firestore**, dan **Storage**.
    - (Wajib) Ikuti panduan untuk menambahkan aplikasi Android dan/atau iOS ke proyek Firebase Anda.
    - Jalankan FlutterFire CLI untuk mengonfigurasi proyek Anda:
      ```bash
      flutterfire configure
      ```
      Perintah ini akan membuat file `lib/firebase_options.dart` yang terhubung ke proyek Firebase Anda.

4.  **Jalankan Aplikasi:**
    - Ambil semua dependensi:
      ```bash
      flutter pub get
      ```
    - Jalankan aplikasi:
      ```bash
      flutter run
      ```

## Screenshot Aplikasi 



| Halaman Dashboard | Halaman Anggota |
| :---: | :---: |
| ![Laptop-Dashboard](screenshots/screenshot-dashboardlaptop.png) | ![Mobile-Dashboard](screenshots/screenshot-dashboardhp.png) |

---

# Duitly – Your Money Buddy

Aplikasi mobile pengelolaan keuangan pribadi berbasis Flutter yang membantu pengguna mencatat pemasukan, pengeluaran, mengatur anggaran, memantau target tabungan, dan melihat ringkasan kondisi keuangan.

## Identitas Mahasiswa

| Keterangan | Informasi |
|---|---|
| Nama | Ni Wayan Enzy Ariantini |
| NIM | 2415051070 |
| Kelas | PTI 5A |
| Mata Kuliah | Pemrograman Mobile |
| Dosen | Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom |
| Teaching Assistant | Made Yuda Sadewa, S.Pd. |
| Nama Project | Duitly – Your Money Buddy |
| Tema | Personal Finance Management |

## Deskripsi Aplikasi

Duitly merupakan aplikasi mobile yang dikembangkan untuk membantu pengguna mengelola keuangan pribadi secara sederhana. Pengguna dapat mencatat transaksi pemasukan dan pengeluaran, menentukan anggaran bulanan, membuat target tabungan, serta melihat analisis keuangan melalui tampilan dashboard.

Aplikasi dikembangkan menggunakan Flutter dan Dart dengan pendekatan pengelolaan state menggunakan Provider dan ChangeNotifier. Supabase digunakan sebagai backend dan database untuk menyimpan serta mengelola data aplikasi.

## Fitur Aplikasi

1. **Dashboard** – Menampilkan ringkasan saldo, pemasukan, pengeluaran, dan anggaran.
2. **Riwayat Transaksi** – Menampilkan daftar transaksi pemasukan dan pengeluaran.
3. **Tambah Transaksi** – Menambahkan data transaksi dengan form dan validasi.
4. **Detail Transaksi** – Menampilkan informasi transaksi yang dipilih.
5. **Edit dan Hapus Transaksi** – Mengubah atau menghapus data transaksi.
6. **Analytics** – Menampilkan ringkasan dan analisis pemasukan serta pengeluaran.
7. **Budget** – Mengatur anggaran dan memantau penggunaan anggaran.
8. **Saving Goals** – Membuat dan mengelola target tabungan.
9. **Saving Activities** – Mencatat aktivitas penambahan dan penarikan tabungan.
10. **Profile** – Menampilkan informasi profil dan pengaturan aplikasi.
11. **Favorite Saving Goals** – Menandai target tabungan sebagai favorit.

## Teknologi yang Digunakan

- Flutter
- Dart
- Provider
- ChangeNotifier
- Supabase
- PostgreSQL
- REST API
- SharedPreferences
- Git dan GitHub
- Visual Studio Code

## REST API dan Backend

Aplikasi menggunakan Supabase sebagai backend dengan layanan REST API untuk berkomunikasi dengan database PostgreSQL.

Operasi yang digunakan meliputi:

| Operasi | Fungsi |
|---|---|
| GET | Mengambil data transaksi dan data tabungan |
| POST | Menambahkan transaksi dan aktivitas tabungan |
| UPDATE | Memperbarui data transaksi dan target tabungan |
| DELETE | Menghapus data transaksi dan target tabungan |

Data yang diterima dari backend dikonversi menjadi Dart Model menggunakan proses JSON parsing.

### Database

Database menggunakan Supabase PostgreSQL dengan tabel utama:

- `transactions` – Menyimpan data pemasukan dan pengeluaran.
- `saving_goals` – Menyimpan target tabungan.
- `saving_entries` – Menyimpan aktivitas penambahan dan penarikan tabungan.

Data anggaran bulanan disimpan menggunakan SharedPreferences.

## Arsitektur Aplikasi

Struktur folder utama:

```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   └── theme/
├── models/
├── providers/
├── repositories/
├── screens/
├── services/
├── widgets/
└── main.dart
```

Alur arsitektur aplikasi:

```text
Screen / Widget
      ↓
Provider / ChangeNotifier
      ↓
Repository
      ↓
Service
      ↓
Supabase REST API
      ↓
PostgreSQL Database
```

Arsitektur tersebut memisahkan tampilan aplikasi, pengelolaan state, proses pengolahan data, dan komunikasi dengan backend.

## Responsive Layout

Aplikasi menerapkan responsive layout menggunakan LayoutBuilder agar tampilan dapat menyesuaikan ukuran layar.

Tampilan dirancang untuk mendukung:
- Compact layout pada layar berukuran kecil.
- Wide layout pada layar berukuran lebih lebar.

## State Management

Pengelolaan state menggunakan Provider dan ChangeNotifier untuk mengatur data aplikasi, termasuk:
- Data transaksi.
- Data target tabungan.
- Aktivitas tabungan.
- Anggaran bulanan.
- Status loading dan error.

## Cara Menjalankan Project

### Persyaratan

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Android Studio atau Android Emulator
- Koneksi internet

### Langkah menjalankan

1. Clone repository:

```bash
git clone https://github.com/enzywayan-web/UTS_2415051070_NiWayanEnzyAriantini.git
```

2. Masuk ke folder project:

```bash
cd UTS_2415051070_NiWayanEnzyAriantini
```

3. Install dependencies:

```bash
flutter pub get
```

4. Pastikan konfigurasi Supabase tersedia pada file konfigurasi aplikasi.

5. Jalankan aplikasi:

```bash
flutter run
```

## Screenshot Aplikasi

Screenshot aplikasi akan dilengkapi pada folder `screenshots/`.

Dokumentasi screenshot yang disiapkan:

- Dashboard
- Riwayat transaksi
- Detail transaksi
- Form tambah transaksi
- Form edit transaksi
- Tampilan responsive
- Data dari REST API
- Data pada Supabase Database

## GitHub Repository

Repository project:

https://github.com/enzywayan-web/UTS_2415051070_NiWayanEnzyAriantini.git

Branch utama: `main`

## Keamanan

Aplikasi menggunakan Supabase publishable key untuk koneksi dari sisi client. Service role key dan credential server yang bersifat rahasia tidak boleh dimasukkan ke dalam aplikasi atau repository publik.

Akses database perlu dilindungi menggunakan konfigurasi Row Level Security (RLS) yang sesuai.

---

**Project Ujian Tengah Semester – Pemrograman Mobile**

Ni Wayan Enzy Ariantini  
2415051070 – PTI 5A
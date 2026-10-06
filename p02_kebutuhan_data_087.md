# Dokumen Kebutuhan Data - Proyek Sistem Informasi Kopma (Milestone 2)
**Nama:** Wulan    **NIM:** 087    **Kelas:** D    **Tanggal:** 06 Oktober 2026

## 1. Pendahuluan
Dokumen ini memuat spesifikasi kebutuhan data, aturan bisnis, matriks CRUD, serta kamus data awal untuk pengembangan sistem informasi di `kopma_123`.

## 2. Proses Bisnis (Minimal 4 Proses)
1. **PB-01 Pendaftaran Anggota:** Calon anggota mendaftarkan diri dengan mengisi data diri untuk mendapatkan kartu/status keanggotaan aktif.
2. **PB-02 Transaksi Pembelian & Poin Loyalitas:** Anggota melakukan transaksi belanja barang, di mana sistem otomatis menghitung total harga dan menambahkan poin loyalitas[cite: 4].
3. **PB-03 Penukaran Poin Loyalitas:** Anggota menukarkan akumulasi poin loyalitas dengan potongan harga/voucher belanja[cite: 4].
4. **PB-04 Manajemen Stok Barang:** Petugas koperasi mengelola data barang masuk, keluar, serta memantau laporan ketersediaan stok.

## 3. Entitas Kandidat (Minimal 6 Entitas)
1. `Anggota` (Menyimpan data identitas dan status anggota)
2. `Petugas` (Menyimpan data pegawai/admin koperasi)
3. `Barang` (Menyimpan informasi produk yang dijual)
4. `Transaksi` (Menyimpan data ringkasan transaksi belanja)
5. `Detail_Transaksi` (Menyimpan rincian barang yang dibeli per transaksi)
6. `Poin_Loyalitas` (Menyimpan riwayat perolehan dan penukaran poin anggota)

## 4. Aturan Bisnis (Minimal 8 Aturan)
* **AB-01:** Setiap pendaftaran anggota baru wajib divalidasi oleh petugas koperasi.
* **AB-02:** Satu anggota hanya dapat memiliki satu nomor identitas unik (ID Anggota).
* **AB-03:** Setiap kelipatan belanja Rp10.000 oleh anggota bernilai 1 poin loyalitas[cite: 4].
* **AB-04:** Sebanyak 50 poin loyalitas dapat ditukar dengan potongan belanja senilai Rp5.000[cite: 4].
* **AB-05:** Transaksi pembelian tidak dapat diproses jika stok barang kurang dari jumlah yang diminta.
* **AB-06:** Setiap transaksi pembelian harus tercatat atas satu ID Petugas yang melayani.
* **AB-07:** Perubahan harga barang hanya dapat dilakukan oleh petugas berwenang (admin).
* **AB-08:** Riwayat penukaran poin wajib mengurangi total akumulasi poin aktif anggota secara real-time.

## 5. Kebutuhan Informasi (Minimal 5 Kebutuhan)
1. Laporan daftar anggota aktif dan riwayat keanggotaan.
2. Laporan rekapitulasi transaksi penjualan harian dan bulanan.
3. Laporan posisi saldo poin loyalitas masing-masing anggota.
4. Laporan stok barang minimum untuk peringatan pengadaan ulang (restock).
5. Laporan rincian potongan harga dari hasil penukaran poin.

## 6. Matriks CRUD
| Entitas / Proses | PB-01 Pendaftaran | PB-02 Transaksi | PB-03 Tukar Poin | PB-04 Kelola Stok |
| :--- | :---: | :---: | :---: | :---: |
| **Anggota** | C, R, U | R | R, U | - |
| **Petugas** | R | R | R | C, R, U, D |
| **Barang** | - | R, U | - | C, R, U, D |
| **Transaksi** | - | C, R | - | - |
| **Detail_Transaksi**| - | C, R | - | - |
| **Poin_Loyalitas** | C | C, U | R, U | - |

## 7. Kamus Data Awal (Minimal 20 Elemen)
| No | Nama Elemen Data | Tipe Data | Panjang | Keterangan / Aturan | Penanggung Jawab |
|:---:|---|---|:---:|---|---|
| 1 | `id_anggota` | Varchar | 10 | Primary Key, unik | Admin Koperasi |
| 2 | `nama_anggota` | Varchar | 50 | Nama lengkap sesuai identitas | Admin Koperasi |
| 3 | `alamat_anggota`| Varchar | 100 | Domisili saat ini (Data Pribadi) | Admin Koperasi |
| 4 | `telepon_anggota`| Varchar | 15 | Nomor kontak aktif (Data Pribadi) | Admin Koperasi |
| 5 | `status_anggota`| Enum | 10 | 'Aktif' / 'Non-Aktif' | Admin Koperasi |
| 6 | `id_petugas` | Varchar | 10 | Primary Key | Manajer |
| 7 | `nama_petugas` | Varchar | 50 | Nama pegawai | Manajer |
| 8 | `role_petugas` | Varchar | 20 | 'Kasir' / 'Admin Stok' | Manajer |
| 9 | `id_barang` | Varchar | 10 | Primary Key | Bagian Gudang |
| 10| `nama_barang` | Varchar | 50 | Nama produk | Bagian Gudang |
| 11| `harga_barang` | Decimal | 10,2 | Harga satuan produk | Bagian Gudang |
| 12| `stok_barang` | Integer | 5 | Sisa jumlah fisik barang | Bagian Gudang |
| 13| `id_transaksi` | Varchar | 15 | Primary Key | Sistem Kasir |
| 14| `tgl_transaksi`| Datetime | - | Waktu transaksi dilakukan | Sistem Kasir |
| 15| `total_transaksi`| Decimal| 10,2 | Nominal akhir pembayaran | Sistem Kasir |
| 16| `jumlah_beli` | Integer | 5 | Kuantitas barang dibeli | Sistem Kasir |
| 17| `subtotal` | Decimal | 10,2 | Harga x jumlah beli | Sistem Kasir |
| 18| `id_poin` | Varchar | 10 | Primary Key | Sistem Loyalitas |
| 19| `jumlah_poin` | Integer | 5 | Akumulasi / perubahan poin | Sistem Loyalitas |
| 20| `tgl_kadaluarsa`| Date | - | Batas masa berlaku poin | Sistem Loyalitas |

## 8. Kebutuhan Non-Fungsional & Keamanan Data Pribadi
* **Kinerja (Performance):** Sistem harus mampu merespons pencarian data barang dalam waktu kurang dari 2 detik.
* **Keamanan Data Pribadi:** 
  * Data pribadi anggota seperti `alamat_anggota` dan `telepon_anggota` dikategorikan sebagai informasi sensitif.
  * **Hak Akses:** Data pribadi hanya boleh diakses oleh *Admin Koperasi* yang berwenang, serta anggota pemilik data tersebut. Kasir hanya dapat melihat nama dan sisa poin saat transaksi.
* **Keandalan (Reliability):** Sistem melakukan backup database secara otomatis setiap pukul 00.00 WIB.

## 9. Dokumen Sumber Fiktif (Nota Transaksi & Poin)
*(Contoh rancangan format nota belanja koperasi yang memuat informasi perolehan poin)*
========================================
KOPMA 123 - NOTA BELANJA
ID Transaksi : TRX-20261006-001
Kasir        : Budi (P-001)
Anggota      : Wulan (A-087)
Buku Tulis  (2x Rp5.000) = Rp10.000

Pulpen      (3x Rp3.000) = Rp9.000

Total Belanja               = Rp19.000
Poin Diperoleh              = 1 Poin (Kelipatan Rp10k)
Total Poin Anda Sekarang    = 15 Poin
 Terima Kasih Telah Berbelanja!     
========================================
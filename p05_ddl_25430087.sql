-- ============================================================================
-- SKRIP DDL BASIS DATA KOPERASI MAHASISWA (KOPMA) - MILESTONE PROYEK 5 & 6
-- Nama       : Wulan Maghfiroh
-- NIM        : 25430087
-- Kelas      : Basis Data Praktikum (Semester 3) / Kelas D
-- Dosen      : Dedi Irawan, S.Kom., M.T.I.
-- Berkas     : p05_ddl_25430087.sql
-- Basis Data : kopma_087
-- Keterangan : Skrip DDL ini dirancang idempoten sehingga dapat dijalankan 
--              ulang secara otomatis dari kondisi basis data kosong.
-- Konvensi Penamaan Khusus:
--   1. Primary Key wajib bernama: id_<nama_tabel>
--   2. Foreign Key wajib bernama: id_<nama_tabel_tujuan>
--   3. Constraint memiliki nama eksplisit dan komentar kode Aturan Bisnis (AB-xx).
-- Parameter Personal (NIM: 25430087):
--   P = (87 mod 9) + 1 = 7. Batas P + 2 = 9 unit/item.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. INISIALISASI BASIS DATA BERSIH
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS kopma_087;
CREATE DATABASE kopma_087
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE kopma_087;

-- ============================================================================
-- 1. TABEL: petugas (Master Petugas dan Kasir Koperasi)
-- Aturan Bisnis: AB-06 (Setiap transaksi wajib dilayani petugas terdaftar)
-- PK: id_petugas
-- ============================================================================
CREATE TABLE petugas (
    id_petugas INT AUTO_INCREMENT NOT NULL,
    kode_petugas VARCHAR(10) NOT NULL,
    nama_petugas VARCHAR(100) NOT NULL,
    username VARCHAR(50) NULL,
    password VARCHAR(255) NULL,
    peran_petugas ENUM('kasir', 'gudang', 'ketua', 'admin') NOT NULL DEFAULT 'kasir',
    CONSTRAINT pk_petugas PRIMARY KEY (id_petugas),
    CONSTRAINT uq_petugas_kode UNIQUE (kode_petugas),
    CONSTRAINT uq_petugas_username UNIQUE (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. TABEL: anggota (Master Anggota Koperasi Mahasiswa)
-- Aturan Bisnis: 
--   AB-01: Pendaftaran anggota divalidasi oleh petugas (status aktif/nonaktif).
--   AB-02: Satu anggota memiliki satu nomor identitas unik (ID Anggota / NIM).
--   AB-05: NIM anggota bersifat unik (mencegah pendaftaran ganda).
-- PK: id_anggota
-- ============================================================================
CREATE TABLE anggota (
    id_anggota INT AUTO_INCREMENT NOT NULL,
    nim_anggota VARCHAR(20) NOT NULL,
    nama_anggota VARCHAR(100) NOT NULL,
    jenis_kelamin ENUM('L', 'P') NULL,
    telepon_anggota VARCHAR(20) NULL,
    alamat_anggota TEXT NULL,
    status_anggota ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif', /* AB-01: Validasi status anggota */
    tgl_daftar DATE NOT NULL,
    CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
    CONSTRAINT uq_anggota_nim UNIQUE (nim_anggota), /* AB-05: NIM kembar ditolak */
    CONSTRAINT uq_anggota_telepon UNIQUE (telepon_anggota) /* AB-02: Nomor kontak unik */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. TABEL: barang (Master Inventaris dan Katalog Produk Toko Kopma)
-- Aturan Bisnis:
--   AB-03: Stok barang tidak boleh bernilai negatif (stok >= 0).
--   AB-07: Harga barang katalog wajib bernilai positif (> 0).
-- Kebutuhan Info: KI-04 (Peringatan pengadaan ulang jika stok <= stok_min).
-- PK: id_barang
-- ============================================================================
CREATE TABLE barang (
    id_barang INT AUTO_INCREMENT NOT NULL,
    kode_barang VARCHAR(15) NOT NULL,
    nama_barang VARCHAR(100) NOT NULL,
    kategori_barang VARCHAR(50) NOT NULL,
    harga_jual_barang DECIMAL(10, 2) NOT NULL,
    stok_barang INT NOT NULL DEFAULT 0,
    stok_min_barang INT NOT NULL DEFAULT 5,
    CONSTRAINT pk_barang PRIMARY KEY (id_barang),
    CONSTRAINT uq_barang_kode UNIQUE (kode_barang),
    CONSTRAINT chk_barang_harga CHECK (harga_jual_barang > 0), /* AB-07: Harga katalog positif */
    CONSTRAINT chk_barang_stok CHECK (stok_barang >= 0), /* AB-03: Stok fisik tidak boleh negatif */
    CONSTRAINT chk_barang_stok_min CHECK (stok_min_barang >= 0) /* KI-04: Batas restock valid */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. TABEL: pemasok (Master Mitra Suplai dan Pemasok Barang)
-- PK: id_pemasok
-- ============================================================================
CREATE TABLE pemasok (
    id_pemasok INT AUTO_INCREMENT NOT NULL,
    nama_pemasok VARCHAR(100) NOT NULL,
    telepon_pemasok VARCHAR(20) NULL,
    alamat_pemasok TEXT NULL,
    CONSTRAINT pk_pemasok PRIMARY KEY (id_pemasok)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. TABEL: penjualan (Kepala Nota Transaksi Belanja Kasir)
-- Aturan Bisnis:
--   AB-01: Nomor nota penjualan unik (tidak boleh ada nomor nota kembar).
--   AB-02: Belanja dapat tercatat atas anggota aktif atau pelanggan umum (id_anggota NULL).
--   AB-03: Kelipatan belanja Rp10.000 bernilai 1 poin loyalitas.
--   AB-06: Setiap transaksi wajib tercatat atas satu ID Petugas kasir.
-- PK: id_penjualan
-- FK: id_petugas (ke petugas), id_anggota (ke anggota, nullable)
-- ============================================================================
CREATE TABLE penjualan (
    id_penjualan INT AUTO_INCREMENT NOT NULL,
    no_nota_penjualan VARCHAR(30) NOT NULL,
    tgl_penjualan DATETIME NOT NULL,
    id_petugas INT NOT NULL, /* AB-06: FK mengacu ke tabel petugas */
    id_anggota INT NULL,     /* AB-02: FK mengacu ke tabel anggota, NULL jika pelanggan umum */
    bayar_penjualan DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_belanja DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    poin_didapat INT NOT NULL DEFAULT 0, /* AB-03: Poin perolehan transaksi kasir */
    CONSTRAINT pk_penjualan PRIMARY KEY (id_penjualan),
    CONSTRAINT uq_penjualan_no_nota UNIQUE (no_nota_penjualan), /* AB-01: Nomor nota unik */
    CONSTRAINT fk_penjualan_petugas FOREIGN KEY (id_petugas) 
        REFERENCES petugas(id_petugas) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_penjualan_anggota FOREIGN KEY (id_anggota) 
        REFERENCES anggota(id_anggota) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT chk_penjualan_total CHECK (total_belanja >= 0),
    CONSTRAINT chk_penjualan_bayar CHECK (bayar_penjualan >= 0),
    CONSTRAINT chk_penjualan_poin CHECK (poin_didapat >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. TABEL: detail_penjualan (Rincian Item Barang yang Dibeli pada Nota Kasir)
-- Aturan Bisnis:
--   AB-05: Kuantitas barang belanja valid.
--   AB-07: Harga satuan historis transaksi terkunci pada saat pembelian.
-- Batas Parameter Personal (P=7):
--   - Analisis 1 Baris (Intra-row): Kuantitas beli per item dibatasi 1 s.d P+2 (1 s.d 9 unit).
--     Ditegakkan langsung melalui CONSTRAINT ck_detail_qty (qty >= 1 AND qty <= 9).
--   - Analisis Banyak Baris (Inter-row): Batasan jumlah ragam baris item per transaksi (maksimal 9 baris).
--     Ditandai secara resmi untuk diselesaikan menggunakan Trigger di Modul 14.
-- PK Komposit: (id_penjualan, id_barang)
-- FK: id_penjualan (ke penjualan ON DELETE CASCADE), id_barang (ke barang ON DELETE RESTRICT)
-- ============================================================================
CREATE TABLE detail_penjualan (
    id_penjualan INT NOT NULL, /* FK mengacu ke tabel penjualan */
    id_barang INT NOT NULL,    /* FK mengacu ke tabel barang */
    qty_detail_penjualan INT NOT NULL,
    harga_satuan_detail_penjualan DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_detail_penjualan PRIMARY KEY (id_penjualan, id_barang),
    CONSTRAINT fk_detail_penjualan_penjualan FOREIGN KEY (id_penjualan) 
        REFERENCES penjualan(id_penjualan) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_penjualan_barang FOREIGN KEY (id_barang) 
        REFERENCES barang(id_barang) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    -- Constraint P+2 lingkup 1 baris (intra-row): Kuantitas per item dibatasi 1 s.d P+2 (1 s.d 9 unit)
    CONSTRAINT ck_detail_qty CHECK (qty_detail_penjualan >= 1 AND qty_detail_penjualan <= 9), /* Parameter P=7 -> P+2=9 */
    CONSTRAINT chk_detail_penjualan_harga CHECK (harga_satuan_detail_penjualan > 0) /* AB-07: Harga satuan transaksi historis wajib positif */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. TABEL: riwayat_poin (Buku Besar Log Audit Poin Loyalitas Anggota)
-- Aturan Bisnis:
--   AB-03: Perolehan poin dari transaksi kasir.
--   AB-04: Penukaran 50 poin loyalitas dengan potongan belanja senilai Rp5.000.
--   AB-08: Riwayat penukaran poin wajib mengurangi saldo poin secara real-time.
-- PK: id_riwayat_poin
-- FK: id_anggota (ke anggota), id_penjualan (ke penjualan, bersifat opsional/NULL)
-- ============================================================================
CREATE TABLE riwayat_poin (
    id_riwayat_poin INT AUTO_INCREMENT NOT NULL,
    id_anggota INT NOT NULL,           /* FK mengacu ke tabel anggota */
    id_penjualan INT NULL,             /* FK mengacu ke tabel penjualan (dapat NULL jika penukaran non-nota) */
    tgl_transaksi_poin DATETIME NOT NULL,
    jenis_mutasi ENUM('Perolehan', 'Penukaran', 'Kedaluwarsa') NOT NULL,
    jumlah_poin INT NOT NULL, /* AB-08: Bernilai positif untuk perolehan, bernilai negatif untuk penukaran */
    keterangan VARCHAR(255) NULL,
    CONSTRAINT pk_riwayat_poin PRIMARY KEY (id_riwayat_poin),
    CONSTRAINT fk_riwayat_poin_anggota FOREIGN KEY (id_anggota) 
        REFERENCES anggota(id_anggota) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_riwayat_poin_penjualan FOREIGN KEY (id_penjualan) 
        REFERENCES penjualan(id_penjualan) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL,
    CONSTRAINT chk_riwayat_poin_jumlah CHECK (jumlah_poin != 0) /* Mutasi poin tidak boleh 0 */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 8. TABEL: pembelian (Kepala Faktur Pengadaan Barang Gudang dari Pemasok)
-- PK: id_pembelian
-- FK: id_pemasok (ke pemasok), id_petugas (ke petugas verifikator gudang)
-- ============================================================================
CREATE TABLE pembelian (
    id_pembelian INT AUTO_INCREMENT NOT NULL,
    no_faktur_pembelian VARCHAR(50) NOT NULL,
    tgl_pembelian DATE NOT NULL,
    id_pemasok INT NOT NULL, /* FK mengacu ke tabel pemasok */
    id_petugas INT NOT NULL, /* FK mengacu ke tabel petugas gudang */
    total_pembelian DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status_pembelian ENUM('Diproses', 'Diterima', 'Selesai', 'Dibatalkan') NOT NULL DEFAULT 'Diterima',
    CONSTRAINT pk_pembelian PRIMARY KEY (id_pembelian),
    CONSTRAINT uq_pembelian_faktur UNIQUE (no_faktur_pembelian),
    CONSTRAINT fk_pembelian_pemasok FOREIGN KEY (id_pemasok) 
        REFERENCES pemasok(id_pemasok) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_pembelian_petugas FOREIGN KEY (id_petugas) 
        REFERENCES petugas(id_petugas) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT chk_pembelian_total CHECK (total_pembelian >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 9. TABEL: detail_pembelian (Rincian Item Barang yang Dipasok dari Pemasok)
-- PK Komposit: (id_pembelian, id_barang)
-- FK: id_pembelian (ke pembelian ON DELETE CASCADE), id_barang (ke barang ON DELETE RESTRICT)
-- ============================================================================
CREATE TABLE detail_pembelian (
    id_pembelian INT NOT NULL, /* FK mengacu ke tabel pembelian */
    id_barang INT NOT NULL,    /* FK mengacu ke tabel barang */
    qty_detail_pembelian INT NOT NULL,
    harga_beli_detail_pembelian DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_detail_pembelian PRIMARY KEY (id_pembelian, id_barang),
    CONSTRAINT fk_detail_pembelian_pembelian FOREIGN KEY (id_pembelian) 
        REFERENCES pembelian(id_pembelian) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_pembelian_barang FOREIGN KEY (id_barang) 
        REFERENCES barang(id_barang) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT chk_detail_pembelian_qty CHECK (qty_detail_pembelian >= 1),
    CONSTRAINT chk_detail_pembelian_harga CHECK (harga_beli_detail_pembelian > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 10. VIEWS KOMPATIBILITAS (ALIAS: transaksi & detail_transaksi)
-- Menjamin kompatibilitas kueri laporan sebelumnya yang merujuk nama transaksi
-- ============================================================================
CREATE OR REPLACE VIEW transaksi AS 
SELECT id_penjualan AS id_transaksi, 
       no_nota_penjualan,
       tgl_penjualan AS tgl_transaksi, 
       id_petugas, 
       id_anggota, 
       total_belanja, 
       poin_didapat 
FROM penjualan;

CREATE OR REPLACE VIEW detail_transaksi AS 
SELECT id_penjualan AS id_transaksi, 
       id_barang, 
       qty_detail_penjualan AS qty, 
       harga_satuan_detail_penjualan AS harga_satuan 
FROM detail_penjualan;

-- ============================================================================
-- AKHIR DARI SKRIP DDL p05_ddl_25430087.sql
-- ============================================================================

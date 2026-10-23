-- ============================================================================
-- SKRIP DDL BASIS DATA KOPERASI MAHASISWA (KOPMA) - MILESTONE PROYEK 5
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
    id_petugas VARCHAR(15) NOT NULL,
    nama_petugas VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_petugas ENUM('Kasir', 'Admin Gudang', 'Manajer') NOT NULL DEFAULT 'Kasir',
    CONSTRAINT pk_petugas PRIMARY KEY (id_petugas),
    CONSTRAINT uq_petugas_username UNIQUE (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 2. TABEL: anggota (Master Anggota Koperasi Mahasiswa)
-- Aturan Bisnis: 
--   AB-01: Pendaftaran anggota divalidasi oleh petugas (status Aktif/Non-Aktif).
--   AB-02: Satu anggota memiliki satu nomor identitas unik (ID Anggota).
-- PK: id_anggota
-- ============================================================================
CREATE TABLE anggota (
    id_anggota VARCHAR(15) NOT NULL,
    nama_anggota VARCHAR(100) NOT NULL,
    jenis_kelamin ENUM('L', 'P') NOT NULL,
    telepon_anggota VARCHAR(20) NOT NULL,
    alamat_anggota TEXT NOT NULL,
    status_anggota ENUM('Aktif', 'Non-Aktif') NOT NULL DEFAULT 'Aktif', /* AB-01: Validasi status anggota */
    tgl_daftar DATE NOT NULL,
    CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
    CONSTRAINT uq_anggota_telepon UNIQUE (telepon_anggota) /* AB-02: Nomor kontak unik */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 3. TABEL: barang (Master Inventaris dan Katalog Produk Toko Kopma)
-- Aturan Bisnis:
--   AB-05: Transaksi tidak dapat diproses jika stok kurang (stok non-negatif).
--   AB-07: Perubahan harga barang dikelola admin (harga wajib bernilai positif).
-- Kebutuhan Info: KI-04 (Peringatan pengadaan ulang jika stok <= stok_min).
-- PK: id_barang
-- ============================================================================
CREATE TABLE barang (
    id_barang VARCHAR(15) NOT NULL,
    nama_barang VARCHAR(100) NOT NULL,
    kategori_barang VARCHAR(50) NOT NULL,
    harga_barang DECIMAL(10, 2) NOT NULL,
    stok_barang INT NOT NULL DEFAULT 0,
    stok_min_barang INT NOT NULL DEFAULT 5,
    CONSTRAINT pk_barang PRIMARY KEY (id_barang),
    CONSTRAINT chk_barang_harga CHECK (harga_barang > 0), /* AB-07: Harga barang katalog wajib bernilai positif */
    CONSTRAINT chk_barang_stok CHECK (stok_barang >= 0), /* AB-05: Stok fisik tidak boleh bernilai negatif */
    CONSTRAINT chk_barang_stok_min CHECK (stok_min_barang >= 0) /* KI-04: Batas restock persediaan valid */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 4. TABEL: pemasok (Master Mitra Suplai dan Pemasok Barang)
-- PK: id_pemasok
-- ============================================================================
CREATE TABLE pemasok (
    id_pemasok VARCHAR(15) NOT NULL,
    nama_pemasok VARCHAR(100) NOT NULL,
    telepon_pemasok VARCHAR(20) NOT NULL,
    alamat_pemasok TEXT NOT NULL,
    CONSTRAINT pk_pemasok PRIMARY KEY (id_pemasok)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 5. TABEL: transaksi (Kepala Nota Transaksi Belanja Kasir)
-- Aturan Bisnis:
--   AB-02: Belanja anggota tercatat atas identitas unik anggota pembeli.
--   AB-03: Kelipatan belanja Rp10.000 bernilai 1 poin loyalitas.
--   AB-06: Setiap transaksi wajib tercatat atas satu ID Petugas kasir.
-- PK: id_transaksi
-- FK: id_petugas (ke petugas), id_anggota (ke anggota)
-- ============================================================================
CREATE TABLE transaksi (
    id_transaksi VARCHAR(20) NOT NULL,
    tgl_transaksi DATETIME NOT NULL,
    id_petugas VARCHAR(15) NOT NULL, /* AB-06: FK mengacu ke tabel petugas */
    id_anggota VARCHAR(15) NOT NULL, /* AB-02: FK mengacu ke tabel anggota */
    total_belanja DECIMAL(12, 2) NOT NULL DEFAULT 0.00, /* Nilai snapshot finansial terkendali */
    poin_didapat INT NOT NULL DEFAULT 0, /* AB-03: Poin perolehan transaksi kasir */
    CONSTRAINT pk_transaksi PRIMARY KEY (id_transaksi),
    CONSTRAINT fk_transaksi_petugas FOREIGN KEY (id_petugas) 
        REFERENCES petugas(id_petugas) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_transaksi_anggota FOREIGN KEY (id_anggota) 
        REFERENCES anggota(id_anggota) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT chk_transaksi_total CHECK (total_belanja >= 0),
    CONSTRAINT chk_transaksi_poin CHECK (poin_didapat >= 0) /* AB-03: Poin tidak boleh bernilai negatif */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 6. TABEL: detail_transaksi (Rincian Item Barang yang Dibeli pada Nota Kasir)
-- Aturan Bisnis:
--   AB-05: Kuantitas barang belanja valid.
--   AB-07: Harga satuan historis transaksi terkunci pada saat pembelian.
-- Batas Parameter Personal (P=7):
--   - Analisis 1 Baris (Intra-row): Kuantitas beli per item dibatasi 1 s.d P+2 (1 s.d 9 unit).
--     Ditegakkan langsung melalui CONSTRAINT CHECK (qty >= 1 AND qty <= 9).
--   - Analisis Banyak Baris (Inter-row): Batasan jumlah ragam baris item per transaksi (maksimal 9 baris).
--     CHECK constraint tidak dapat menjaganya karena melibatkan banyak baris (subquery dilarang di CHECK).
--     Ditandai secara resmi untuk diselesaikan menggunakan Trigger di Modul 14.
-- PK Komposit: (id_transaksi, id_barang)
-- FK: id_transaksi (ke transaksi), id_barang (ke barang)
-- ============================================================================
CREATE TABLE detail_transaksi (
    id_transaksi VARCHAR(20) NOT NULL, /* FK mengacu ke tabel transaksi */
    id_barang VARCHAR(15) NOT NULL,    /* FK mengacu ke tabel barang */
    qty INT NOT NULL,
    harga_satuan DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_detail_transaksi PRIMARY KEY (id_transaksi, id_barang),
    CONSTRAINT fk_detail_transaksi_transaksi FOREIGN KEY (id_transaksi) 
        REFERENCES transaksi(id_transaksi) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT fk_detail_transaksi_barang FOREIGN KEY (id_barang) 
        REFERENCES barang(id_barang) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    -- Constraint P+2 lingkup 1 baris (intra-row): Kuantitas per item dibatasi 1 s.d P+2 (1 s.d 9 unit)
    CONSTRAINT chk_detail_transaksi_qty CHECK (qty >= 1 AND qty <= 9), /* Parameter P=7 -> P+2=9 */
    CONSTRAINT chk_detail_transaksi_harga CHECK (harga_satuan > 0) /* AB-07: Harga satuan transaksi historis wajib positif */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 7. TABEL: riwayat_poin (Buku Besar Log Audit Poin Loyalitas Anggota)
-- Aturan Bisnis:
--   AB-03: Perolehan poin dari transaksi kasir.
--   AB-04: Penukaran 50 poin loyalitas dengan potongan belanja senilai Rp5.000.
--   AB-08: Riwayat penukaran poin wajib mengurangi saldo poin secara real-time.
-- PK: id_riwayat_poin
-- FK: id_anggota (ke anggota), id_transaksi (ke transaksi, bersifat opsional/NULL)
-- ============================================================================
CREATE TABLE riwayat_poin (
    id_riwayat_poin INT AUTO_INCREMENT NOT NULL,
    id_anggota VARCHAR(15) NOT NULL,   /* FK mengacu ke tabel anggota */
    id_transaksi VARCHAR(20) NULL,      /* FK mengacu ke tabel transaksi (dapat NULL jika penukaran non-nota) */
    tgl_transaksi_poin DATETIME NOT NULL,
    jenis_mutasi ENUM('Perolehan', 'Penukaran', 'Kedaluwarsa') NOT NULL,
    jumlah_poin INT NOT NULL, /* AB-08: Bernilai positif untuk perolehan, bernilai negatif untuk penukaran */
    keterangan VARCHAR(255) NULL,
    CONSTRAINT pk_riwayat_poin PRIMARY KEY (id_riwayat_poin),
    CONSTRAINT fk_riwayat_poin_anggota FOREIGN KEY (id_anggota) 
        REFERENCES anggota(id_anggota) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
    CONSTRAINT fk_riwayat_poin_transaksi FOREIGN KEY (id_transaksi) 
        REFERENCES transaksi(id_transaksi) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL,
    CONSTRAINT chk_riwayat_poin_jumlah CHECK (jumlah_poin != 0) /* Mutasi poin tidak boleh 0 */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- 8. TABEL: pembelian (Kepala Faktur Pengadaan Barang Gudang dari Pemasok)
-- Titik Analisis 3 (P03): Keterlacakan staf gudang verifikator barang masuk.
-- PK: id_pembelian
-- FK: id_pemasok (ke pemasok), id_petugas (ke petugas verifikator gudang)
-- ============================================================================
CREATE TABLE pembelian (
    id_pembelian VARCHAR(20) NOT NULL,
    no_faktur_pembelian VARCHAR(50) NOT NULL,
    tgl_pembelian DATE NOT NULL,
    id_pemasok VARCHAR(15) NOT NULL, /* FK mengacu ke tabel pemasok */
    id_petugas VARCHAR(15) NOT NULL, /* FK mengacu ke tabel petugas gudang */
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
-- FK: id_pembelian (ke pembelian), id_barang (ke barang)
-- ============================================================================
CREATE TABLE detail_pembelian (
    id_pembelian VARCHAR(20) NOT NULL, /* FK mengacu ke tabel pembelian */
    id_barang VARCHAR(15) NOT NULL,    /* FK mengacu ke tabel barang */
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
-- AKHIR DARI SKRIP DDL p05_ddl_25430087.sql
-- Seluruh 9 tabel fisik, kunci primer id_<nama_tabel>, kunci tamu id_<nama_tabel_tujuan>,
-- serta constraint aturan bisnis (AB-xx) dan parameter P+2 telah terdefinisi sempurna.
-- ============================================================================

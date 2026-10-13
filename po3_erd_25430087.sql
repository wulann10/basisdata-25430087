-- ========================================================
-- Skrip DDL Basis Data Koperasi Mahasiswa (Kopma)
-- Nama : Wulan Maghfiroh
-- NIM  : 25430087
-- Modul: Pertemuan 03 - Entity-Relationship Diagram (ERD)
-- ========================================================

CREATE DATABASE IF NOT EXISTS kopma;
USE kopma;

-- 1. Tabel Petugas
CREATE TABLE IF NOT EXISTS petugas (
    id_petugas INT AUTO_INCREMENT PRIMARY KEY,
    nama_petugas VARCHAR(50) NOT NULL,
    username VARCHAR(30) NOT NULL,
    password VARCHAR(35) NOT NULL,
    peran_petugas ENUM('admin', 'kasir') NOT NULL
);

-- 2. Tabel Anggota
CREATE TABLE IF NOT EXISTS anggota (
    id_anggota VARCHAR(10) PRIMARY KEY,
    nama_anggota VARCHAR(100) NOT NULL,
    jk_anggota CHAR(1) NOT NULL,
    tempat_lahir_anggota VARCHAR(50),
    tgl_lahir_anggota DATE,
    prodi_anggota VARCHAR(100),
    no_hp_anggota VARCHAR(15),
    status_anggota VARCHAR(20),
    tgl_daftar_anggota DATE
);

-- 3. Tabel Pemasok
CREATE TABLE IF NOT EXISTS pemasok (
    id_pemasok INT AUTO_INCREMENT PRIMARY KEY,
    nama_pemasok VARCHAR(100) NOT NULL,
    telp_pemasok VARCHAR(15),
    alamat_pemasok VARCHAR(200)
);

-- 4. Tabel Barang
CREATE TABLE IF NOT EXISTS barang (
    kd_barang VARCHAR(10) PRIMARY KEY,
    nama_barang VARCHAR(100) NOT NULL,
    kategori_barang VARCHAR(50),
    harga_jual_barang DECIMAL(10,2) NOT NULL,
    stok_barang INT(11) NOT NULL,
    stok_min_barang INT(11) NOT NULL
);

-- 5. Tabel Penjualan
CREATE TABLE IF NOT EXISTS penjualan (
    no_penjualan VARCHAR(12) PRIMARY KEY,
    no_nota_penjualan VARCHAR(20),
    tgl_penjualan DATETIME NOT NULL,
    jml_penjualan SMALLINT(6),
    total_penjualan DECIMAL(10,2),
    id_petugas INT(11) NOT NULL,
    id_anggota VARCHAR(10) NOT NULL,
    bayar_penjualan DECIMAL(10,2),
    CONSTRAINT fk_penjualan_petugas FOREIGN KEY (id_petugas) REFERENCES petugas(id_petugas),
    CONSTRAINT fk_penjualan_anggota FOREIGN KEY (id_anggota) REFERENCES anggota(id_anggota)
);

-- 6. Tabel Detail Penjualan (Entitas Asosiatif Penjualan - Barang)
CREATE TABLE IF NOT EXISTS detail_penjualan (
    no_penjualan VARCHAR(12) NOT NULL,
    kd_barang VARCHAR(10) NOT NULL,
    qty_detail_penjualan INT(11) NOT NULL,
    harga_satuan_detail_penjualan DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (no_penjualan, kd_barang),
    CONSTRAINT fk_dp_penjualan FOREIGN KEY (no_penjualan) REFERENCES penjualan(no_penjualan) ON DELETE CASCADE,
    CONSTRAINT fk_dp_barang FOREIGN KEY (kd_barang) REFERENCES barang(kd_barang)
);

-- 7. Tabel Pembelian
CREATE TABLE IF NOT EXISTS pembelian (
    id_pembelian INT AUTO_INCREMENT PRIMARY KEY,
    no_faktur_pembelian VARCHAR(20),
    tgl_pembelian DATE NOT NULL,
    jml_pembelian INT(11),
    id_pemasok INT(11) NOT NULL,
    status_pembelian VARCHAR(30),
    CONSTRAINT fk_pembelian_pemasok FOREIGN KEY (id_pemasok) REFERENCES pemasok(id_pemasok)
);

-- 8. Tabel Detail Pembelian (Entitas Asosiatif Pembelian - Barang)
CREATE TABLE IF NOT EXISTS detail_pembelian (
    id_pembelian INT(11) NOT NULL,
    kd_barang VARCHAR(10) NOT NULL,
    qty_detail_pembelian INT(11) NOT NULL,
    harga_beli_detail_pembelian DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pembelian, kd_barang),
    CONSTRAINT fk_dpembelian_pembelian FOREIGN KEY (id_pembelian) REFERENCES pembelian(id_pembelian) ON DELETE CASCADE,
    CONSTRAINT fk_dpembelian_barang FOREIGN KEY (kd_barang) REFERENCES barang(kd_barang)
);

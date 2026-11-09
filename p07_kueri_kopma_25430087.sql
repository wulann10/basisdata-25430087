-- ============================================================================
-- SKRIP KUERI KOPMA - LANGKAH PERCOBAAN D & LATIHAN E (MODUL 07)
-- Praktikum Basis Data: Menjawab Pertanyaan dengan SELECT dan Fungsi Skalar
-- 
-- Identitas Mahasiswa:
-- Nama       : Wulan Maghfiroh
-- NIM        : 25430087
-- Kelas      : Basis Data Praktikum (Semester 3) / Kelas D
-- Dosen      : Dedi Irawan, S.Kom., M.T.I.
-- Berkas     : p07_kueri_kopma_25430087.sql
-- Basis Data : kopma_087
-- Tanggal    : 09 November 2026
-- Repositori : basisdata-25430087
-- ============================================================================

USE kopma_087;

-- ============================================================================
-- D. LANGKAH PERCOBAAN
-- ============================================================================

-- ----------------------------------------------------------------------------
-- D.1 PROYEKSI DAN PENYARINGAN
-- ----------------------------------------------------------------------------

-- 1. Kueri KI-03: Menampilkan barang yang berada di bawah batas stok minimum
-- Pertanyaan: "Barang apa saja yang stoknya hampir habis dan perlu dipesan ulang?"
-- Hasil yang diharapkan: Menampilkan barang dengan stok_barang < stok_min_barang 
-- beserta selisih kekurangan stoknya, diurutkan dari yang paling mendesak.
SELECT kode_barang, 
       nama_barang, 
       stok_barang, 
       stok_min_barang, 
       stok_min_barang - stok_barang AS kurang
FROM barang
WHERE stok_barang < stok_min_barang
ORDER BY kurang DESC;


-- 2. Tiga Kueri Penyaringan Lain:

-- 2.a Penyaringan Himpunan Nilai (Operator IN):
-- Pertanyaan: "Barang apa saja yang termasuk dalam kategori ATK atau minuman?"
-- Hasil yang diharapkan: Menampilkan seluruh katalog barang khusus kategori ATK dan minuman.
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       harga_jual_barang, 
       stok_barang
FROM barang
WHERE kategori_barang IN ('ATK', 'minuman')
ORDER BY kategori_barang ASC, nama_barang ASC;


-- 2.b Penyaringan Rentang Waktu (Operator BETWEEN):
-- Pertanyaan: "Nota penjualan mana sajakah yang tercatat pada hari transaksi 24 September 2026?"
-- Hasil yang diharapkan: Menampilkan transaksi yang terjadi antara rentang tanggal 24-09-2026 00:00:00 s.d 23:59:59.
SELECT no_nota_penjualan, 
       tgl_penjualan, 
       total_belanja, 
       bayar_penjualan
FROM penjualan
WHERE tgl_penjualan BETWEEN '2026-09-24 00:00:00' AND '2026-09-24 23:59:59'
ORDER BY tgl_penjualan ASC;


-- 2.c Penyaringan Nilai Kosong (Operator IS NULL):
-- Pertanyaan: "Siapa saja anggota koperasi yang belum memiliki / tidak mengisi nomor telepon HP?"
-- Hasil yang diharapkan: Menampilkan baris data anggota yang kolom telepon_anggota bernilai NULL.
SELECT nim_anggota, 
       nama_anggota, 
       jenis_kelamin, 
       status_anggota, 
       telepon_anggota
FROM anggota
WHERE telepon_anggota IS NULL;


-- ----------------------------------------------------------------------------
-- TITIK ANALISIS 1: Evaluasi Alias Kolom pada Klausa WHERE vs ORDER BY
-- ----------------------------------------------------------------------------
-- Demonstrasi Galat: Mencoba menyaring baris menggunakan alias 'kurang' pada WHERE:
--
-- SELECT kode_barang, nama_barang, stok_barang, stok_min_barang, 
--        stok_min_barang - stok_barang AS kurang
-- FROM barang
-- WHERE kurang > 0;
--
-- HASIL RUNTIME SERVER:
-- ERROR 1054 (42S22): Unknown column 'kurang' in 'where clause'
--
-- PENJELASAN LOGIS:
-- Hal ini disebabkan oleh urutan evaluasi logis SQL (Logical Query Processing Order):
-- 1. FROM & JOIN     -> Menentukan dan menggabungkan tabel sumber data
-- 2. WHERE           -> Menyaring baris berdasarkan predikat kondisi
-- 3. GROUP BY        -> Mengelompokkan baris hasil penyaringan
-- 4. HAVING          -> Menyaring kelompok data (agregasi)
-- 5. SELECT          -> Mengevaluasi ekspresi kolom dan MENETAPKAN ALIAS ('AS kurang')
-- 6. DISTINCT        -> Menghilangkan duplikasi baris
-- 7. ORDER BY        -> Mengurutkan hasil akhir (alias SUDAH DIKENAL di sini)
-- 8. LIMIT           -> Membatasi jumlah baris output
--
-- Karena klausa WHERE dievaluasi pada Langkah 2 SEBELUM klausa SELECT (Langkah 5),
-- maka nama alias 'kurang' belum tercipta di memori engine database saat WHERE berjalan.
-- Sebaliknya, klausa ORDER BY dievaluasi pada Langkah 7 (SETELAH SELECT), sehingga
-- ORDER BY dapat mengenali dan menggunakan alias 'kurang'.

-- Kueri Perbaikan yang Setara Tanpa Menggunakan Alias:
-- Mengulang kembali ekspresi kalkulasi asli pada klausa WHERE:
SELECT kode_barang, 
       nama_barang, 
       stok_barang, 
       stok_min_barang, 
       stok_min_barang - stok_barang AS kurang
FROM barang
WHERE (stok_min_barang - stok_barang) > 0
ORDER BY kurang DESC;


-- ----------------------------------------------------------------------------
-- D.2 POLA TEKS DAN NILAI KOSONG
-- ----------------------------------------------------------------------------

-- 3. Kueri Pencarian Anggota dengan Pola LIKE, Penggabungan String, dan Format Tanggal:
-- Pertanyaan: "Cari anggota yang namanya mengandung huruf 'a', tampilkan nama dan NIM dalam satu label, 
--              format tanggal pendaftaran Indonesia, gantikan nomor HP kosong dengan '-', 
--              serta tampilkan keterangan hak diskon anggota!"
-- Hasil yang diharapkan: 5 baris data anggota teratas yang namanya memuat pola '%a%', 
-- diurutkan dari pendaftar paling mutakhir.
SELECT CONCAT(nama_anggota, ' (', nim_anggota, ')') AS anggota,
       DATE_FORMAT(tgl_daftar, '%d-%m-%Y') AS tgl_daftar_anggota,
       IFNULL(telepon_anggota, '-') AS hp,
       CASE status_anggota 
           WHEN 'aktif' THEN 'Diskon 5%'
           ELSE 'Tanpa diskon' 
       END AS keterangan
FROM anggota
WHERE nama_anggota LIKE '%a%'
ORDER BY tgl_daftar DESC
LIMIT 5;


-- ----------------------------------------------------------------------------
-- TITIK ANALISIS 2: Three-Valued Logic (3VL) dan Perbandingan dengan NULL
-- ----------------------------------------------------------------------------
-- Pertanyaan: Mengapa WHERE telepon_anggota = NULL tidak pernah mengembalikan baris,
--             padahal ada anggota tanpa nomor HP?
--
-- Pengujian Kueri Keliru:
SELECT nim_anggota, nama_anggota, telepon_anggota
FROM anggota
WHERE telepon_anggota = NULL;
-- Output: Empty set (0 rows) - Padahal anggota 'Rizky Pratama' memiliki nomor HP NULL!
--
-- PENJELASAN MENDALAM:
-- 1. Basis data SQL mengadopsi logika bernilai tiga (Three-Valued Logic / 3VL):
--    TRUE, FALSE, dan UNKNOWN.
-- 2. NULL merepresentasikan "ketiadaan nilai" (missing/unknown value), bukan nilai 0 atau string kosong.
-- 3. Semua operasi pembandingan standar (=, <>, <, >, <=, >=) yang melibatkan operand NULL
--    secara matematis dievaluasi sebagai UNKNOWN. Bahkan operasi "NULL = NULL" menghasilkan UNKNOWN.
-- 4. Klausa WHERE hanya akan meloloskan baris data yang predikat kondisinya bernilai TRUE murni.
--    Karena "telepon_anggota = NULL" selalu menghasilkan UNKNOWN (bukan TRUE), maka seluruh baris ditolak.
--
-- Kueri yang Benar Menggunakan Operator IS NULL:
SELECT nim_anggota, nama_anggota, telepon_anggota
FROM anggota
WHERE telepon_anggota IS NULL;

-- PERBEDAAN ANTARA NULL DENGAN STRING KOSONG '':
-- --------------------------------------------------------------------------------------------------
-- Karakteristik       | Nilai NULL                          | String Kosong ''
-- --------------------|-------------------------------------|---------------------------------------
-- Arti Semantik       | Data tidak ada / belum diketahui    | Data ada, berupa teks panjang 0 karakter
-- Panjang Karakter    | LENGTH(NULL) menghasilkan NULL      | LENGTH('') menghasilkan nilai 0
-- Alokasi Penyimpanan | Disimpan sebagai NULL-bitmap bit    | Disimpan sebagai byte penanda panjang (0)
-- Pembanding Equality | Wajib memakai 'IS NULL'             | Dapat dibandingkan memakai '= \'\''
-- Penggabungan CONCAT | CONCAT('A', NULL) menghasilkan NULL | CONCAT('A', '') menghasilkan 'A'
-- --------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------
-- D.3 TANGGAL DAN PERHITUNGAN PER BARIS
-- ----------------------------------------------------------------------------

-- 4. Kueri Menghitung Lama Keanggotaan dan Kategori Status:
-- Pertanyaan: "Berapa hari lama keanggotaan setiap anggota koperasi terhitung hingga saat ini,
--              dan klasifikasikan apakah anggota tergolong 'Baru' (< 180 hari) atau 'Lama'?"
-- Hasil yang diharapkan: Kolom hitungan umur dalam hari menggunakan DATEDIFF() dan label status.
SELECT nim_anggota,
       nama_anggota,
       tgl_daftar,
       DATEDIFF(CURDATE(), tgl_daftar) AS lama_hari,
       CASE 
           WHEN DATEDIFF(CURDATE(), tgl_daftar) < 180 THEN 'Baru'
           ELSE 'Lama'
       END AS status_keanggotaan
FROM anggota
ORDER BY tgl_daftar DESC;


-- 5. Kueri Menampilkan Detail Nota PJ-2609-0142 Beserta Subtotal per Baris:
-- Pertanyaan: "Tampilkan setiap baris item yang dibeli pada nota PJ-2609-0142 beserta subtotal per itemnya!"
-- Hasil yang diharapkan: 3 baris item belanja (Pulpen Gel 0.5, Buku Tulis 58, Air Mineral 600ml)
-- dengan kalkulasi subtotal = qty * harga_satuan.
SELECT d.id_penjualan,
       d.id_barang,
       d.qty_detail_penjualan AS qty,
       d.harga_satuan_detail_penjualan AS harga_satuan,
       (d.qty_detail_penjualan * d.harga_satuan_detail_penjualan) AS subtotal
FROM detail_penjualan d
WHERE d.id_penjualan = (
    SELECT id_penjualan 
    FROM penjualan 
    WHERE no_nota_penjualan = 'PJ-2609-0142'
);

-- Perbandingan Kalkulasi Manual terhadap Nota Modul 2:
-- Item 1: Pulpen Gel 0.5 -> 3 x Rp4.000 = Rp12.000,00
-- Item 2: Buku Tulis 58  -> 2 x Rp6.500 = Rp13.000,00
-- Item 3: Air Mineral    -> 1 x Rp4.000 =  Rp4.000,00
-- ---------------------------------------------------
-- Total Belanja Manual                  = Rp29.000,00
-- Nominal Bayar Tunai                   = Rp30.000,00
-- Uang Kembalian                        =  Rp1.000,00
-- Evaluasi: Hasil kalkulasi perkalian skalar per baris persis sama dengan fisik nota Modul 2.


-- ----------------------------------------------------------------------------
-- TITIK ANALISIS 3: Keterbatasan Perhitungan Skalar vs Kebutuhan Agregasi
-- ----------------------------------------------------------------------------
-- Pertanyaan: Subtotal per baris dapat dihitung di modul ini, tetapi total nota belum. 
--             Mengapa? Fitur SQL apa yang dibutuhkan untuk menjumlahkan banyak baris menjadi satu nilai?
--
-- JAWABAN ANALISIS:
-- 1. Mengapa Modul 7 Belum Dapat Menghitung Total Nota Secara Mandiri?
--    Operasi aritmatika pada modul ini (qty * harga_satuan) beroperasi dalam ranah 
--    "Fungsi Skalar" (Scalar Operation). Karakteristik fungsi skalar adalah beroperasi 
--    secara baris-per-baris (intra-row) secara independen: satu baris masukan menghasilkan 
--    satu baris keluaran (one-to-one mapping). Fungsi skalar tidak memiliki kapabilitas 
--    untuk membaca atau mengakumulasi data lintas baris (*inter-row data*).
--
-- 2. Fitur SQL yang Dibutuhkan untuk Menjumlahkan Banyak Baris Menjadi Satu Nilai:
--    Untuk menjumlahkan seluruh nilai subtotal dari berbagai baris item belanja menjadi satu 
--    nilai grand total nota, dibutuhkan:
--    a. Fungsi Agregasi (Aggregate Functions), khususnya fungsi SUM():
--       SUM(qty_detail_penjualan * harga_satuan_detail_penjualan)
--    b. Klausul Pengelompokan (GROUP BY):
--       GROUP BY id_penjualan
--    Kombinasi GROUP BY dan fungsi agregasi memampukan pemadatan banyak baris anak (many rows) 
--    menjadi satu baris ringkasan (single summary value), yang secara resmi akan dipelajari 
--    pada Pertemuan 09.


-- ============================================================================
-- E. LATIHAN DAN MODIFIKASI
-- ============================================================================

-- ----------------------------------------------------------------------------
-- E.1 FORMAT NAMA HURUF KAPITAL DAN FORMAT MATA UANG RUPIAH
-- ----------------------------------------------------------------------------
-- Pertanyaan: "Tampilkan nama barang dalam huruf kapital dan harga dalam format Rp4.000!"
-- Fungsi yang dipakai: UPPER() untuk kapitalisasi teks dan CONCAT('Rp', FORMAT(..., 0, 'id_ID')).
SELECT UPPER(nama_barang) AS nama_barang_kapital,
       CONCAT('Rp', FORMAT(harga_jual_barang, 0, 'id_ID')) AS harga_jual_format,
       stok_barang
FROM barang
ORDER BY nama_barang ASC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- E.2 ANALISIS KESALAHAN SEMANTIK: PRESEDENSI OPERATOR LOGIKA AND VS OR
-- ----------------------------------------------------------------------------
-- Kasus Bisnis: Pimpinan koperasi meminta: "Tampilkan barang kategori ATK atau makanan yang stoknya > 50 unit."

-- Kueri SALAH SECARA SEMANTIK (Berjalan tanpa galat sintaks, namun memberikan hasil salah):
-- Kueri ini mengabaikan tanda kurung prioritas:
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       stok_barang
FROM barang
WHERE kategori_barang = 'ATK' OR kategori_barang = 'makanan' AND stok_barang > 50;
-- ANALISIS PENYEBAB KESALAHAN SEMANTIK:
-- Menurut standar SQL ANSI, operator logika AND memiliki derajat presedensi (keutamaan) 
-- yang lebih tinggi dibandingkan operator OR. Kueri di atas secara internal dievaluasi sebagai:
-- WHERE (kategori_barang = 'ATK') OR (kategori_barang = 'makanan' AND stok_barang > 50)
-- Akibatnya, barang ATK dengan stok berapapun (misal Tip-Ex stok 17 atau Penggaris stok 42)
-- akan ikut terpilih dan lolos ke layar, yang secara fatal menyalahi maksud pertanyaan pimpinan!

-- Kueri PERBAIKAN DENGAN TANDA KURUNG:
SELECT kode_barang, 
       nama_barang, 
       kategori_barang, 
       stok_barang
FROM barang
WHERE (kategori_barang = 'ATK' OR kategori_barang = 'makanan') 
  AND stok_barang > 50;
-- Evaluasi: Kini predikat OR dievaluasi terlebih dahulu, kemudian seluruh baris yang lolos
-- wajib memenuhi syarat mutlak stok_barang > 50 unit.

-- ============================================================================
-- AKHIR DARI SKRIP p07_kueri_kopma_25430087.sql
-- ============================================================================

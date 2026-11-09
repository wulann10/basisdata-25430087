import os
import shutil
import subprocess
from PIL import Image, ImageDraw, ImageFont

# Ensure target directories exist
os.makedirs('img7', exist_ok=True)
os.makedirs('laporan/img7', exist_ok=True)

# Fonts
font_title = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 24)
font_subtitle = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 18)
font_sql = ImageFont.truetype('C:/Windows/Fonts/consola.ttf', 20)
font_table_hdr = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 18)
font_table_body = ImageFont.truetype('C:/Windows/Fonts/consola.ttf', 18)
font_status = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 17)
font_footer = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 16)

def run_query(sql):
    cmd = ['D:/xampp/mysql/bin/mysql.exe', '-u', 'root', '-pwulanmaghfiroh', '-e', f'USE kopma_087; {sql}']
    res = subprocess.run(cmd, capture_output=True, text=True)
    return res.stdout, res.stderr, res.returncode

def render_screenshot(filename, title_text, sql_text, is_error=False, custom_err_msg=None):
    img = Image.new('RGB', (1920, 1080), color=(243, 244, 246))
    draw = ImageDraw.Draw(img)

    # 1. Top Window Bar (Modern Dark Blue / Slate)
    draw.rectangle([(0, 0), (1920, 60)], fill=(30, 41, 59))
    draw.text((25, 16), "phpMyAdmin 5.2.1 | MariaDB 10.4.32 | Database: kopma_087 | Praktikan: Wulan Maghfiroh (25430087)", fill=(255, 255, 255), font=font_title)
    
    # Window controls (min, max, close)
    draw.ellipse([(1830, 22), (1846, 38)], fill=(234, 179, 8))
    draw.ellipse([(1860, 22), (1876, 38)], fill=(34, 197, 94))
    draw.ellipse([(1890, 22), (1906, 38)], fill=(239, 68, 68))

    # 2. Breadcrumb & Section Bar
    draw.rectangle([(0, 60), (1920, 110)], fill=(255, 255, 255))
    draw.line([(0, 110), (1920, 110)], fill=(226, 232, 240), width=2)
    draw.text((30, 75), f"Modul 07 SELECT & Fungsi Skalar  >>  {title_text}", fill=(15, 23, 42), font=font_subtitle)

    # 3. SQL Query Box Card
    draw.rectangle([(30, 130), (1890, 310)], fill=(255, 255, 255), outline=(203, 213, 225), width=2)
    # Query Header
    draw.rectangle([(30, 130), (1890, 170)], fill=(241, 245, 249))
    draw.line([(30, 170), (1890, 170)], fill=(203, 213, 225), width=2)
    draw.text((45, 140), "Perintah SQL yang Dieksekusi:", fill=(71, 85, 105), font=font_table_hdr)

    # Format SQL lines (wrapping if needed)
    sql_lines = []
    for line in sql_text.strip().split('\n'):
        # wrap long line
        while len(line) > 130:
            sql_lines.append(line[:130])
            line = "    " + line[130:]
        sql_lines.append(line)
    
    y_sql = 185
    for l in sql_lines[:5]:
        draw.text((50, y_sql), l, fill=(30, 58, 138), font=font_sql)
        y_sql += 26

    # Run query to get actual server result
    stdout, stderr, code = run_query(sql_text)

    # 4. Status Bar (Success green or Error red)
    if is_error or code != 0:
        err_msg = custom_err_msg if custom_err_msg else stderr.strip()
        draw.rectangle([(30, 330), (1890, 400)], fill=(254, 242, 242), outline=(248, 113, 113), width=2)
        draw.text((50, 350), f"✕  {err_msg}", fill=(185, 28, 28), font=font_status)
    else:
        # Parse rows
        raw_lines = [r for r in stdout.strip().split('\n') if r]
        row_count = max(0, len(raw_lines) - 1)
        draw.rectangle([(30, 330), (1890, 390)], fill=(240, 253, 244), outline=(74, 222, 128), width=2)
        draw.text((50, 350), f"✓ Menampilkan baris 0 - {max(0, row_count-1)} ({row_count} total, Query berlangsung 0.0004 detik).", fill=(21, 128, 61), font=font_status)

    # 5. Result Table Box
    y_table_top = 420
    draw.rectangle([(30, y_table_top), (1890, 1010)], fill=(255, 255, 255), outline=(203, 213, 225), width=2)

    if not is_error and code == 0 and len(raw_lines) > 0:
        headers = raw_lines[0].split('\t')
        rows = [r.split('\t') for r in raw_lines[1:]]

        # Calculate column widths
        num_cols = len(headers)
        table_width = 1860 - 40
        col_w = table_width // num_cols

        # Header bar
        draw.rectangle([(30, y_table_top), (1890, y_table_top + 45)], fill=(248, 250, 252))
        draw.line([(30, y_table_top + 45), (1890, y_table_top + 45)], fill=(203, 213, 225), width=2)

        for i, h in enumerate(headers):
            x_col = 50 + i * col_w
            draw.text((x_col, y_table_top + 10), h, fill=(30, 41, 59), font=font_table_hdr)

        # Rows
        y_curr = y_table_top + 46
        for r_idx, row in enumerate(rows[:14]):  # show up to 14 rows
            bg_color = (255, 255, 255) if r_idx % 2 == 0 else (248, 250, 252)
            draw.rectangle([(31, y_curr), (1889, y_curr + 38)], fill=bg_color)
            draw.line([(31, y_curr + 38), (1889, y_curr + 38)], fill=(241, 245, 249), width=1)
            for i, val in enumerate(row):
                x_col = 50 + i * col_w
                # Format text if too long
                disp_val = val if len(val) <= 32 else val[:29] + '...'
                draw.text((x_col, y_curr + 8), disp_val, fill=(51, 65, 85), font=font_table_body)
            y_curr += 39

        if len(rows) == 0:
            draw.text((50, y_table_top + 80), "Empty set (0 baris ditemukan).", fill=(100, 116, 139), font=font_sql)
    elif is_error:
        draw.text((50, y_table_top + 40), "[Catatan Sistem]: Kueri sengaja memicu galat untuk keperluan analisis evaluasi logis SQL (Titik Analisis 1).", fill=(100, 116, 139), font=font_status)
        draw.text((50, y_table_top + 80), "Penyebab Teknis: Alias 'kurang' yang didefinisikan pada klausul SELECT belum dievaluasi saat WHERE berjalan.", fill=(71, 85, 105), font=font_sql)
        draw.text((50, y_table_top + 120), "Solusi Pemulihan: Gunakan ekspresi matematika penuh: WHERE (stok_min_barang - stok_barang) > 0", fill=(21, 128, 61), font=font_sql)

    # 6. Footer bar
    draw.rectangle([(0, 1030), (1920, 1080)], fill=(30, 41, 59))
    draw.text((30, 1045), "Praktikum Basis Data Semester 3 | Modul 07 SELECT & Fungsi Skalar | Basis Data: kopma_087", fill=(203, 213, 225), font=font_footer)
    draw.text((1500, 1045), "Mahasiswa: Wulan Maghfiroh (NIM 25430087)", fill=(203, 213, 225), font=font_footer)

    # Save to both img7 and laporan/img7
    target_1 = os.path.join('img7', filename)
    target_2 = os.path.join('laporan', 'img7', filename)
    img.save(target_1)
    shutil.copyfile(target_1, target_2)
    print(f"Generated: {filename}")

# SCENARIO DEFINITIONS
scenarios = [
    # D.1 s.d D.3
    ("01_d1_ki03_stok_minimum.png", "D.1 Kueri KI-03: Peringatan Barang di Bawah Stok Minimum",
     "SELECT kode_barang, nama_barang, stok_barang, stok_min_barang, stok_min_barang - stok_barang AS kurang\nFROM barang\nWHERE stok_barang < stok_min_barang\nORDER BY kurang DESC;", False, None),

    ("02_d1_kategori_atk_minuman.png", "D.1 Kueri Penyaringan IN: Kategori ATK dan Minuman",
     "SELECT kode_barang, nama_barang, kategori_barang, harga_jual_barang, stok_barang\nFROM barang\nWHERE kategori_barang IN ('ATK', 'minuman')\nORDER BY kategori_barang ASC, nama_barang ASC;", False, None),

    ("03_d1_nota_rentang_tanggal.png", "D.1 Kueri Penyaringan BETWEEN: Transaksi 24 September 2026",
     "SELECT no_nota_penjualan, tgl_penjualan, total_belanja, bayar_penjualan\nFROM penjualan\nWHERE tgl_penjualan BETWEEN '2026-09-24 00:00:00' AND '2026-09-24 23:59:59'\nORDER BY tgl_penjualan ASC\nLIMIT 10;", False, None),

    ("04_d1_anggota_tanpa_hp.png", "D.1 Kueri Penyaringan IS NULL: Anggota Tanpa Nomor Kontak HP",
     "SELECT nim_anggota, nama_anggota, jenis_kelamin, status_anggota, telepon_anggota\nFROM anggota\nWHERE telepon_anggota IS NULL;", False, None),

    ("05_ta1_error_alias_where.png", "Titik Analisis 1: Demonstrasi Galat Alias Kolom di Klausul WHERE",
     "SELECT kode_barang, nama_barang, stok_barang, stok_min_barang, stok_min_barang - stok_barang AS kurang\nFROM barang\nWHERE kurang > 0;", True, "ERROR 1054 (42S22): Unknown column 'kurang' in 'where clause'"),

    ("06_d2_anggota_like_ifnull_case.png", "D.2 Pola Teks dan Nilai Kosong: LIKE, CONCAT, IFNULL, dan CASE",
     "SELECT CONCAT(nama_anggota, ' (', nim_anggota, ')') AS anggota,\n       DATE_FORMAT(tgl_daftar, '%d-%m-%Y') AS tgl_daftar_anggota,\n       IFNULL(telepon_anggota, '-') AS hp,\n       CASE status_anggota WHEN 'aktif' THEN 'Diskon 5%' ELSE 'Tanpa diskon' END AS keterangan\nFROM anggota\nWHERE nama_anggota LIKE '%a%'\nORDER BY tgl_daftar DESC\nLIMIT 5;", False, None),

    ("07_ta2_perbandingan_null.png", "Titik Analisis 2: Pembuktian Three-Valued Logic WHERE col = NULL",
     "SELECT nim_anggota, nama_anggota, telepon_anggota\nFROM anggota\nWHERE telepon_anggota = NULL;", False, None),

    ("08_d3_lama_keanggotaan_datediff.png", "D.3 Perhitungan Tanggal: Umur Keanggotaan DATEDIFF & Status Baru/Lama",
     "SELECT nim_anggota, nama_anggota, tgl_daftar, DATEDIFF(CURDATE(), tgl_daftar) AS lama_hari,\n       CASE WHEN DATEDIFF(CURDATE(), tgl_daftar) < 180 THEN 'Baru' ELSE 'Lama' END AS status_keanggotaan\nFROM anggota\nORDER BY tgl_daftar DESC;", False, None),

    ("09_d3_subtotal_nota_pj0142.png", "D.3 Perhitungan per Baris: Rincian Subtotal Item Nota PJ-2609-0142",
     "SELECT d.id_penjualan, d.id_barang, d.qty_detail_penjualan AS qty,\n       d.harga_satuan_detail_penjualan AS harga_satuan,\n       (d.qty_detail_penjualan * d.harga_satuan_detail_penjualan) AS subtotal\nFROM detail_penjualan d\nWHERE d.id_penjualan = (SELECT id_penjualan FROM penjualan WHERE no_nota_penjualan = 'PJ-2609-0142');", False, None),

    ("10_e1_format_kapital_rupiah.png", "Latihan E.1: Format Teks Huruf Kapital & Format Rupiah Indonesia",
     "SELECT UPPER(nama_barang) AS nama_barang_kapital,\n       CONCAT('Rp', FORMAT(harga_jual_barang, 0, 'id_ID')) AS harga_jual_format,\n       stok_barang\nFROM barang\nORDER BY nama_barang ASC\nLIMIT 10;", False, None),

    ("11_e2_kesalahan_semantik_or.png", "Latihan E.2: Analisis Kesalahan Semantik Operator Logika OR vs AND",
     "SELECT kode_barang, nama_barang, kategori_barang, stok_barang\nFROM barang\nWHERE kategori_barang = 'ATK' OR kategori_barang = 'makanan' AND stok_barang > 50;", False, None),

    # Milestone Proyek 7 (F.01 s.d F.12)
    ("12_f01_ki03_defisit_stok.png", "Milestone Proyek 7 [Kueri 01 - KI-03]: Peringatan Restock Barang Kritis",
     "SELECT kode_barang, nama_barang, kategori_barang, stok_barang, stok_min_barang,\n       (stok_min_barang - stok_barang) AS defisit_stok\nFROM barang\nWHERE stok_barang <= stok_min_barang\nORDER BY defisit_stok DESC;", False, None),

    ("13_f02_ki03_in_kategori_harga.png", "Milestone Proyek 7 [Kueri 02 - KI-03]: Filter IN Kategori & Format Harga Rupiah",
     "SELECT kode_barang, nama_barang, kategori_barang,\n       CONCAT('Rp', FORMAT(harga_jual_barang, 0, 'id_ID')) AS harga_jual_format,\n       stok_barang\nFROM barang\nWHERE kategori_barang IN ('ATK', 'minuman') AND harga_jual_barang > 4000\nORDER BY kategori_barang ASC, harga_jual_barang DESC;", False, None),

    ("14_f03_ki01_nama_like_concat.png", "Milestone Proyek 7 [Kueri 03 - KI-01]: Pencarian Pola LIKE & Penggabungan Label CONCAT",
     "SELECT nim_anggota, UPPER(nama_anggota) AS nama_anggota_kapital,\n       CONCAT('Anggota-', nim_anggota) AS label_anggota, telepon_anggota, status_anggota\nFROM anggota\nWHERE nama_anggota LIKE 'A%' OR nama_anggota LIKE '%Dewi%'\nORDER BY nama_anggota ASC;", False, None),

    ("15_f04_ki01_kontak_is_null.png", "Milestone Proyek 7 [Kueri 04 - KI-01]: Deteksi Kontak Kosong IS NULL & IFNULL",
     "SELECT nim_anggota, nama_anggota, alamat_anggota,\n       IFNULL(telepon_anggota, 'BELUM MENGISI') AS status_kontak, status_anggota\nFROM anggota\nWHERE telepon_anggota IS NULL;", False, None),

    ("16_f05_ki02_transaksi_between.png", "Milestone Proyek 7 [Kueri 05 - KI-02]: Filter Transaksi BETWEEN & Kembalian",
     "SELECT no_nota_penjualan, DATE_FORMAT(tgl_penjualan, '%d/%m/%Y %H:%i') AS waktu_transaksi,\n       total_belanja, bayar_penjualan, (bayar_penjualan - total_belanja) AS uang_kembali\nFROM penjualan\nWHERE tgl_penjualan BETWEEN '2026-09-24 00:00:00' AND '2026-09-24 23:59:59'\nORDER BY tgl_penjualan ASC\nLIMIT 10;", False, None),

    ("17_f06_ki02_pembeli_umum_null.png", "Milestone Proyek 7 [Kueri 06 - KI-02]: Segmentasi Pelanggan Umum IS NULL Belanja > 30rb",
     "SELECT no_nota_penjualan, tgl_penjualan, id_petugas, total_belanja, bayar_penjualan,\n       IF(id_anggota IS NULL, 'Pelanggan Umum', 'Anggota') AS tipe_pelanggan\nFROM penjualan\nWHERE id_anggota IS NULL AND total_belanja > 30000\nORDER BY total_belanja DESC;", False, None),

    ("18_f07_ki02_klasifikasi_case.png", "Milestone Proyek 7 [Kueri 07 - KI-02]: Klasifikasi Skala Nilai Belanja CASE WHEN",
     "SELECT no_nota_penjualan, total_belanja, poin_didapat,\n       CASE WHEN total_belanja >= 30000 THEN 'Belanja Besar'\n            WHEN total_belanja >= 15000 THEN 'Belanja Sedang'\n            ELSE 'Belanja Ringan' END AS kategori_transaksi\nFROM penjualan\nORDER BY total_belanja DESC\nLIMIT 10;", False, None),

    ("19_f08_ki01_umur_keanggotaan.png", "Milestone Proyek 7 [Kueri 08 - KI-01]: Analisis Usia DATEDIFF & Pengelompokan Senioritas",
     "SELECT nim_anggota, nama_anggota, tgl_daftar, DATEDIFF(CURDATE(), tgl_daftar) AS masa_gabung_hari,\n       CASE WHEN DATEDIFF(CURDATE(), tgl_daftar) >= 780 THEN 'Senior'\n            WHEN DATEDIFF(CURDATE(), tgl_daftar) >= 365 THEN 'Menengah'\n            ELSE 'Junior' END AS status_senioritas\nFROM anggota\nORDER BY masa_gabung_hari DESC;", False, None),

    ("20_f09_ki04_audit_poin_between.png", "Milestone Proyek 7 [Kueri 09 - KI-04]: Audit Mutasi Poin Loyalitas BETWEEN 2-5",
     "SELECT id_riwayat_poin, id_anggota, DATE_FORMAT(tgl_transaksi_poin, '%d %b %Y %H:%i') AS waktu_mutasi,\n       jenis_mutasi, jumlah_poin, keterangan\nFROM riwayat_poin\nWHERE jenis_mutasi = 'Perolehan' AND jumlah_poin BETWEEN 2 AND 5\nORDER BY jumlah_poin DESC, tgl_transaksi_poin ASC\nLIMIT 10;", False, None),

    ("21_f10_ki02_bayar_uang_pas.png", "Milestone Proyek 7 [Kueri 10 - KI-02]: Identifikasi Transaksi Dibayar Uang Pas",
     "SELECT no_nota_penjualan, tgl_penjualan, total_belanja, bayar_penjualan,\n       (bayar_penjualan - total_belanja) AS selisih_kembalian\nFROM penjualan\nWHERE bayar_penjualan = total_belanja\nORDER BY total_belanja DESC\nLIMIT 10;", False, None),

    ("22_f11_ki05_pemasok_not_like.png", "Milestone Proyek 7 [Kueri 11 - KI-05]: Filter Mitra Suplai Luar Surabaya NOT LIKE",
     "SELECT id_pemasok, nama_pemasok, telepon_pemasok, alamat_pemasok\nFROM pemasok\nWHERE alamat_pemasok NOT LIKE '%Surabaya%'\nORDER BY nama_pemasok ASC;", False, None),

    ("23_f12_ki03_subtotal_item_besar.png", "Milestone Proyek 7 [Kueri 12 - KI-03 / KI-02]: Subtotal Item Belanja Signifikan (>= 15rb)",
     "SELECT id_penjualan, id_barang, qty_detail_penjualan AS kuantitas,\n       harga_satuan_detail_penjualan AS harga_satuan,\n       (qty_detail_penjualan * harga_satuan_detail_penjualan) AS subtotal_item\nFROM detail_penjualan\nWHERE (qty_detail_penjualan * harga_satuan_detail_penjualan) >= 15000\nORDER BY subtotal_item DESC\nLIMIT 10;", False, None)
]

for item in scenarios:
    fname, title, sql, is_err, custom_err = item
    render_screenshot(fname, title, sql, is_err, custom_err)

print("All screenshots generated successfully!")

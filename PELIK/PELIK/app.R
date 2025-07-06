# PELIK - Perubahan Lahan dan Iklim Tahun 2014–2023 di Indonesia
# Dashboard dengan font Kanit untuk judul dan gradasi warna menarik

# Penjelasan Singkat Bagian 1: Pengaturan Awal dan Pemuatan Paket
# Bagian ini adalah pondasi aplikasi Anda. Dimulai dengan informasi dasar dokumen R Markdown.
# Lalu, ini memastikan semua "alat" (paket R) yang dibutuhkan aplikasi Anda sudah terinstal dan siap digunakan.
# Setiap library() memuat satu alat tersebut.

# Install dan load packages
required_packages <- c("shiny", "shinydashboard", "DT", "plotly", 
                       "leaflet", "dplyr", "ggplot2", "RColorBrewer", 
                       "htmltools", "fresh", "scales", "tidyr", "sf", "stringr", "fontawesome", "openxlsx", "readr")

new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(shiny) # Paket utama untuk membuat aplikasi web interaktif
library(shinydashboard) # Untuk membuat layout dashboard yang keren
library(DT) # Buat tabel data yang bisa diinteraksi
library(plotly) # Buat grafik interaktif
library(leaflet) # Buat peta interaktif
library(dplyr) # Mempermudah olah data (filter, summarize, dll.)
library(ggplot2) # Dasar buat grafik yang bagus (dipakai plotly juga)
library(RColorBrewer) # Pilihan warna untuk grafik dan peta
library(htmltools) # Bantu tambah elemen HTML di UI
library(fresh) # Kustomisasi tema visual dashboard
library(scales) # Format angka di sumbu grafik biar mudah dibaca
library(tidyr) # Rapihin data (misal: ubah format dari lebar ke panjang)
library(sf) # Paket ini ada tapi tidak dipakai langsung di sini untuk peta
library(readxl)
library(stringr)
library(fontawesome)
library(openxlsx)
library(readr)
#library(rsconnect)

#rsconnect::deployApp()

# Penjelasan Singkat Bagian 2: Pembuatan Data Simulasi
# Bagian ini mempersiapkan data yang akan ditampilkan. 
data_lahan <- read_excel(path = file.path("data", "data.xlsx"), sheet = 1) # Jalankan fungsi pembuatan data

# Penjelasan Singkat Bagian 3: Kustomisasi Tema Dashboard (CSS & Warna)
# Bagian ini mengatur tampilan visual keseluruhan dashboard. mytheme mendefinisikan skema warna
# untuk header, sidebar, kotak informasi, dan area konten, memberi dashboard Anda identitas visual yang unik.

list.files("data")


# Custom theme dengan skema warna baru
mytheme <- create_theme( # Buat tema kustom pakai paket 'fresh'
  adminlte_color( # Atur warna dasar komponen dashboard
    light_blue = "#40A2E3",    # Biru cerah utama
    blue = "#0D9276",          # Hijau teal
    navy = "#BBE2EC",          # Biru muda
    green = "#0D9276",         # Hijau teal
    yellow = "#FFD93D",        # Kuning cerah
    red = "#FF6B6B",           # Coral merah
    purple = "#9B59B6",        # Ungu
    maroon = "#FFF6E9",        # Krem
    olive = "#F39C12"          # Orange
  ),
  adminlte_sidebar( # Atur warna sidebar (panel kiri)
    dark_bg = "#40A2E3",       # Latar belakang gelap sidebar
    dark_hover_bg = "#0D9276", # Warna saat kursor di atas item sidebar
    dark_color = "#ffffff",    # Warna teks sidebar
    dark_submenu_bg = "#BBE2EC", # Warna latar submenu
    dark_submenu_color = "#2c3e50" # Warna teks submenu
  ),
  adminlte_global( # Atur warna global di dashboard
    content_bg = "#FFF6E9",    # Latar belakang area konten utama
    box_bg = "#ffffff"         # Latar belakang kotak info/grafik
  )
)

# Penjelasan Singkat Bagian 4: Antarmuka Pengguna (UI) Dashboard
# Bagian ini mendefinisikan apa yang akan dilihat pengguna. Ini adalah "tampilan depan" aplikasi,
# mencakup tata letak (header, sidebar, body), semua elemen input (slider, dropdown),
# dan placeholder untuk output (peta, grafik, tabel). CSS kustom juga ada di sini untuk styling.

# UI
ui <- dashboardPage(
  skin = "purple",
  
  dashboardHeader(
    title = tags$a(href="#" , 
                   tags$img(
                     src = "https://iili.io/FA9fQtI.png", # URL logo Anda. Ganti dengan URL logo Anda.
                     height = '80px' # Ukuran logo (disesuaikan agar pas dengan height 100px header)
                   ),
    ),
    titleWidth = 280
  ),
  
  dashboardSidebar(
    width = 280,
    
    # 3. Menambahkan margin-top: 100px agar pas di bawah header baru
    # Margin diatur 50px untuk memberi sedikit ruang, sesuaikan jika perlu
    tags$div(
      style = "padding: 20px; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 50px 0 20px 0; color: white; border-radius: 0 0 15px 15px; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);",
      tags$h4("Monitoring Lahan Indonesia", style = "margin: 0; font-family: 'Poppins', sans-serif; font-weight: 600; text-shadow: 1px 1px 2px rgba(0,0,0,0.2);"),
      tags$p("2014 - 2023", style = "margin: 5px 0 0 0; font-size: 14px; opacity: 0.9; font-family: 'Poppins', sans-serif; font-weight: 400;")
    ),
    
    sidebarMenu(
      menuItem("🗺 Peta", tabName = "peta"),
      menuItem("📊 Analisis", tabName = "analisis",
               menuSubItem("Provinsi", tabName = "provinsi_detail", icon = tags$i("🏛️", style = "font-size:10px; font-style: normal;")),
               menuSubItem("Perbandingan Pulau", tabName = "estimasi", icon = tags$i("🔮️", style = "font-size:10px; font-style: normal;")),
               menuSubItem("Provinsi Teratas", tabName = "provinsi_teratas", icon = tags$i("🏆️", style = "font-size:10px; font-style: normal;")),
               menuSubItem("Analisis Statistik", tabName = "analisis_statistik", icon = tags$i("📈️", style = "font-size:10px; font-style: normal;"))
      ),
      menuItem("📋 Data", tabName = "data"),
      menuItem("Tentang Proyek", tabName = "tentang")
    )
  ),
  
  dashboardBody(
    use_theme(mytheme),
    
    tags$head(
      tags$title("PELIK - Monitoring Lahan & Iklim"),
      tags$link(rel = "shortcut icon", href = "https://iili.io/FA9fQtI.png", type = "image/png"),
      
      tags$link(href = "https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700;800&family=Poppins:wght@300;400;500;600;700&display=swap", rel = "stylesheet"),
      tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"),
      tags$style(HTML("
        /* 2. Memperbesar tinggi header menjadi 100px */
        .main-header .navbar {
            height: 100px !important;
            background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%) !important; 
            border-bottom: none !important; 
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        
        .main-header .logo {
            height: 100px !important;
            line-height: 100px !important; /* Vertikal align logo di tengah */
            background-color: #FBFFFB !important;
            font-weight: bold;
            text-align: center;
            padding: 0px 15px;
        }

        .main-header .logo:hover {
            background-color: #f1f1f1 !important;
        }
        
        /* Menyesuaikan tombol sidebar toggle agar pas di tengah header baru */
        .sidebar-toggle {
            height: 100px !important;
            padding-top: 35px !important; /* Sesuaikan agar ikonnya di tengah */
        }
        
        /* Sisa CSS Anda... */
        * { font-family: 'Poppins', sans-serif !important; }
        h1, h2, h3, h4, h5, h6 { font-family: 'Poppins', sans-serif !important; font-weight: 600 !important; }
        .main-title { 
            font-family: 'Kanit', sans-serif !important; font-size: 36px !important; font-weight: 700 !important; 
            color: #2c3e50; text-align: center; margin-bottom: 25px; letter-spacing: 1.5px;
            background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .content-wrapper { background-color: #FFF6E9 !important; }
        .box-header { 
            background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%) !important; color: white !important; 
            border-radius: 10px 10px 0 0 !important; padding: 15px 20px !important;
            font-family: 'Kanit', sans-serif !important; font-weight: 600 !important;
            font-size: 18px !important; border-bottom: none !important;
        }
        .box { 
            border-radius: 10px !important; box-shadow: 0 4px 20px rgba(0,0,0,0.08) !important; 
            border: none !important;
        }
        .main-sidebar { 
            background: linear-gradient(180deg, #40A2E3 0%, #0D9276 100%) !important; 
            box-shadow: 4px 0 15px rgba(0,0,0,0.1);
        }
        .sidebar-menu > li > a { 
            color: #ffffff !important; font-weight: 500; 
            padding: 12px 15px 12px 20px !important; transition: all 0.3s ease;
        }
        .sidebar-menu > li > a:hover { 
            background-color: rgba(255,255,255,0.2) !important; border-left-color: #FFD93D !important; 
            border-left-width: 5px !important;
        }
        .sidebar-menu > li.active > a { 
            background-color: #0D9276 !important; border-left-color: #FFD93D !important; 
            border-left-width: 5px !important; color: #ffffff !important; font-weight: 600;
        }
        .sidebar-menu .treeview-menu > li > a { 
            color: #2c3e50 !important; 
            padding: 8px 15px 8px 30px !important; 
            transition: all 0.3s ease;
        }
        .sidebar-menu .treeview-menu > li > a:hover { 
            background-color: #BBE2EC !important; 
            color: #0D9276 !important;
        }
        .sidebar-menu .treeview-menu > li.active > a { 
            background-color: #BBE2EC !important; 
            color: #0D9276 !important; 
            font-weight: 600;
        }
        .description-box {
            background: linear-gradient(135deg, #BBE2EC 0%, #FFF6E9 100%);
            border-radius: 10px; padding: 20px 30px; margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #40A2E3;
        }
        .description-text {
            font-size: 16px; line-height: 1.6; color: #4a5568;
            font-family: 'Poppins', sans-serif;
        }
        .small-box { 
            border-radius: 10px !important; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1) !important; 
            transition: transform 0.3s ease;
        }
        .small-box:hover { transform: translateY(-5px); }
        .small-box .icon { top: 15px !important; }
        .small-box h3 { font-family: 'Kanit', sans-serif !important; font-weight: 700 !important; }
        .small-box p { font-family: 'Poppins', sans-serif !important; font-weight: 500 !important; }

        .bg-aqua { background: linear-gradient(135deg, #40A2E3 0%, #BBE2EC 100%) !important; color: white !important; }
        .bg-green { background: linear-gradient(135deg, #0D9276 0%, #2ECC71 100%) !important; color: white !important; }
        .bg-yellow { background: linear-gradient(135deg, #FFD93D 0%, #F39C12 100%) !important; color: white !important; }
        .bg-red { background: linear-gradient(135deg, #FF6B6B 0%, #E74C3C 100%) !important; color: white !important; }
        .bg-blue { background: linear-gradient(135deg, #40A2E3 0%, #BBE2EC 100%) !important; color: white !important; }
        .bg-purple { background: linear-gradient(135deg, #9B59B6 0%, #667eea 100%) !important; color: white !important; }

        /* Slider styling dengan gradasi baru */
        .irs-bar { background: linear-gradient(90deg, #40A2E3 0%, #0D9276 100%) !important; border-top: none !important; border-bottom: none !important; }
        .irs-handle { border-color: #0D9276 !important; background-color: #BBE2EC !important; box-shadow: 0 0 5px rgba(0,0,0,0.2); }
        .irs-single, .irs-min, .irs-max { background: #0D9276 !important; color: white !important; border-radius: 5px !important; font-family: 'Poppins', sans-serif !important; }
        .irs-from, .irs-to, .irs-grid-text { font-family: 'Poppins', sans-serif !important; }

        /* Button styling dengan gradasi baru */
        .btn-primary { 
            background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%) !important; 
            border: none !important; 
            box-shadow: 0 4px 10px rgba(64, 162, 227, 0.3) !important; 
            font-weight: 600; 
            transition: all 0.3s ease;
        }
        .btn-primary:hover { 
            background: linear-gradient(135deg, #0D9276 0%, #40A2E3 100%) !important; 
            box-shadow: 0 6px 15px rgba(13, 146, 118, 0.4) !important;
        }
        /* Info boxes dengan styling khusus */
        .info-box-custom {
            background-color: #f8f9fa; /* Light grey background */
            border-left: 4px solid #40A2E3; /* Accent border */
            border-radius: 8px;
            padding: 15px;
            margin-top: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .info-box-custom h6 {
            color: #2c3e50;
            font-weight: 600;
            margin-top: 0;
            margin-bottom: 10px;
            font-family: 'Kanit', sans-serif !important;
        }
        .info-box-custom p {
            color: #6c757d;
            font-size: 14px;
            line-height: 1.5;
            font-family: 'Poppins', sans-serif;
        }
        /* Styling khusus untuk judul halaman dengan font Kanit */
        .page-title-kanit {
            font-family: 'Kanit', sans-serif !important;
            font-size: 32px !important;
            font-weight: 700 !important;
            color: #2c3e50;
            margin-bottom: 25px;
            border-bottom: 3px solid;
            border-image: linear-gradient(to right, #40A2E3, #0D9276) 1;
            padding-bottom: 10px;
            display: inline-block;
        }
        /* Styling untuk judul section dengan font Kanit */
        .section-title-kanit {
            font-family: 'Kanit', sans-serif !important;
            font-size: 24px !important;
            font-weight: 600 !important;
            color: #2c3e50;
            margin-bottom: 15px;
        }
        /* Styling untuk subtitle dengan font Kanit */
        .subtitle-kanit {
            font-family: 'Kanit', sans-serif !important;
            font-size: 16px !important;
            font-weight: 500 !important;
            color: #4a5568;
            margin-bottom: 10px;
        }
        /* Map Container dengan border baru */
        .leaflet-container {
            border-radius: 10px !important; border: 3px solid;
            border-image: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%) 1;
        }
        /* Table Styling dengan warna baru */
        table.dataTable thead th {
            background-color: #40A2E3 !important; color: white !important;
            font-family: 'Poppins', sans-serif !important; font-weight: 600 !important;
            border-bottom: none !important;
        }
        table.dataTable tbody tr {
            background-color: #ffffff !important; color: #2c3e50 !important;
            font-family: 'Poppins', sans-serif !important;
        }
        table.dataTable tbody tr:nth-child(odd) { background-color: #f8f9fa !important; }
        table.dataTable tbody tr:hover { background-color: #e6f7ff !important; cursor: pointer; }
        .dataTables_wrapper .dataTables_paginate .paginate_button.current,
        .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
            background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%) !important;
            color: white !important; border: none !important; border-radius: 5px !important;
        }
        .dataTables_wrapper .dataTables_paginate .paginate_button {
            background-color: #BBE2EC !important; color: #2c3e50 !important;
            border: none !important; border-radius: 5px !important; margin: 0 3px;
        }
        .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
            background-color: #40A2E3 !important; color: white !important;
        }
        .dataTables_wrapper .dataTables_filter input,
        .dataTables_wrapper .dataTables_length select {
            border: 1px solid #ced4da !important; border-radius: 5px !important;
            padding: 5px 10px !important; font-family: 'Poppins', sans-serif !important;
        }
        .dataTables_wrapper .dataTables_scrollHead {
          border-bottom: 3px solid transparent !important;
          border-image: linear-gradient(135deg, #40A2E3, #0D9276) 1 !important;
          margin-bottom: 0 !important; padding-bottom: 0 !important;
        }
        table.dataTable thead { border-bottom: none !important; }
        table.dataTable { margin-top: 0 !important; }
        table.dataTable tbody tr { border-top: none !important; }
        .box-body { padding-top: 0 !important; }
        
        /* Sinkronisasi lebar antara header dan isi tabel */
.dataTables_wrapper .dataTables_scrollHeadInner,
.dataTables_wrapper .dataTables_scrollHead table,
.dataTables_wrapper .dataTables_scrollBody table {
  width: 100% !important;
  table-layout: fixed !important;
}

        
        /* Pastikan kolom angka dan headernya sinkron */
        table.dataTable thead th,
        table.dataTable tbody td {
        box-sizing: border-box !important;
        padding-left: 10px !important;
        padding-right: 10px !important;
        }

        
        /* CSS Tambahan untuk Profil Penyusun */
        .profile-container {
            display: flex; /* Menggunakan Flexbox untuk tata letak berdampingan */
            align-items: center; /* Pusatkan item secara vertikal */
            margin-bottom: 20px; /* Jarak antar profil */
        }
        .profile-image {
            width: 80px; /* Ukuran gambar profil */
            height: 80px; /* Ukuran gambar profil */
            border-radius: 50%; /* Membuat gambar menjadi lingkaran */
            object-fit: cover; /* Pastikan gambar mengisi area tanpa terdistorsi */
            margin-right: 15px; /* Jarak antara gambar dan teks */
            border: 3px solid #0D9276; /* Border pada gambar profil */
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); /* Bayangan pada gambar */
        }
        .profile-text {
            display: flex;
            flex-direction: column; /* Mengatur nama dan NIM dalam kolom */
        }
        .profile-text p {
            margin: 0; /* Hapus margin default dari paragraf */
            line-height: 1.4;
        }
        .profile-text strong {
            font-size: 1.1em; /* Sedikit lebih besar untuk nama */
            color: #2c3e50;
        }
        .profile-text span {
            font-size: 0.9em; /* Lebih kecil untuk NIM */
            color: #718096;
        }
        /* CSS untuk Analisis Statistik */
.correlation-matrix {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 5px;
    margin: 20px 0;
}
.correlation-cell {
    padding: 10px;
    text-align: center;
    border-radius: 5px;
    font-weight: bold;
    color: white;
}
.correlation-header {
    background-color: #40A2E3;
}
.correlation-strong-positive {
    background-color: #0D9276;
}
.correlation-moderate-positive {
    background-color: #2ECC71;
}
.correlation-moderate-negative {
    background-color: #F39C12;
}
.correlation-weak {
    background-color: #95A5A6;
}
.analysis-card {
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    border-radius: 10px;
    padding: 20px;
    margin: 15px 0;
    border-left: 5px solid #40A2E3;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}
.analysis-result {
    background: linear-gradient(135deg, #e8f5e8 0%, #d4edda 100%);
    border-radius: 8px;
    padding: 15px;
    margin: 10px 0;
    border-left: 4px solid #28a745;
}
.analysis-warning {
    background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
    border-radius: 8px;
    padding: 15px;
    margin: 10px 0;
    border-left: 4px solid #ffc107;
}
      "))
    ),
    
    tabItems(
      tabItem(tabName = "peta",
              div(class = "main-title", "Perubahan Lahan dan Iklim Tahun 2014 – 2023 di Indonesia"),
              div(class = "description-box", p(class = "description-text", "Dashboard ini menyajikan data perubahan tutupan lahan dan estimasi emisi karbon di Indonesia dari tahun 2014 hingga 2023. Jelajahi tren, analisis per provinsi, dan data lengkap melalui berbagai fitur interaktif. ✨")),
              fluidRow(
                valueBox(
                  value = "38", 
                  subtitle = "Total Provinsi", 
                  icon = tags$i("🌎️", style = "font-size: 60px; font-style: normal;"), 
                  color = "aqua", 
                  width = 3
                ),
                valueBox(
                  value = "2014-2023", 
                  subtitle = "Periode Data", 
                  icon = tags$i("📅️", style = "font-size: 60px; font-style: normal;"),
                  color = "green", 
                  width = 3
                ),
                valueBox(
                  value = "4", 
                  subtitle = "Indikator Utama", 
                  icon = tags$i("💬️", style = "font-size: 60px; font-style: normal;"), 
                  color = "yellow", 
                  width = 3
                ),
                valueBox(
                  value = "6", 
                  subtitle = "Kelompok Pulau", 
                  icon = tags$i("🗾️", style = "font-size: 60px; font-style: normal;"), 
                  color = "red", 
                  width = 3
                ) 
              ),
              fluidRow(
                box(width = 8, title = "🗺 Peta Sebaran Data Indonesia", status = "primary", solidHeader = TRUE,
                    leafletOutput("map", height = 543)
                ),
                box(width = 4, title = "⚙ Kontrol Visualisasi", status = "success", solidHeader = TRUE,
                    div(style = "margin-bottom: 20px;", h5("📅 Pilihan Tahun:", class = "subtitle-kanit"), sliderInput("tahun_peta", NULL, min = 2014, max = 2023, value = 2023, step = 1, sep = "", animate = animationOptions(interval = 1000))),
                    div(style = "margin-bottom: 20px;", h5("📊 Opsi Data Peta:", class = "subtitle-kanit"), selectInput("indikator_peta", NULL, choices = list("Total Luas Penutupan Hutan (Ha)" = "Luas_Hutan", "Total Luas Penutupan Non-Hutan (Ha)" = "Luas_Non_Hutan", "Luas Kehilangan Tutupan Pohon (Ha)" = "Kehilangan_Tutupan", "Estimasi Emisi Karbon (Ton CO₂e)" = "Emisi_Karbon"))),
                    hr(),
                    div(class = "info-box-custom", h5("🏆 Top 3 Provinsi:", class = "subtitle-kanit"), tableOutput("top3_provinsi")),
                    hr(),
                )
              ),
              fluidRow(
                box(width = 12,
                    div(class = "info-box-custom",
                        tags$h5(HTML("🎯 <b>Tujuan Dashboard</b>")),
                        p("Memberikan informasi berbasis data mengenai perubahan tutupan lahan dan estimasi emisi karbon di seluruh provinsi di Indonesia, serta menyediakan visualisasi interaktif untuk memudahkan pemahaman tren dan pola.")
                    )
                )
              ),
              
              fluidRow(
                box(width = 12, title = "📄 Detail Data Berdasarkan Pilihan", status = "primary", solidHeader = TRUE,
                    DT::dataTableOutput("tabel_peta_detail")
                )
              )
              
      ),
      
      tabItem(tabName = "tren_region", h2("📈 Tren by Region", class = "page-title-kanit"), fluidRow( box(width = 4, title = "🎛 Kontrol Analisis", status = "primary", solidHeader = TRUE, selectInput("jenis_data_region", "Pilih Jenis Data:", choices = list("Luas Penutupan Lahan Hutan (Ha)" = "Luas_Hutan", "Luas Penutupan Lahan Non-Hutan (Ha)" = "Luas_Non_Hutan")), selectInput("pulau_region", "Pilih Pulau:", choices = list("Sumatra" = "Sumatra", "Jawa" = "Jawa", "Kalimantan" = "Kalimantan", "Sulawesi" = "Sulawesi", "Nusa Tenggara dan Bali" = "Bali-Nusa Tenggara", "Papua dan Maluku" = "Papua-Maluku")), div(class = "info-box-custom", h6("📋 Keterangan:"), p("Grafik garis menunjukkan tren perubahan tutupan lahan hutan dan non-hutan di setiap provinsi dalam kelompok pulau yang dipilih. Anda dapat melihat bagaimana luas lahan berubah dari tahun ke tahun untuk setiap provinsi di pulau tersebut.")) ), box(width = 8, title = "📊 Grafik Tren Regional", status = "success", solidHeader = TRUE, plotlyOutput("plot_tren_region", height = 450)) )),
      tabItem(tabName = "provinsi_detail", h2("🏛 Analisis per Provinsi", class = "page-title-kanit"), fluidRow( box(width = 4, title = "🎯 Pilih Provinsi", status = "primary", solidHeader = TRUE, selectInput("provinsi_analisis", "Pilih Provinsi:", choices = sort(unique(data_lahan$Provinsi))), div(class = "info-box-custom", h6("📊 Informasi:"), p("Grafik line chart ini menampilkan perkembangan luas tutupan lahan hutan dan non-hutan untuk provinsi yang Anda pilih dari tahun 2014 hingga 2023. Ini membantu melihat dinamika perubahan lahan di tingkat provinsi secara spesifik.")) ), box(width = 8, title = "📈 Perkembangan Tutupan Lahan", status = "info", solidHeader = TRUE, plotlyOutput("plot_provinsi_detail", height = 450)) )),

      tabItem(tabName = "estimasi", 
              h2("🏝️ Perbandingan antar Kelompok Pulau", class = "page-title-kanit"), 
              fluidRow( 
                box(width = 4, 
                    title = "⚙ Indikator Pembanding", 
                    status = "primary", 
                    solidHeader = TRUE, 
                    
                    # Pilihan indikator yang akan dibandingkan
                    selectInput("indikator_pembanding", 
                                "Pilih Indikator Pembanding:", 
                                choices = list(
                                  "Luas Kehilangan Tutupan Pohon (Ha)" = "Kehilangan_Tutupan",
                                  "Estimasi Emisi Karbon (Ton CO₂e)" = "Emisi_Karbon",
                                  "Total Luas Penutupan Hutan (Ha)" = "Luas_Hutan",
                                  "Total Luas Penutupan Non-Hutan (Ha)" = "Luas_Non_Hutan"
                                ),
                                selected = "Kehilangan_Tutupan"),
                    
                    # Slider tahun
                    sliderInput("tahun_estimasi", 
                                "Pilih Tahun:", 
                                min = 2014, 
                                max = 2023, 
                                value = 2023, 
                                step = 1, 
                                sep = ""),
                    
                    # Pilihan jenis visualisasi
                    radioButtons("jenis_visualisasi",
                                 "Jenis Visualisasi:",
                                 choices = list(
                                   "Bar Chart" = "bar",
                                   "Pie Chart" = "pie",
                                   "Donut Chart" = "donut"
                                 ),
                                 selected = "bar"),
                    
                    # Pilihan sorting
                    selectInput("urutan_data",
                                "Urutkan Data:",
                                choices = list(
                                  "Tertinggi ke Terendah" = "desc",
                                  "Terendah ke Tertinggi" = "asc",
                                  "Berdasarkan Nama Pulau" = "nama"
                                ),
                                selected = "desc"),
                    
                    # Info box
                    div(class = "info-box-custom", 
                        h6("📊 Informasi Visualisasi:"), 
                        p("Visualisasi ini menampilkan perbandingan nilai indikator yang dipilih antar kelompok pulau di Indonesia pada tahun yang ditentukan. Pilih indikator dan tahun sesuai kebutuhan analisis Anda."))
                ), 
                
                box(width = 8, 
                    title = "📈 Hasil Perbandingan", 
                    status = "warning", 
                    solidHeader = TRUE, 
                    
                    # Tab untuk berbagai tampilan
                    tabsetPanel(
                      tabPanel("Visualisasi", 
                               plotlyOutput("plot_estimasi", height = 450)),
                      tabPanel("Tabel Data", 
                               DT::dataTableOutput("table_estimasi")),
                      tabPanel("Statistik Ringkasan", 
                               div(style = "padding: 20px;",
                                   h4("📋 Ringkasan Statistik"),
                                   htmlOutput("summary_stats")))
                    )
                )
              )
      ),
            tabItem(tabName = "provinsi_teratas", h2("🏆 Provinsi Teratas", class = "page-title-kanit"), fluidRow( box(width = 4, title = "🎮 Pengaturan Ranking", status = "primary", solidHeader = TRUE, selectInput("jenis_data_top", "Pilih Jenis Data:", choices = list("Total Luas Penutupan Hutan (Ha)" = "Luas_Hutan", "Total Luas Penutupan Non-Hutan (Ha)" = "Luas_Non_Hutan", "Luas Kehilangan Tutupan Pohon (Ha)" = "Kehilangan_Tutupan", "Estimasi Emisi Karbon (Ton CO₂e)" = "Emisi_Karbon")), sliderInput("tahun_top", "Pilih Tahun:", min = 2014, max = 2023, value = 2023, step = 1, sep = ""), div(class = "info-box-custom", h6("🥧 Visualisasi:"), p("Diagram pie ini menampilkan proporsi dari 5 provinsi teratas berdasarkan jenis data (luas hutan, non-hutan, kehilangan tutupan, atau emisi karbon) pada tahun yang Anda pilih. Ini membantu mengidentifikasi kontributor terbesar.")) ), box(width = 8, title = "🥧 Diagram Pie - Top 5 Provinsi", status = "danger", solidHeader = TRUE, plotlyOutput("plot_provinsi_teratas", height = 450)) )),
      
      # TAMBAHAN: Tab Analisis Statistik
      # Tab Analisis Statistik Lengkap
      tabItem(tabName = "analisis_statistik",
              h2("📈 Analisis Statistik Lanjutan", class = "page-title-kanit"),
              div(class = "description-box", 
                  p(class = "description-text", "Analisis korelasi, regresi, dan ANOVA untuk data perubahan lahan dan emisi karbon di Indonesia. Pilih jenis analisis yang diinginkan untuk mendapatkan insight statistik yang mendalam.")
              ),
              
              fluidRow(
                box(width = 12, 
                    tabsetPanel(
                      id = "analisis_tabs",
                      
                      # Tab Analisis Korelasi
                      tabPanel("🔗 Analisis Korelasi",
                               fluidRow(
                                 box(width = 4, title = "⚙️ Parameter Korelasi", status = "primary", solidHeader = TRUE,
                                     selectInput("tahun_korelasi", "Pilih Tahun:", 
                                                 choices = 2014:2023, selected = 2023),
                                     selectInput("metode_korelasi", "Metode Korelasi:", 
                                                 choices = list("Pearson" = "pearson", 
                                                                "Spearman" = "spearman", 
                                                                "Kendall" = "kendall"), 
                                                 selected = "pearson"),
                                     div(class = "info-box-custom",
                                         h6("📊 Interpretasi:"),
                                         p("• |r| > 0.7: Korelasi Kuat"),
                                         p("• 0.3 < |r| < 0.7: Korelasi Sedang"),
                                         p("• |r| < 0.3: Korelasi Lemah"))
                                 ),
                                 box(width = 8, title = "🔗 Matriks Korelasi", status = "info", solidHeader = TRUE,
                                     plotlyOutput("plot_korelasi", height = 400)
                                 )
                               ),
                               fluidRow(
                                 box(width = 12, title = "📋 Tabel Korelasi Detail", status = "success", solidHeader = TRUE,
                                     DT::dataTableOutput("tabel_korelasi")
                                 )
                               )
                      ),
                      
                      # Tab Analisis Regresi  
                      tabPanel("📈 Analisis Regresi",
                               fluidRow(
                                 box(width = 4, title = "⚙️ Parameter Regresi", status = "primary", solidHeader = TRUE,
                                     selectInput("var_x_regresi", "Variabel X (Prediktor):", 
                                                 choices = list("Luas Hutan" = "Luas_Hutan",
                                                                "Luas Non-Hutan" = "Luas_Non_Hutan",
                                                                "Kehilangan Tutupan" = "Kehilangan_Tutupan")),
                                     selectInput("var_y_regresi", "Variabel Y (Respon):", 
                                                 choices = list("Emisi Karbon" = "Emisi_Karbon",
                                                                "Luas Hutan" = "Luas_Hutan",
                                                                "Luas Non-Hutan" = "Luas_Non_Hutan",
                                                                "Kehilangan Tutupan" = "Kehilangan_Tutupan"),
                                                 selected = "Emisi_Karbon"),
                                     sliderInput("tahun_regresi", "Range Tahun:", 
                                                 min = 2014, max = 2023, value = c(2014, 2023), step = 1, sep = ""),
                                     div(class = "info-box-custom",
                                         h6("📈 Model Regresi:"),
                                         p("Y = β₀ + β₁X + ε"),
                                         p("Analisis hubungan linear antara variabel"))
                                 ),
                                 box(width = 8, title = "📊 Scatter Plot & Garis Regresi", status = "warning", solidHeader = TRUE,
                                     plotlyOutput("plot_regresi", height = 400)
                                 )
                               ),
                               fluidRow(
                                 box(width = 6, title = "📋 Summary Model", status = "info", solidHeader = TRUE,
                                     verbatimTextOutput("summary_regresi")
                                 ),
                                 box(width = 6, title = "📊 Diagnostik Residual", status = "success", solidHeader = TRUE,
                                     plotlyOutput("plot_residual", height = 350)
                                 )
                               )
                      ),
                      
                      # Tab Analisis ANOVA
                      tabPanel("📊 Analisis ANOVA",
                               fluidRow(
                                 box(width = 4, title = "⚙️ Parameter ANOVA", status = "primary", solidHeader = TRUE,
                                     selectInput("var_anova", "Variabel Dependen:", 
                                                 choices = list("Luas Hutan" = "Luas_Hutan",
                                                                "Luas Non-Hutan" = "Luas_Non_Hutan",
                                                                "Kehilangan Tutupan" = "Kehilangan_Tutupan",
                                                                "Emisi Karbon" = "Emisi_Karbon")),
                                     selectInput("faktor_anova", "Faktor Grouping:", 
                                                 choices = list("Pulau" = "Pulau", 
                                                                "Tahun" = "Tahun")),
                                     sliderInput("tahun_anova", "Range Tahun:", 
                                                 min = 2014, max = 2023, value = c(2014, 2023), step = 1, sep = ""),
                                     div(class = "info-box-custom",
                                         h6("📊 Hipotesis ANOVA:"),
                                         p("H₀: μ₁ = μ₂ = ... = μₖ"),
                                         p("H₁: Minimal ada satu μᵢ ≠ μⱼ"),
                                         p("α = 0.05"))
                                 ),
                                 box(width = 8, title = "📊 Box Plot Perbandingan", status = "danger", solidHeader = TRUE,
                                     plotlyOutput("plot_boxplot_anova", height = 400)
                                 )
                               ),
                               fluidRow(
                                 box(width = 12, title = "📋 Hasil ANOVA", status = "info", solidHeader = TRUE,
                                     verbatimTextOutput("hasil_anova")
                                 )),
                               fluidRow(
                                 box(width = 12, title = "📊 Post-hoc Test (Tukey HSD)", status = "success", solidHeader = TRUE,
                                     DT::dataTableOutput("tabel_tukey")
                                 ))
                      )
                    )
                )
              )
      ),
      
      tabItem(
        tabName = "data", 
        h2("📋 Dataset Lengkap", class = "page-title-kanit"), 
        
        div(class = "description-box", 
            h4("📖 Deskripsi Dataset", class = "section-title-kanit"), 
            p("Semua data berasal dari hasil olahan dan kompilasi dari berbagai sumber terpercaya, mencakup periode 2014 hingga 2023. Data ini disimulasikan untuk tujuan demonstrasi dashboard.", 
              style = "margin-bottom: 10px; font-family: 'Poppins', sans-serif;"), 
            
            tags$ul(style = "margin-left: 20px; color: #4a5568; font-family: 'Poppins', sans-serif;", 
                    tags$li("🏛 Kementerian Lingkungan Hidup dan Kehutanan (KLHK) - Data tutupan lahan Indonesia."), 
                    tags$li("📊 Data tutupan lahan Indonesia (2014–2023)"), 
                    tags$li("💨 Data estimasi emisi karbon (CO₂e) dari Global Forest Watch")), 
            
            p("Silakan akses tautan berikut untuk informasi lebih lanjut mengenai sumber data:", 
              style = "margin-top: 15px; margin-bottom: 8px; font-family: 'Poppins', sans-serif;"), 
            
            tags$ul(style = "margin-left: 20px; font-family: 'Poppins', sans-serif;", 
                    tags$li(tags$a("Data Tutupan Lahan: KLHK – Tutupan Lahan", 
                                   href = "https://statistik.menlhk.go.id/sisklhk/ditjen_ppkl", 
                                   target = "_blank", 
                                   style = "color: #667eea;")), 
                    tags$li(tags$a("Estimasi Emisi: Global Forest Watch", 
                                   href = "https://www.globalforestwatch.org/dashboards/country/IDN/?lang=id",
                                   target = "_blank", 
                                   style = "color: #667eea;")))), 
        
        # Row untuk Filter Data
        fluidRow(
          box(width = 12, 
              title = "🔍 Filter Data", 
              status = "primary", 
              solidHeader = TRUE, 
              selectInput("kategori_data", 
                          "Pilih Kategori Data:", 
                          choices = list("Semua Data" = "all", 
                                         "Total Luas Penutupan Hutan (Ha)" = "Luas_Hutan", 
                                         "Total Luas Penutupan Non-Hutan (Ha)" = "Luas_Non_Hutan", 
                                         "Luas Kehilangan Tutupan Pohon (Ha)" = "Kehilangan_Tutupan", 
                                         "Estimasi Emisi Karbon (Ton CO₂e)" = "Emisi_Karbon")))
        ),
        
        # Row untuk Tabel Data
        fluidRow(
          box(width = 12, 
              title = "📊 Tabel Data Interaktif", 
              status = "success", 
              solidHeader = TRUE, 
              
              # Informasi tambahan tentang fitur ekspor
              div(style = "margin-bottom: 15px; background-color: #f8f9fa; padding: 15px; border-radius: 8px; border-left: 4px solid #28a745;",
                  div(style = "display: flex; align-items: center; margin-bottom: 10px;",
                      h5("📈 Kolom Data:", class = "subtitle-kanit", style = "margin: 0; margin-right: 10px;"),
                      tags$span("(Gunakan tombol Copy, CSV, atau Excel di bawah tabel)", 
                                style = "font-size: 12px; color: #6c757d; font-style: italic; font-family: 'Poppins', sans-serif;")),
                  
                  p("No • Provinsi • Pulau • Tahun • Luas Hutan (Ha) • Luas Non-Hutan (Ha) • Luas Kehilangan Tutupan Pohon (Ha) • Estimasi Emisi Karbon (Ton CO₂e)", 
                    style = "font-size: 12px; color: #718096; font-style: italic; font-family: 'Poppins', sans-serif; margin: 0;"),
                  
                  div(style = "margin-top: 10px;",
                      tags$span("🔍 ", style = "color: #17a2b8;"),
                      tags$span("Gunakan fitur pencarian dan filter pada tabel untuk mempersempit data", 
                                style = "font-size: 12px; color: #495057; font-family: 'Poppins', sans-serif;"),
                      tags$br(),
                      tags$span("📥 ", style = "color: #ffc107;"),
                      tags$span("Tombol ekspor (Copy, CSV, Excel) tersedia di bagian atas tabel", 
                                style = "font-size: 12px; color: #495057; font-family: 'Poppins', sans-serif;"))
              ),
              
              # Tabel Data
              DT::dataTableOutput("tabel_data"))
        )
      ),
      
      tabItem(tabName = "tentang", div(style = "max-width: 1000px; margin: 0 auto;", div(style = "text-align: center; margin-bottom: 30px;", h1("Perubahan Tutupan Lahan & Estimasi Emisi Karbon di Indonesia", class = "main-title", style = "font-size: 44px !important;")), fluidRow( column(6, box(width = NULL, title = "📋 Deskripsi Singkat", status = "primary", solidHeader = TRUE, p("Dashboard ini menyajikan informasi komprehensif mengenai perubahan tutupan lahan dan estimasi emisi karbon di seluruh provinsi di Indonesia dari tahun 2014 hingga 2023. Dibangun dengan R Shiny, dashboard ini bertujuan untuk memberikan visualisasi data yang interaktif dan mudah dipahami bagi para pembuat kebijakan, peneliti, dan masyarakat umum yang tertarik pada isu lingkungan dan iklim.", style = "text-align: justify; line-height: 1.7; font-family: 'Poppins', sans-serif; color: #4a5568;")) ), column(6, box(width = NULL, title = "🎯 Tujuan Proyek", status = "success", solidHeader = TRUE, tags$ul(style = "line-height: 1.8; font-family: 'Poppins', sans-serif; color: #4a5568;", tags$li("Menyediakan visualisasi interaktif data perubahan tutupan lahan dan emisi karbon."), tags$li("Menampilkan estimasi dan tren perubahan lahan di tingkat regional dan provinsi."), tags$li("Memberikan insight yang mudah diakses untuk mendukung pengambilan keputusan terkait lingkungan dan iklim.")))) ), 
                                       # --- START NEW SECTION: Video Demonstration ---
                                       fluidRow(
                                         column(12,
                                                box(width = NULL,
                                                    title = "🎬 Video Demonstrasi Dashboard",
                                                    status = "info",
                                                    solidHeader = TRUE,
                                                    div(style = "text-align: center; padding: 20px;",
                                                        p("Tonton video penjelasan singkat tentang fitur-fitur dashboard ini:", 
                                                          style = "font-family: 'Poppins', sans-serif; color: #4a5568; margin-bottom: 20px;"),
                                                        
                                                        # Video Perkenalan
                                                        tags$iframe(
                                                          width = "100%",
                                                          height = "400",
                                                          src = "https://www.youtube.com/embed/YoAdGQ2-hX0?rel=0", # Embed URL YouTube
                                                          title = "YouTube video",
                                                          frameborder = "0",
                                                          allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
                                                          allowfullscreen = NA,
                                                          style = "max-width: 800px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);"
                                                        ),
                                                        
                                                        # Link Download PDF User Guide
                                                        div(style = "margin-top: 25px; padding: 15px; background-color: #f8f9fa; border-radius: 8px; border-left: 4px solid #007bff;",
                                                            p("📚 Butuh panduan lengkap? Download user guide dalam format PDF:", 
                                                              style = "font-family: 'Poppins', sans-serif; color: #495057; margin-bottom: 15px; font-weight: 500;"),
                                                            
                                                            downloadButton("downloadPDF", 
                                                                           label = "📥 Download User Guide PELIK (PDF)",
                                                                           style = "background-color: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 5px; font-family: 'Poppins', sans-serif; font-weight: 500; cursor: pointer; box-shadow: 0 2px 4px rgba(0,123,255,0.2);",
                                                                           class = "btn-primary")
                                                        )
                                                        
                                                      
                                                    )
                                                )
                                         )
                                       ),
                                       # --- END NEW SECTION: Video Demonstration ---
                                       fluidRow( column(6, box(width = NULL, title = "📚 Sumber Data", status = "info", solidHeader = TRUE, tags$ul(style = "line-height: 1.8; font-family: 'Poppins', sans-serif; color: #4a5568;", tags$li(tags$a("Kementerian Lingkungan Hidup dan Kehutanan (KLHK)", href = "https://statistik.menlhk.go.id/sisklhk/ditjen_ppkl", target = "_blank", style = "color: #667eea;")), tags$li(tags$a("Global Forest Watch (GFW)", href = "https://www.globalforestwatch.org/dashboards/country/IDN/?lang=id", target = "_blank", style ="color: #667eea;")), tags$li(tags$a("Badan Informasi Geospasial (BIG)", href = "https://geoportal.big.go.id/#/", target = "_blank", style = "color: #667eea;")), tags$li("Hasil pengolahan dan simulasi data untuk tujuan demonstrasi.")) )), column(6, box(width = NULL, title = "👥 Nama Penyusun", status = "warning", solidHeader = TRUE, 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                # --- START MODIFIED SECTION: Profil Penyusun ---
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                div(class = "profile-container", # Container untuk gambar dan teks nama
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    tags$img(src = "https://iili.io/FRdT6x4.jpg", class = "profile-image"), # Gambar profil Amalia
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    div(class = "profile-text",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(strong("AMALIA KHOIRUM MAZIDAH")), # Nama lengkap
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(tags$span("NIM: 222312964")) # NIM di baris baru
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                div(class = "profile-container",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    tags$img(src = "https://iili.io/FRJ4GXn.jpg", class = "profile-image"), # Ganti dengan URL gambar penyusun 2
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    div(class = "profile-text",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(strong("ANANDA MIZAN ALI")),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(tags$span("NIM: 222312970"))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                div(class = "profile-container",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    tags$img(src = "https://iili.io/FRd5b4V.jpg", class = "profile-image"), # Ganti dengan URL gambar penyusun 3
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    div(class = "profile-text",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(strong("JOHANA PUTRI NATASYA SITORUS")),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(tags$span("NIM: 222313150"))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                div(class = "profile-container",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    tags$img(src = "https://iili.io/FRd7rMv.jpg", class = "profile-image"), # Ganti dengan URL gambar penyusun 4
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    div(class = "profile-text",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(strong("VALENTINA LASMA SITUMORANG")),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        tags$p(tags$span("NIM: 222313413"))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                )
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                # --- END MODIFIED SECTION: Profil Penyusun ---
      )) ), fluidRow( column(12, box(width = NULL, title = "🏫 Institusi", status = "primary", solidHeader = TRUE, 
                                     # --- START MODIFIED SECTION: Logo Institusi ---
                                     div(style = "text-align: center; padding: 30px;",
                                         tags$img(src = "https://iili.io/FRdFBO7.jpg", class = "institution-logo"), # Logo institusi di sini, ganti URL
                                         h3("Politeknik Statistika STIS", class = "section-title-kanit"),
                                         p("Program Studi Komputasi Statistika | Semester 4", style = "color: #718096; font-size: 16px; font-family: 'Poppins', sans-serif;"),
                                         p("Jalan Otto Iskandardinata No.64C, Jakarta Timur, Indonesia", style = "color: #a0aec0; font-size: 14px; margin-top: 15px; font-family: 'Poppins', sans-serif;")
                                     )
                                     # --- END MODIFIED SECTION: Logo Institusi ---
      )) )))
    )
  )
)

# Penjelasan Singkat Bagian 5: Logika Server (Backend Aplikasi)
# Bagian ini adalah "otak" aplikasi Anda. Fungsi `server` menerima input dari UI
# (misalnya, pilihan tahun, provinsi, atau jenis data) dan menghasilkan output (peta, grafik, tabel)
# yang diperbarui secara dinamis. Setiap `output$...` adalah elemen yang akan ditampilkan di UI.
# Bagian ini berisi semua perhitungan, pemfilteran data, dan logika pembuatan visualisasi.

# Server
server <- function(input, output, session) {
  
  # Load peta GeoJSON sekali saja di luar reactive
  geojson_data <- st_read("www/indonesia-prov.geojson")
  
  # Reactive data gabungan: data spasial + data lahan per tahun
  data_peta <- reactive({
    req(input$tahun_peta)
    
    # Filter data lahan berdasarkan tahun input
    data_lahan_filtered <- data_lahan %>%
      filter(Tahun == input$tahun_peta)
    
    # Gabungkan data lahan dengan peta GeoJSON berdasarkan Provinsi
    geo_joined <- geojson_data %>%
      left_join(data_lahan_filtered, by = "Provinsi")
    
    return(geo_joined)
  })
  
  output$map <- renderLeaflet({
    data_filtered <- data_peta()
    req(input$indikator_peta)
    
    # Palet warna dinamis berdasarkan indikator
    colors <- if (input$indikator_peta %in% c("Kehilangan_Tutupan", "Emisi_Karbon")) {
      c("#FFF6E9", "#FFD93D", "#F39C12", "#FF6B6B", "#E74C3C")
    } else {
      c("#BBE2EC", "#40A2E3", "#0D9276", "#2ECC71", "#27AE60")
    }
    
    pal <- colorNumeric(
      palette = colors,
      domain = data_filtered[[input$indikator_peta]]
    )
    
    leaflet(data_filtered) %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng = 118, lat = -2, zoom = 5) %>%
      addPolygons(
        fillColor = ~pal(get(input$indikator_peta)),
        weight = 1,
        opacity = 1,
        color = "white",
        dashArray = "3",
        fillOpacity = 0.7,
        popup = ~paste0(
          "<div style='font-family: Poppins, sans-serif; padding: 12px; min-width: 220px; border-radius: 10px;
                     background: linear-gradient(135deg, #FFF6E9 0%, #BBE2EC 100%);'>",
          "<h4 style='background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%);
                       -webkit-background-clip: text; -webkit-text-fill-color: transparent;
                       background-clip: text; margin: 0 0 8px 0; font-weight: 600;'>",
          Provinsi, "</h4>",
          "<p style='margin: 4px 0; color: #2c3e50;'><strong>Pulau:</strong> ", Pulau, "</p>",
          "<p style='margin: 4px 0; color: #2c3e50;'><strong>Tahun:</strong> ", Tahun, "</p>",
          "<p style='margin: 4px 0;
                     background: linear-gradient(135deg, #40A2E3 0%, #0D9276 100%);
                     -webkit-background-clip: text; -webkit-text-fill-color: transparent;
                     background-clip: text; font-weight: 600;'><strong>Nilai:</strong> ",
          format(get(input$indikator_peta), big.mark = ",", scientific = FALSE),
          ifelse(input$indikator_peta == "Emisi_Karbon", " Ton CO₂e", " Ha"),
          "</p>",
          "</div>"
        )
      ) %>%
      addLegend(
        pal = pal,
        values = data_filtered[[input$indikator_peta]],
        title = "Nilai",
        position = "bottomright",
        opacity = 0.8
      )
  })
  
  
  # Top 3 provinsi dengan visual ranking
  output$top3_provinsi <- renderTable({
    indikator_urutan <- c("Luas_Hutan", "Luas_Non_Hutan", "Kehilangan_Tutupan", "Emisi_Karbon")
    
    data <- data_peta()
    req(input$indikator_peta)
    req(input$indikator_peta %in% indikator_urutan)
    
    df <- st_drop_geometry(data)
    
    df %>%
      arrange(factor(input$indikator_peta, levels = indikator_urutan)) %>%
      arrange(desc(.data[[input$indikator_peta]])) %>%
      head(3) %>%
      mutate(
        Ranking = c("🥇", "🥈", "🥉"),
        Nilai = paste0(format(as.numeric(.data[[input$indikator_peta]]), 
                              big.mark = ",", scientific = FALSE), 
                       ifelse(input$indikator_peta == "Emisi_Karbon", " Ton CO₂e", " Ha"))
      ) %>%
      select(Ranking, Provinsi, Nilai)
  }, striped = TRUE, spacing = "s", width = "100%")
  
  
  output$tabel_peta_detail <- DT::renderDataTable({
    data_tabel <- st_drop_geometry(data_peta())
    
    data_display <- data_tabel %>%
      arrange(desc(.data[[input$indikator_peta]])) %>%
      mutate(
        `Luas Hutan (Ha)` = format(as.numeric(Luas_Hutan), big.mark = ","),
        `Luas Non-Hutan (Ha)` = format(as.numeric(Luas_Non_Hutan), big.mark = ","),
        `Kehilangan Tutupan (Ha)` = format(as.numeric(Kehilangan_Tutupan), big.mark = ","),
        `Emisi Karbon (Ton CO2e)` = format(as.numeric(Emisi_Karbon), big.mark = ",")
      ) %>%
      select(
        Provinsi, Pulau,
        `Luas Hutan (Ha)`,
        `Luas Non-Hutan (Ha)`,
        `Kehilangan Tutupan (Ha)`,
        `Emisi Karbon (Ton CO2e)`
      )
    
    DT::datatable(
      data_display,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        dom = 'tp',
        autoWidth = TRUE
      ),
      rownames = FALSE,
      class = 'cell-border stripe hover compact',
      escape = FALSE
    )
  })
  
  
  output$plot_tren_region <- renderPlotly({ 
    req(input$pulau_region, input$jenis_data_region)
    
    # Filter data sesuai pulau
    filtered_data <- data_lahan %>% 
      filter(Pulau == input$pulau_region) %>% 
      group_by(Provinsi, Tahun) %>% 
      summarise(
        nilai = sum(.data[[input$jenis_data_region]], na.rm = TRUE),
        .groups = 'drop'
      )
    
    # Ambil daftar provinsi untuk warna dinamis
    provinsi_list <- unique(filtered_data$Provinsi)
    color_palette <- RColorBrewer::brewer.pal(min(length(provinsi_list), 12), "Set3")
    if (length(provinsi_list) > length(color_palette)) {
      # Tambah warna otomatis kalau tidak cukup
      color_palette <- scales::hue_pal()(length(provinsi_list))
    }
    
    # Buat plot dengan gaya elegan
    p <- ggplot(filtered_data, aes(x = Tahun, y = nilai, color = Provinsi)) + 
      geom_line(size = 1.5, alpha = 0.85) + 
      geom_point(size = 3, alpha = 0.95) +
      scale_color_manual(values = setNames(color_palette, provinsi_list)) +
      scale_y_continuous(labels = scales::comma_format()) +
      theme_minimal(base_family = "Poppins") +
      theme(
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#f1f5f9", size = 0.5),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        plot.title = element_text(color = "#2c3e50", size = 15, face = "bold"),
        axis.title = element_text(color = "#34495e", size = 12),
        axis.text = element_text(size = 10)
      ) +
      labs(
        title = paste("📊 Tren", gsub("_", " ", input$jenis_data_region), "di", input$pulau_region),
        y = if (input$jenis_data_region == "Emisi_Karbon") "Total Emisi (Ton CO₂e)" else "Luas (Ha)",
        x = "Tahun"
      )
    
    # Konversi ke plotly
    ggplotly(p, tooltip = c("x", "y", "colour")) %>% 
      layout(
        legend = list(orientation = "h", x = 0, y = -0.25),
        margin = list(l = 50, r = 20, b = 50, t = 50)
      )
  })
  
  
  output$plot_provinsi_detail <- renderPlotly({ 
    req(input$provinsi_analisis); 
    filtered_data <- data_lahan %>% 
      filter(Provinsi == input$provinsi_analisis) %>% 
      select(Tahun, Luas_Hutan, Luas_Non_Hutan) %>% 
      pivot_longer(cols = c(Luas_Hutan, Luas_Non_Hutan), names_to = "Jenis", values_to = "Luas") %>% 
      mutate(Jenis = case_when(Jenis == "Luas_Hutan" ~ "🌲 Luas Penutupan Lahan Hutan", Jenis == "Luas_Non_Hutan" ~ "🏞 Luas Penutupan Lahan Non-Hutan")); 
    p <- ggplot(filtered_data, aes(x = Tahun, y = Luas, color = Jenis)) + 
      geom_line(size = 2.2, alpha = 0.8) + 
      geom_point(size = 4.5, alpha = 0.9) + 
      scale_color_manual(values = c("🌲 Luas Penutupan Lahan Hutan" = "#0D9276", "🏞 Luas Penutupan Lahan Non-Hutan" = "#FF6B6B")) + 
      theme_minimal() + 
      theme(
        panel.grid.minor = element_blank(), 
        panel.grid.major = element_line(color = "#f1f5f9", size = 0.5), 
        text = element_text(family = "Poppins"), 
        legend.position = "bottom", 
        legend.title = element_blank(), 
        plot.background = element_rect(fill = "white", color = NA), 
        panel.background = element_rect(fill = "white", color = NA), 
        plot.title = element_text(color = "#2c3e50", size = 14, face = "bold")
      ) + 
      labs(
        title = paste("Perkembangan Tutupan Lahan di", input$provinsi_analisis), 
        y = "Luas (Ha)", 
        x = "Tahun"
      ) + 
      scale_y_continuous(labels = comma_format()); 
    ggplotly(p, tooltip = c("x", "y", "colour")) %>% 
      layout(legend = list(orientation = "h", x = 0, y = -0.2)) 
  });
  
  output$plot_estimasi <- renderPlotly({ 
    req(input$indikator_pembanding, input$tahun_estimasi)
    
    # Filter dan agregasi data
    filtered_data <- data_lahan %>% 
      filter(Tahun == input$tahun_estimasi) %>% 
      group_by(Pulau) %>% 
      summarise(
        Kehilangan_Tutupan = sum(Kehilangan_Tutupan, na.rm = TRUE), 
        Emisi_Karbon = sum(Emisi_Karbon, na.rm = TRUE),
        Luas_Hutan = sum(Luas_Hutan, na.rm = TRUE),
        Luas_Non_Hutan = sum(Luas_Non_Hutan, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      mutate(
        Pulau = case_when(
          Pulau == "Sumatera" ~ "Sumatera",
          Pulau == "Jawa" ~ "Jawa",
          Pulau == "Kalimantan" ~ "Kalimantan",
          Pulau == "Sulawesi" ~ "Sulawesi",
          Pulau == "Papua" ~ "Papua",
          Pulau == "Bali_Nusa_Tenggara" ~ "Bali & Nusa Tenggara",
          Pulau == "Maluku" ~ "Maluku",
          TRUE ~ Pulau
        )
      )
    
    # Pilih kolom sesuai indikator
    plot_data <- filtered_data %>%
      select(Pulau, Nilai = all_of(input$indikator_pembanding))
    
    # Urutkan data
    if(input$urutan_data == "desc") {
      plot_data <- plot_data %>% arrange(desc(Nilai))
    } else if(input$urutan_data == "asc") {
      plot_data <- plot_data %>% arrange(Nilai)
    } else {
      plot_data <- plot_data %>% arrange(Pulau)
    }
    
    plot_data <- plot_data %>%
      mutate(Pulau = factor(Pulau, levels = Pulau))
    
    # Buat label untuk indikator
    label_indikator <- case_when(
      input$indikator_pembanding == "Kehilangan_Tutupan" ~ "Luas Kehilangan Tutupan Pohon (Ha)",
      input$indikator_pembanding == "Emisi_Karbon" ~ "Estimasi Emisi Karbon (Ton CO₂e)",
      input$indikator_pembanding == "Luas_Hutan" ~ "Total Luas Penutupan Hutan (Ha)",
      input$indikator_pembanding == "Luas_Non_Hutan" ~ "Total Luas Penutupan Non-Hutan (Ha)"
    )
    
    # Buat warna berdasarkan indikator
    color_palette <- case_when(
      input$indikator_pembanding == "Kehilangan_Tutupan" ~ "#FF6B6B",
      input$indikator_pembanding == "Emisi_Karbon" ~ "#9B59B6",
      input$indikator_pembanding == "Luas_Hutan" ~ "#2ECC71",
      input$indikator_pembanding == "Luas_Non_Hutan" ~ "#F39C12"
    )
    
    # Buat plot berdasarkan jenis visualisasi
    if(input$jenis_visualisasi == "bar") {
      # Bar Chart
      if(input$urutan_data == "desc") {
        p <- ggplot(plot_data, aes(x = reorder(Pulau, -Nilai), y = Nilai))
      } else if(input$urutan_data == "asc") {
        p <- ggplot(plot_data, aes(x = reorder(Pulau, Nilai), y = Nilai))
      } else {
        p <- ggplot(plot_data, aes(x = reorder(Pulau, Pulau), y = Nilai))
      }
      p <- ggplot(plot_data, aes(x = Pulau, y = Nilai)) + 
        geom_col(alpha = 0.8, width = 0.7, fill = color_palette) + 
        theme_minimal() + 
        theme(
          panel.grid.minor = element_blank(), 
          panel.grid.major.x = element_blank(), 
          panel.grid.major.y = element_line(color = "#f1f5f9", size = 0.5), 
          text = element_text(family = "Poppins"), 
          axis.text.x = element_text(angle = 45, hjust = 1, size = 10), 
          legend.position = "none", 
          plot.background = element_rect(fill = "white", color = NA), 
          panel.background = element_rect(fill = "white", color = NA), 
          plot.title = element_text(color = "#2c3e50", size = 14, face = "bold")
        ) + 
        labs(
          title = paste(label_indikator, "Tahun", input$tahun_estimasi), 
          y = label_indikator, 
          x = "Kelompok Pulau"
        ) + 
        scale_y_continuous(labels = comma_format())
      
      ggplotly(p, tooltip = c("x", "y")) %>% 
        layout(showlegend = FALSE)
      
    } else if(input$jenis_visualisasi == "pie") {
      # Pie Chart
      plot_data <- plot_data %>%
        mutate(
          Persentase = round(Nilai / sum(Nilai) * 100, 1),
          Label = paste0(Pulau, "\n", comma(Nilai), "\n(", Persentase, "%)")
        )
      
      plot_ly(plot_data, 
              labels = ~Pulau, 
              values = ~Nilai, 
              type = 'pie',
              textposition = 'inside',
              textinfo = 'label+percent',
              hovertemplate = paste('<b>%{label}</b><br>',
                                    'Nilai: %{value:,.0f}<br>',
                                    'Persentase: %{percent}<br>',
                                    '<extra></extra>'),
              marker = list(colors = RColorBrewer::brewer.pal(n = nrow(plot_data), name = "Set3"))) %>%
        layout(title = paste(label_indikator, "Tahun", input$tahun_estimasi),
               showlegend = TRUE,
               font = list(family = "Poppins"))
      
    } else {
      # Donut Chart
      plot_data <- plot_data %>%
        mutate(
          Persentase = round(Nilai / sum(Nilai) * 100, 1)
        )
      
      plot_ly(plot_data, 
              labels = ~Pulau, 
              values = ~Nilai, 
              type = 'pie',
              hole = 0.4,
              textposition = 'inside',
              textinfo = 'label+percent',
              hovertemplate = paste('<b>%{label}</b><br>',
                                    'Nilai: %{value:,.0f}<br>',
                                    'Persentase: %{percent}<br>',
                                    '<extra></extra>'),
              marker = list(colors = RColorBrewer::brewer.pal(n = nrow(plot_data), name = "Spectral"))) %>%
        layout(title = paste(label_indikator, "Tahun", input$tahun_estimasi),
               showlegend = TRUE,
               font = list(family = "Poppins"),
               annotations = list(text = paste("Total:", comma(sum(plot_data$Nilai))),
                                  showarrow = FALSE, 
                                  font = list(size = 16, family = "Poppins")))
    }
  })
  
  # Output tabel data
  output$table_estimasi <- DT::renderDataTable({
    req(input$indikator_pembanding, input$tahun_estimasi)
    
    filtered_data <- data_lahan %>% 
      filter(Tahun == input$tahun_estimasi) %>% 
      group_by(Pulau) %>% 
      summarise(
        Kehilangan_Tutupan = sum(Kehilangan_Tutupan, na.rm = TRUE), 
        Emisi_Karbon = sum(Emisi_Karbon, na.rm = TRUE),
        Luas_Hutan = sum(Luas_Hutan, na.rm = TRUE),
        Luas_Non_Hutan = sum(Luas_Non_Hutan, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      mutate(
        Pulau = case_when(
          Pulau == "Sumatera" ~ "Sumatera",
          Pulau == "Jawa" ~ "Jawa",
          Pulau == "Kalimantan" ~ "Kalimantan",
          Pulau == "Sulawesi" ~ "Sulawesi",
          Pulau == "Papua" ~ "Papua",
          Pulau == "Bali_Nusa_Tenggara" ~ "Bali & Nusa Tenggara",
          Pulau == "Maluku" ~ "Maluku",
          TRUE ~ Pulau
        )
      ) %>%
      select(Pulau, Nilai = all_of(input$indikator_pembanding)) %>%
      arrange(desc(Nilai)) %>%
      mutate(
        Ranking = row_number(),
        Persentase = round(Nilai / sum(Nilai) * 100, 2)
      ) %>%
      select(Ranking, Pulau, Nilai, Persentase)
    
    # Nama kolom sesuai indikator
    label_indikator <- case_when(
      input$indikator_pembanding == "Kehilangan_Tutupan" ~ "Luas Kehilangan Tutupan Pohon (Ha)",
      input$indikator_pembanding == "Emisi_Karbon" ~ "Estimasi Emisi Karbon (Ton CO₂e)",
      input$indikator_pembanding == "Luas_Hutan" ~ "Total Luas Penutupan Hutan (Ha)",
      input$indikator_pembanding == "Luas_Non_Hutan" ~ "Total Luas Penutupan Non-Hutan (Ha)"
    )
    
    colnames(filtered_data) <- c("Ranking", "Kelompok Pulau", label_indikator, "Persentase (%)")
    
    DT::datatable(filtered_data, 
                  options = list(pageLength = 10, autoWidth = TRUE),
                  rownames = FALSE) %>%
      DT::formatRound(columns = c(3, 4), digits = 2) %>%
      DT::formatStyle(columns = c(1:4), fontSize = '14px')
  })
  
  # Output statistik ringkasan
  output$summary_stats <- renderUI({
    req(input$indikator_pembanding, input$tahun_estimasi)
    
    filtered_data <- data_lahan %>% 
      filter(Tahun == input$tahun_estimasi) %>% 
      group_by(Pulau) %>% 
      summarise(
        Kehilangan_Tutupan = sum(Kehilangan_Tutupan, na.rm = TRUE), 
        Emisi_Karbon = sum(Emisi_Karbon, na.rm = TRUE),
        Luas_Hutan = sum(Luas_Hutan, na.rm = TRUE),
        Luas_Non_Hutan = sum(Luas_Non_Hutan, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      select(Pulau, Nilai = all_of(input$indikator_pembanding))
    
    total_nilai <- sum(filtered_data$Nilai, na.rm = TRUE)
    rata_rata <- mean(filtered_data$Nilai, na.rm = TRUE)
    nilai_max <- max(filtered_data$Nilai, na.rm = TRUE)
    nilai_min <- min(filtered_data$Nilai, na.rm = TRUE)
    pulau_tertinggi <- filtered_data$Pulau[which.max(filtered_data$Nilai)]
    pulau_terendah <- filtered_data$Pulau[which.min(filtered_data$Nilai)]
    
    label_indikator <- case_when(
      input$indikator_pembanding == "Kehilangan_Tutupan" ~ "Luas Kehilangan Tutupan Pohon",
      input$indikator_pembanding == "Emisi_Karbon" ~ "Estimasi Emisi Karbon",
      input$indikator_pembanding == "Luas_Hutan" ~ "Total Luas Penutupan Hutan",
      input$indikator_pembanding == "Luas_Non_Hutan" ~ "Total Luas Penutupan Non-Hutan"
    )
    
    HTML(paste(
      "<div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 10px 0;'>",
      "<h5 style='color: #2c3e50; margin-bottom: 15px;'>", label_indikator, " - Tahun ", input$tahun_estimasi, "</h5>",
      "<div style='display: grid; grid-template-columns: 1fr 1fr; gap: 15px;'>",
      "<div style='background-color: white; padding: 15px; border-radius: 5px; border-left: 4px solid #3498db;'>",
      "<strong>📊 Total Keseluruhan:</strong><br>", comma(total_nilai), "</div>",
      "<div style='background-color: white; padding: 15px; border-radius: 5px; border-left: 4px solid #2ecc71;'>",
      "<strong>📈 Rata-rata:</strong><br>", comma(round(rata_rata, 2)), "</div>",
      "<div style='background-color: white; padding: 15px; border-radius: 5px; border-left: 4px solid #e74c3c;'>",
      "<strong>🔺 Tertinggi:</strong><br>", pulau_tertinggi, " (", comma(nilai_max), ")</div>",
      "<div style='background-color: white; padding: 15px; border-radius: 5px; border-left: 4px solid #f39c12;'>",
      "<strong>🔻 Terendah:</strong><br>", pulau_terendah, " (", comma(nilai_min), ")</div>",
      "</div></div>"
    ))
  })
  
  output$plot_provinsi_teratas <- renderPlotly({ 
    req(input$jenis_data_top, input$tahun_top); 
    filtered_data <- data_lahan %>% 
      filter(Tahun == input$tahun_top) %>% 
      group_by(Provinsi, Pulau) %>% 
      summarise(nilai = sum(.data[[input$jenis_data_top]], na.rm = TRUE), .groups = 'drop') %>% 
      arrange(desc(nilai)) %>% 
      head(5) %>% 
      mutate(label = paste0(Provinsi, "\n(", Pulau, ")\n", format(nilai, big.mark = ","), ifelse(input$jenis_data_top == "Emisi_Karbon", " Ton CO₂e", " Ha"))); 
    colors <- c("#40A2E3", "#0D9276", "#FFD93D", "#FF6B6B", "#9B59B6"); 
    plot_ly(data = filtered_data, labels = ~label, values = ~nilai, type = 'pie', textinfo = 'label+percent', textposition = 'outside', hovertemplate = paste0("<b>%{label}</b><br>","Nilai: %{value:,.0f}<br>","Persentase: %{percent}<br>","<extra></extra>"), marker = list(colors = colors, line = list(color = '#FFFFFF', width = 3))) %>% 
      layout(
        title = list(text = paste("Top 5 Provinsi -", gsub("_", " ", input$jenis_data_top), "Tahun", input$tahun_top), font = list(family = "Poppins", size = 16, color = "#2c3e50")), 
        font = list(family = "Poppins", size = 12), showlegend = FALSE
      ) 
  });
  
  # Pastikan library ini sudah di-load di bagian atas file
  # library(DT)
  # library(openxlsx)
  # library(readr)
  
  # Fungsi reaktif untuk data yang akan diekspor
  data_for_export <- reactive({
    req(input$kategori_data)
    
    data_base <- data_lahan %>% 
      mutate(No = row_number()) %>% 
      select(No, Provinsi, Pulau, Tahun, Luas_Hutan, Luas_Non_Hutan, Kehilangan_Tutupan, Emisi_Karbon)
    
    if (input$kategori_data == "all") {
      data_export <- data_base %>%
        select(No, Provinsi, Pulau, Tahun, Luas_Hutan, Luas_Non_Hutan, Kehilangan_Tutupan, Emisi_Karbon)
    } else {
      # Mapping nama kolom untuk ekspor
      kolom_data <- switch(input$kategori_data,
                           "Luas_Hutan" = "Luas_Hutan",
                           "Luas_Non_Hutan" = "Luas_Non_Hutan", 
                           "Kehilangan_Tutupan" = "Kehilangan_Tutupan",
                           "Emisi_Karbon" = "Emisi_Karbon"
      )
      
      data_export <- data_base %>%
        select(No, Provinsi, Pulau, Tahun, all_of(kolom_data))
    }
    
    return(data_export)
  })
  
  # Render DataTable dengan tombol ekspor
  output$tabel_data <- DT::renderDataTable({ 
    req(input$kategori_data)
    
    data_base <- data_lahan %>% 
      mutate(No = row_number()) %>% 
      select(No, Provinsi, Pulau, Tahun, Luas_Hutan, Luas_Non_Hutan, Kehilangan_Tutupan, Emisi_Karbon)
    
    data_formatted <- data_base %>%
      mutate(
        `Luas Hutan (Ha)` = format(Luas_Hutan, big.mark = ","),
        `Luas Non-Hutan (Ha)` = format(Luas_Non_Hutan, big.mark = ","),
        `Luas Kehilangan Tutupan Pohon (Ha)` = format(Kehilangan_Tutupan, big.mark = ","),
        `Est. Emisi Karbon (Ton CO₂e)` = format(Emisi_Karbon, big.mark = ",")
      )
    
    if (input$kategori_data == "all") {
      data_display <- data_formatted %>%
        select(No, Provinsi, Pulau, Tahun,
               `Luas Hutan (Ha)`,
               `Luas Non-Hutan (Ha)`,
               `Luas Kehilangan Tutupan Pohon (Ha)`,
               `Est. Emisi Karbon (Ton CO₂e)`)
    } else {
      # Mapping nama kolom label
      label <- switch(input$kategori_data,
                      "Luas_Hutan" = "Luas Hutan (Ha)",
                      "Luas_Non_Hutan" = "Luas Non-Hutan (Ha)",
                      "Kehilangan_Tutupan" = "Luas Kehilangan Tutupan Pohon (Ha)",
                      "Emisi_Karbon" = "Est. Emisi Karbon (Ton CO₂e)"
      )
      
      data_display <- data_formatted %>%
        select(No, Provinsi, Pulau, Tahun, all_of(label))
    }
    
    # Buat nama file dan judul berdasarkan pilihan kategori
    filename_base <- switch(input$kategori_data,
                            "all" = "data_lahan_di_Indonesia",
                            "Luas_Hutan" = "data_luas_tutupan_hutan",
                            "Luas_Non_Hutan" = "data_luas_tutupan_non_hutan",
                            "Kehilangan_Tutupan" = "data_kehilangan_tutupan_pohon",
                            "Emisi_Karbon" = "data_emisi_karbon")
    
    title_export <- switch(input$kategori_data,
                           "all" = "Data Lahan di Indonesia",
                           "Luas_Hutan" = "Data Luas Tutupan Hutan",
                           "Luas_Non_Hutan" = "Data Luas Tutupan Non-Hutan",
                           "Kehilangan_Tutupan" = "Data Kehilangan Tutupan Pohon",
                           "Emisi_Karbon" = "Data Emisi Karbon")
    
    DT::datatable(
      data_display,
      options = list(
        pageLength = 15,
        scrollX = TRUE,
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = list(
          list(extend = 'copy', text = 'Copy'),
          list(extend = 'csv', 
               text = 'Download CSV',
               filename = paste0(filename_base, '_', Sys.Date()),
               title = title_export),
          list(extend = 'excel', 
               text = 'Download Excel',
               filename = paste0(filename_base, '_', Sys.Date()),
               title = title_export)
        ),
        columnDefs = list(
          list(className = 'dt-center', targets = "_all"),
          list(width = '60px', targets = 0),
          list(width = '150px', targets = 1),
          list(width = '120px', targets = 4)
        )
      ),
      extensions = 'Buttons',
      class = 'cell-border stripe hover compact',
      rownames = FALSE
    ) %>%
      DT::formatStyle(
        columns = names(data_display)[5],
        backgroundColor = '#f3f3f3',
        color = '#1a237e',
        fontWeight = 'bold'
      )
  })
  

  
  
  # Server logic untuk Analisis Statistik
  
  # =============================================================================
  # ANALISIS KORELASI
  # =============================================================================
  
  # Data reaktif untuk analisis korelasi
  data_korelasi <- reactive({
    req(input$tahun_korelasi)
    
    # Filter data berdasarkan tahun yang dipilih
    data_filtered <- data_lahan %>%
      filter(Tahun == input$tahun_korelasi) %>%
      select(Luas_Hutan, Luas_Non_Hutan, Kehilangan_Tutupan, Emisi_Karbon) %>%
      na.omit()
    
    return(data_filtered)
  })
  
  # Matriks korelasi reaktif
  matriks_korelasi <- reactive({
    req(data_korelasi())
    
    # Hitung korelasi berdasarkan metode yang dipilih
    cor_matrix <- cor(data_korelasi(), method = input$metode_korelasi)
    
    return(cor_matrix)
  })
  
  # Plot matriks korelasi
  output$plot_korelasi <- renderPlotly({
    req(matriks_korelasi())
    
    # Konversi matriks ke format yang bisa diplot
    cor_data <- as.data.frame(matriks_korelasi()) %>%
      mutate(Var1 = rownames(.)) %>%
      gather(key = "Var2", value = "Correlation", -Var1) %>%
      mutate(
        Var1 = factor(Var1, levels = c("Luas_Hutan", "Luas_Non_Hutan", "Kehilangan_Tutupan", "Emisi_Karbon")),
        Var2 = factor(Var2, levels = c("Luas_Hutan", "Luas_Non_Hutan", "Kehilangan_Tutupan", "Emisi_Karbon")),
        # Interpretasi korelasi
        Interpretasi = case_when(
          abs(Correlation) > 0.7 ~ "Kuat",
          abs(Correlation) > 0.3 ~ "Sedang",
          TRUE ~ "Lemah"
        ),
        # Warna berdasarkan kekuatan korelasi
        Warna = case_when(
          Correlation > 0.7 ~ "#0D9276",
          Correlation > 0.3 ~ "#2ECC71", 
          Correlation > -0.3 ~ "#95A5A6",
          Correlation > -0.7 ~ "#F39C12",
          TRUE ~ "#E74C3C"
        )
      )
    
    # Buat heatmap
    p <- ggplot(cor_data, aes(x = Var1, y = Var2, fill = Correlation)) +
      geom_tile(color = "white", size = 0.5) +
      geom_text(aes(label = sprintf("%.3f", Correlation)), 
                color = "white", size = 3, fontface = "bold") +
      scale_fill_gradient2(low = "#E74C3C", mid = "#95A5A6", high = "#0D9276", 
                           midpoint = 0, limit = c(-1, 1), space = "Lab",
                           name = "Korelasi") +
      scale_x_discrete(labels = c("Luas Hutan", "Luas Non-Hutan", "Kehilangan Tutupan", "Emisi Karbon")) +
      scale_y_discrete(labels = c("Luas Hutan", "Luas Non-Hutan", "Kehilangan Tutupan", "Emisi Karbon")) +
      labs(title = paste("Matriks Korelasi", str_to_title(input$metode_korelasi), "- Tahun", input$tahun_korelasi),
           x = "", y = "") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        axis.text.y = element_text(size = 10),
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        legend.position = "bottom"
      )
    
    ggplotly(p, tooltip = c("x", "y", "fill"))
  })
  
  # Tabel korelasi detail
  output$tabel_korelasi <- DT::renderDataTable({
    req(matriks_korelasi())
    
    # Konversi matriks ke tabel dengan interpretasi
    cor_table <- as.data.frame(matriks_korelasi()) %>%
      mutate(Variabel = rownames(.)) %>%
      select(Variabel, everything()) %>%
      mutate(across(where(is.numeric), ~round(.x, 4)))
    
    # Rename kolom untuk tampilan yang lebih baik
    colnames(cor_table) <- c("Variabel", "Luas Hutan", "Luas Non-Hutan", "Kehilangan Tutupan", "Emisi Karbon")
    
    DT::datatable(cor_table, 
                  options = list(
                    pageLength = 10,
                    scrollX = TRUE,
                    dom = 'Bfrtip',
                    buttons = c('copy', 'csv', 'excel')
                  ),
                  rownames = FALSE) %>%
      formatRound(columns = 2:5, digits = 4) %>%
      formatStyle(columns = 2:5, 
                  backgroundColor = styleInterval(c(-0.7, -0.3, 0.3, 0.7), 
                                                  c("#ffebee", "#fff3e0", "#f3e5f5", "#e8f5e8", "#e0f2f1")))
  }, server = FALSE)
  
  # =============================================================================
  # ANALISIS REGRESI
  # =============================================================================
  
  # Data untuk regresi
  data_regresi <- reactive({
    req(input$var_x_regresi, input$var_y_regresi, input$tahun_regresi)
    
    # Filter data berdasarkan range tahun
    data_filtered <- data_lahan %>%
      filter(Tahun >= input$tahun_regresi[1], Tahun <= input$tahun_regresi[2]) %>%
      select(Provinsi, Tahun, Pulau, all_of(c(input$var_x_regresi, input$var_y_regresi))) %>%
      na.omit()
    
    return(data_filtered)
  })
  
  # Model regresi reaktif
  model_regresi <- reactive({
    req(data_regresi())
    
    # Buat formula regresi
    formula_str <- paste(input$var_y_regresi, "~", input$var_x_regresi)
    
    # Fit model regresi linear
    model <- lm(as.formula(formula_str), data = data_regresi())
    
    return(model)
  })
  
  # Plot scatter dengan garis regresi
  output$plot_regresi <- renderPlotly({
    req(data_regresi(), model_regresi())
    
    # Ambil data dan model
    data_plot <- data_regresi()
    model <- model_regresi()
    
    # Buat nama variabel yang lebih readable
    var_names <- list(
      "Luas_Hutan" = "Luas Hutan (Ha)",
      "Luas_Non_Hutan" = "Luas Non-Hutan (Ha)", 
      "Kehilangan_Tutupan" = "Kehilangan Tutupan (Ha)",
      "Emisi_Karbon" = "Emisi Karbon (Ton CO₂e)"
    )
    
    x_label <- var_names[[input$var_x_regresi]]
    y_label <- var_names[[input$var_y_regresi]]
    
    # R-squared
    r_squared <- summary(model)$r.squared
    
    # Buat plot
    p <- ggplot(data_plot, aes_string(x = input$var_x_regresi, y = input$var_y_regresi)) +
      geom_point(aes(color = Pulau, text = paste("Provinsi:", Provinsi, 
                                                 "<br>Tahun:", Tahun,
                                                 "<br>", x_label, ":", scales::comma(get(input$var_x_regresi)),
                                                 "<br>", y_label, ":", scales::comma(get(input$var_y_regresi)))), 
                 alpha = 0.7, size = 2) +
      geom_smooth(method = "lm", se = TRUE, color = "#0D9276", fill = "#BBE2EC", alpha = 0.3) +
      scale_color_brewer(type = "qual", palette = "Set2") +
      labs(title = paste("Analisis Regresi:", y_label, "vs", x_label),
           subtitle = paste("R² =", round(r_squared, 4), "| Periode:", input$tahun_regresi[1], "-", input$tahun_regresi[2]),
           x = x_label, y = y_label, color = "Pulau") +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5),
        axis.title = element_text(size = 11),
        legend.position = "bottom"
      )
    
    ggplotly(p, tooltip = "text")
  })
  
  # Summary model regresi
  output$summary_regresi <- renderPrint({
    req(model_regresi())
    
    model <- model_regresi()
    summary_model <- summary(model)
    
    cat("=== HASIL ANALISIS REGRESI ===\n\n")
    
    cat("Formula:", deparse(model$call$formula), "\n")
    cat("Jumlah Observasi:", nobs(model), "\n\n")
    
    cat("=== KOEFISIEN REGRESI ===\n")
    print(summary_model$coefficients)
    
    cat("\n=== STATISTIK MODEL ===\n")
    cat("R-squared:", round(summary_model$r.squared, 4), "\n")
    cat("Adjusted R-squared:", round(summary_model$adj.r.squared, 4), "\n")
    cat("F-statistic:", round(summary_model$fstatistic[1], 4), "\n")
    cat("p-value:", format.pval(pf(summary_model$fstatistic[1], 
                                   summary_model$fstatistic[2], 
                                   summary_model$fstatistic[3], 
                                   lower.tail = FALSE)), "\n")
    
    cat("\n=== INTERPRETASI ===\n")
    if(summary_model$r.squared > 0.7) {
      cat("Model memiliki kemampuan prediksi yang BAIK (R² > 0.7)\n")
    } else if(summary_model$r.squared > 0.3) {
      cat("Model memiliki kemampuan prediksi yang SEDANG (R² > 0.3)\n")
    } else {
      cat("Model memiliki kemampuan prediksi yang LEMAH (R² < 0.3)\n")
    }
  })
  
  # Plot diagnostik residual
  output$plot_residual <- renderPlotly({
    req(model_regresi())
    
    model <- model_regresi()
    residuals <- residuals(model)
    fitted_values <- fitted(model)
    
    # Buat dataframe untuk plot
    residual_data <- data.frame(
      Fitted = fitted_values,
      Residuals = residuals,
      Standardized = scale(residuals)[,1]
    )
    
    # Plot residual vs fitted
    p <- ggplot(residual_data, aes(x = Fitted, y = Residuals)) +
      geom_point(alpha = 0.6, color = "#40A2E3") +
      geom_hline(yintercept = 0, color = "#E74C3C", linetype = "dashed") +
      geom_smooth(method = "loess", se = FALSE, color = "#0D9276") +
      labs(title = "Residual vs Fitted Values",
           subtitle = "Cek asumsi homoskedastisitas",
           x = "Fitted Values", y = "Residuals") +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5)
      )
    
    ggplotly(p)
  })
  
  # =============================================================================
  # ANALISIS ANOVA
  # =============================================================================
  
  # Data untuk ANOVA
  data_anova <- reactive({
    req(input$var_anova, input$faktor_anova, input$tahun_anova)
    
    # Filter data berdasarkan range tahun
    data_filtered <- data_lahan %>%
      filter(Tahun >= input$tahun_anova[1], Tahun <= input$tahun_anova[2]) %>%
      select(Provinsi, Tahun, Pulau, all_of(c(input$var_anova, input$faktor_anova))) %>%
      na.omit()
    
    # Pastikan faktor dalam format yang benar
    if(input$faktor_anova == "Tahun") {
      data_filtered$Tahun <- as.factor(data_filtered$Tahun)
    } else {
      data_filtered$Pulau <- as.factor(data_filtered$Pulau)
    }
    
    return(data_filtered)
  })
  
  # Model ANOVA reaktif
  model_anova <- reactive({
    req(data_anova())
    
    # Buat formula ANOVA
    formula_str <- paste(input$var_anova, "~", input$faktor_anova)
    
    # Fit ANOVA
    model <- aov(as.formula(formula_str), data = data_anova())
    
    return(model)
  })
  
  # Box plot untuk ANOVA
  output$plot_boxplot_anova <- renderPlotly({
    req(data_anova())
    
    data_plot <- data_anova()
    
    # Nama variabel yang readable
    var_names <- list(
      "Luas_Hutan" = "Luas Hutan (Ha)",
      "Luas_Non_Hutan" = "Luas Non-Hutan (Ha)",
      "Kehilangan_Tutupan" = "Kehilangan Tutupan (Ha)",
      "Emisi_Karbon" = "Emisi Karbon (Ton CO₂e)"
    )
    
    y_label <- var_names[[input$var_anova]]
    
    # Buat plot berdasarkan faktor
    if(input$faktor_anova == "Pulau") {
      p <- ggplot(data_plot, aes_string(x = "Pulau", y = input$var_anova, fill = "Pulau")) +
        geom_boxplot(alpha = 0.7, outlier.alpha = 0.5) +
        geom_jitter(width = 0.2, alpha = 0.4, size = 1) +
        scale_fill_brewer(type = "qual", palette = "Set2") +
        labs(title = paste("Distribusi", y_label, "Berdasarkan Pulau"),
             x = "Pulau", y = y_label, fill = "Pulau") +
        theme_minimal() +
        theme(
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
          legend.position = "none"
        )
    } else {
      p <- ggplot(data_plot, aes_string(x = "factor(Tahun)", y = input$var_anova, fill = "factor(Tahun)")) +
        geom_boxplot(alpha = 0.7, outlier.alpha = 0.5) +
        geom_jitter(width = 0.2, alpha = 0.4, size = 1) +
        scale_fill_viridis_d(option = "C") +
        labs(title = paste("Distribusi", y_label, "Berdasarkan Tahun"),
             x = "Tahun", y = y_label, fill = "Tahun") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
          legend.position = "none"
        )
    }
    
    ggplotly(p)
  })
  
  # Hasil ANOVA
  output$hasil_anova <- renderPrint({
    req(model_anova())
    
    model <- model_anova()
    summary_anova <- summary(model)
    
    cat("=== HASIL ANALISIS ANOVA ===\n\n")
    
    cat("Variabel Dependen:", input$var_anova, "\n")
    cat("Faktor:", input$faktor_anova, "\n")
    cat("Periode:", input$tahun_anova[1], "-", input$tahun_anova[2], "\n")
    cat("Jumlah Observasi:", nrow(data_anova()), "\n\n")
    
    cat("=== TABEL ANOVA ===\n")
    print(summary_anova)
    
    # Interpretasi hasil
    p_value <- summary_anova[[1]][["Pr(>F)"]][1]
    
    cat("\n=== INTERPRETASI ===\n")
    cat("Alpha (α) = 0.05\n")
    cat("p-value =", format.pval(p_value), "\n")
    
    if(p_value < 0.05) {
      cat("KESIMPULAN: Terdapat perbedaan yang signifikan antar kelompok (p < 0.05)\n")
      cat("Tolak H₀: Rata-rata antar kelompok tidak sama\n")
    } else {
      cat("KESIMPULAN: Tidak terdapat perbedaan yang signifikan antar kelompok (p ≥ 0.05)\n")
      cat("Gagal tolak H₀: Rata-rata antar kelompok sama\n")
    }
  })
  
  # Post-hoc test Tukey HSD
  output$tabel_tukey <- DT::renderDataTable({
    req(model_anova())
    
    model <- model_anova()
    
    # Hanya lakukan Tukey HSD jika ANOVA signifikan
    summary_anova <- summary(model)
    p_value <- summary_anova[[1]][["Pr(>F)"]][1]
    
    if(p_value < 0.05) {
      # Tukey HSD
      tukey_result <- TukeyHSD(model)
      
      # Konversi ke dataframe
      tukey_df <- as.data.frame(tukey_result[[1]]) %>%
        mutate(
          Comparison = rownames(.),
          Significant = ifelse(`p adj` < 0.05, "Ya", "Tidak"),
          `p adj` = round(`p adj`, 4),
          diff = round(diff, 2),
          lwr = round(lwr, 2),
          upr = round(upr, 2)
        ) %>%
        select(Comparison, diff, lwr, upr, `p adj`, Significant)
      
      colnames(tukey_df) <- c("Perbandingan", "Selisih", "CI Bawah", "CI Atas", "p-value", "Signifikan")
      
      DT::datatable(tukey_df, 
                    options = list(
                      pageLength = 10,
                      scrollX = TRUE,
                      dom = 'Bfrtip',
                      buttons = c('copy', 'csv', 'excel')
                    ),
                    rownames = FALSE) %>%
        formatRound(columns = 2:5, digits = 4) %>%
        formatStyle("Signifikan", 
                    backgroundColor = styleEqual("Ya", "#e8f5e8"))
    } else {
      # Jika tidak signifikan, tampilkan pesan
      empty_df <- data.frame(
        Pesan = "Post-hoc test tidak dilakukan karena ANOVA tidak signifikan (p ≥ 0.05)"
      )
      
      DT::datatable(empty_df, options = list(dom = 't'), rownames = FALSE)
    }
  }, server = FALSE)
  
  
  # Di dalam server function
  output$downloadPDF <- downloadHandler(
    filename = function() {
      # Nama file yang akan didownload
      "User Guide PELIK.pdf"
    },
    content = function(file) {
      # Path ke file PDF di folder www
      # Ganti "nama_file.pdf" dengan nama file PDF Anda yang sebenarnya
      pdf_path <- file.path("www", "User Guide PELIK.pdf")
      
      # Cek apakah file ada
      if (file.exists(pdf_path)) {
        file.copy(pdf_path, file)
      } else {
        # Jika file tidak ditemukan, buat file kosong atau berikan pesan error
        stop("File PDF tidak ditemukan di folder www")
      }
    },
    contentType = "application/pdf"
  )
  
} # Tutup fungsi server

# Jalankan aplikasi
cat("Starting PELIK Dashboard with Kanit Font...\n")
shinyApp(ui = ui, server = server)

# Panduan Belajar MVVM dan Struktur File

## Jawaban singkat

Struktur proyek ini sudah baik untuk belajar MVVM karena kode dikelompokkan berdasarkan fitur, lalu berdasarkan tanggung jawab di dalam fitur tersebut. Struktur ini cukup jelas untuk pemula tanpa menambahkan layer yang belum dibutuhkan.

```text
Challenge6/
├── App/
│   └── Challenge6App.swift
├── DesignSystem/
│   └── Layout/AppSpacing.swift
├── Features/
│   └── Analysis/
│       ├── Models/
│       │   ├── AnalysisRequest.swift
│       │   └── AnalysisResult.swift
│       ├── Services/
│       │   ├── MLService.swift
│       │   └── DemoMLService.swift
│       ├── ViewModels/
│       │   └── AnalysisViewModel.swift
│       └── Views/
│           ├── AnalysisView.swift
│           └── AnalysisStatusView.swift
└── Resources/
    └── Assets.xcassets
```

Jangan menambah folder `Repository`, `Coordinator`, `UseCase`, atau `Utilities` hanya karena sering terlihat pada proyek besar. Tambahkan abstraksi ketika ada masalah nyata yang perlu diselesaikan.

## Gambaran mental MVVM

```text
Input pengguna
      ↓
AnalysisView
      ↓ memanggil analyze()
AnalysisViewModel
      ↓ membuat AnalysisRequest
MLService
      ↓ mengembalikan AnalysisResult
AnalysisViewModel.State
      ↓ dibaca oleh View
Tampilan idle, loading, success, atau failure
```

### Model

`AnalysisRequest` dan `AnalysisResult` adalah data aplikasi. Model tidak mengetahui SwiftUI, tombol, warna, atau cara data ditampilkan.

Pertanyaan untuk mengecek batasnya: “Jika UI diganti, apakah tipe data ini masih masuk akal?” Jika jawabannya ya, tipe tersebut kemungkinan berada di tempat yang benar.

### View

`AnalysisView` hanya mengatur input dan interaksi. `AnalysisStatusView` mengubah setiap state menjadi tampilan. View boleh mengetahui SwiftUI, tetapi tidak menyimpan aturan analisis pesan.

Pemisahan menjadi dua View dilakukan karena masing-masing memiliki tujuan yang mudah disebutkan:

- `AnalysisView`: form dan aksi utama;
- `AnalysisStatusView`: feedback idle, loading, success, dan failure.

Jangan memecah setiap `VStack` menjadi file baru. Buat file baru ketika sebuah bagian memiliki tanggung jawab, dapat dibaca secara mandiri, atau mulai sulit dipahami.

### ViewModel

`AnalysisViewModel` adalah penghubung antara View dan service. Ia bertanggung jawab atas:

- menyimpan teks yang sedang diedit;
- memvalidasi input kosong;
- memulai pekerjaan asynchronous;
- mengubah state secara eksplisit; dan
- mengubah error internal menjadi pesan aman untuk UI.

`@Observable` membuat perubahan properti dapat diamati SwiftUI. `@State` pada `AnalysisView` berarti View tersebut memiliki lifecycle ViewModel. `private(set)` pada `state` membolehkan View membaca state, tetapi hanya ViewModel yang boleh mengubahnya.

Satu enum `State` mencegah kombinasi yang tidak masuk akal, misalnya loading dan success tampil bersamaan.

### Service

`MLService` adalah protocol atau kontrak. ViewModel hanya tahu bahwa ia dapat mengirim `AnalysisRequest` dan menerima `AnalysisResult`; ViewModel tidak perlu tahu apakah implementasinya memakai Core ML, data lokal, atau test double.

`DemoMLService` adalah implementasi sementara agar alur MVVM dapat dijalankan. Service ini hanya mencari beberapa keyword sederhana dan bukan model machine learning. Hasilnya tidak boleh dipakai sebagai nasihat keamanan.

### App

`Challenge6App` adalah composition root: tempat objek konkret dipilih dan disambungkan. Di sinilah `DemoMLService` diberikan kepada `AnalysisView`. Ketika model asli tersedia, penggantian implementasi dimulai dari titik ini.

## Ikuti satu interaksi di kode

1. Pengguna memasukkan teks melalui binding `$viewModel.message` di `AnalysisView`.
2. Tombol membuat `Task` dan memanggil `await viewModel.analyze()`.
3. ViewModel membersihkan whitespace dan menolak input kosong.
4. ViewModel mengubah state menjadi `.loading`.
5. ViewModel membuat `AnalysisRequest` dan memanggil `MLService`.
6. Service mengembalikan `AnalysisResult` atau melempar error.
7. ViewModel memilih `.success`, `.failure`, atau `.idle` jika task dibatalkan.
8. SwiftUI membaca state baru dan memperbarui `AnalysisStatusView`.

Gunakan breakpoint pada langkah 2, 4, 5, dan 7. Jalankan aplikasi dengan Command-R, lalu gunakan Step Over untuk melihat perpindahan tanggung jawab antarlayer.

## Accessibility yang dapat dipelajari

Implementasi saat ini sengaja memakai komponen native dan semantic colors agar mendukung light mode, dark mode, serta Dynamic Type dengan lebih aman.

- `TextEditor` mempunyai label dan hint yang jelas untuk VoiceOver.
- Tombol mempunyai area sentuh minimal 44 point dan disabled saat proses berjalan.
- Loading selalu mempunyai `ProgressView` dan teks; feedback tidak bergantung pada warna.
- Success dan failure memakai gabungan icon, judul, serta penjelasan.
- Perubahan state dikirim sebagai VoiceOver announcement.
- `Form` dapat scroll ketika ukuran teks besar atau keyboard mengambil ruang layar.
- Hasil demo menyatakan batasannya secara visual dan melalui accessibility label.

Checklist manual di Simulator:

1. Aktifkan VoiceOver dan pastikan urutan bacanya: judul, input, bantuan, tombol, lalu status.
2. Ubah Dynamic Type ke ukuran accessibility terbesar dan pastikan teks tetap dapat dibaca dengan scroll.
3. Coba light mode dan dark mode; informasi harus tetap jelas tanpa mengandalkan warna.
4. Masukkan input kosong, pesan biasa, dan pesan dengan kata seperti `urgent` atau `password`.
5. Putar perangkat ke landscape dan pastikan input serta tombol tetap dapat dijangkau.

## Latihan bertahap

Kerjakan satu latihan per commit agar penyebab setiap perubahan mudah dipahami.

1. Ubah pesan validasi input kosong, lalu amati state `.failure`.
2. Tambahkan batas minimal panjang teks di ViewModel, bukan di View.
3. Buat `FailingMLService` khusus Preview untuk mempelajari error path.
4. Tulis unit test untuk transisi `idle → loading → success` dan input kosong.
5. Tambahkan tombol reset melalui method ViewModel, bukan dengan mengubah `state` dari View.
6. Setelah model tersedia, buat `CoreMLService` baru yang memenuhi protocol `MLService`.

## Tanda struktur mulai perlu berkembang

Pertimbangkan perubahan struktur hanya jika salah satu kondisi ini muncul:

- dua fitur memakai komponen UI yang benar-benar sama;
- lebih dari satu service membutuhkan konfigurasi app-wide;
- satu ViewModel memiliki beberapa alasan berbeda untuk berubah;
- navigasi memiliki banyak screen dan alur bercabang; atau
- test sulit dibuat karena dependency dibuat langsung di dalam ViewModel.

Sampai kondisi tersebut muncul, struktur kecil dan eksplisit ini lebih baik untuk belajar daripada arsitektur yang penuh folder kosong.

## Kesalahan umum

- Menjalankan Core ML langsung dari View.
- Membuat `DemoMLService` langsung di dalam ViewModel sehingga dependency sulit diganti.
- Membiarkan View mengubah `state` secara langsung.
- Menggunakan beberapa boolean seperti `isLoading`, `hasError`, dan `hasResult` yang dapat saling bertentangan.
- Menaruh warna atau nama SF Symbol di Model.
- Menganggap output `DemoMLService` sebagai prediksi nyata.
- Membuat folder baru tanpa tanggung jawab yang dapat dijelaskan.

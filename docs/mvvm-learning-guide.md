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
│       │   ├── DemoMLService.swift
│       │   ├── TextTokenizer.swift
│       │   ├── TokenBag.swift
│       │   ├── PredictionScores.swift
│       │   ├── TrainingDataValidator.swift
│       │   ├── SpamTrainingDataset.swift
│       │   ├── MultinomialNaiveBayesClassifier.swift
│       │   └── MultinomialNaiveBayesService.swift
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
      ↓ MultinomialNaiveBayesService
MultinomialNaiveBayesClassifier
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
- mengubah error internal menjadi failure yang aman untuk UI; serta
- mengabaikan result lama jika input berubah ketika service masih berjalan.

`@Observable` membuat perubahan properti dapat diamati SwiftUI. `@State` pada `AnalysisView` berarti View tersebut memiliki lifecycle ViewModel. `private(set)` pada `state` membolehkan View membaca state, tetapi hanya ViewModel yang boleh mengubahnya.

Satu enum `State` mencegah kombinasi yang tidak masuk akal, misalnya loading dan success tampil bersamaan. Failure juga berupa enum agar ViewModel tidak menyebarkan string bebas ke seluruh aplikasi.

### Service

`MLService` adalah protocol atau kontrak. ViewModel hanya tahu bahwa ia dapat mengirim `AnalysisRequest` dan menerima `AnalysisResult`; ViewModel tidak perlu tahu apakah implementasinya memakai perhitungan Swift, Core ML, atau test double.

`MultinomialNaiveBayesService` adalah adapter yang memenuhi kontrak tersebut. Dataset kecilnya berada di `SpamTrainingDataset`, sedangkan perhitungan diserahkan ke `MultinomialNaiveBayesClassifier`. Dataset ini bukan data produksi, sehingga hasilnya tidak boleh dipakai sebagai nasihat keamanan.

Bagian ML sengaja dipecah berdasarkan tahap perhitungan:

- `TextTokenizer`: teks mentah menjadi token lowercase;
- `TokenBag`: token menjadi sparse count seperti `["cash": 2]`;
- `TrainingDataValidator`: memastikan smoothing valid dan kedua label tersedia;
- `MultinomialNaiveBayesClassifier`: melatih statistik kelas dan menghitung log score; serta
- `PredictionScores`: memilih label, mempertahankan aturan tie, dan menormalisasi confidence.

Pemisahan ini bukan layer arsitektur baru. Setiap tipe hanya memberi nama pada satu langkah matematika yang sebelumnya tersembunyi di dalam classifier.

`DemoMLService` tetap tersedia sebagai pembanding sederhana, tetapi tidak dipakai oleh aplikasi utama.

### App

`Challenge6App` adalah composition root: tempat objek konkret dipilih dan disambungkan. Di sinilah `MultinomialNaiveBayesService` diberikan kepada `AnalysisView`. Ketika model Core ML tersedia, penggantian implementasi dimulai dari titik ini.

## Ikuti satu interaksi di kode

1. Pengguna memasukkan teks melalui binding `$viewModel.message` di `AnalysisView`.
2. Tombol membuat `Task` dan memanggil `await viewModel.analyze()`.
3. `AnalysisRequest(rawText:)` membersihkan whitespace dan menolak input kosong.
4. ViewModel mengubah state menjadi `.loading`.
5. ViewModel membuat `AnalysisRequest` dan memanggil `MLService`.
6. Service meminta classifier menghitung probabilitas lalu mengembalikan `AnalysisResult` atau melempar error.
7. Sebelum menerbitkan success, ViewModel memastikan message masih sama dengan request yang selesai.
8. ViewModel memilih `.success`, typed `.failure`, atau `.idle` jika task dibatalkan atau result sudah stale.
9. SwiftUI membaca state baru dan memperbarui `AnalysisStatusView`.

Gunakan breakpoint pada langkah 2, 4, 5, dan 7. Jalankan aplikasi dengan Command-R, lalu gunakan Step Over untuk melihat perpindahan tanggung jawab antarlayer.

## Urutan reconstruction dari kosong

Jangan mencoba mengingat seluruh project sebagai satu blok. Bangun kembali dependency chain berikut:

1. `MessageLabel`, `AnalysisRequest`, dan `AnalysisResult`;
2. `MLService` sebagai kontrak input-output;
3. `AnalysisViewModel.State`, `message`, dan `analyze()`;
4. `AnalysisView` yang mengirim action dan membaca state;
5. `TextTokenizer` dan `TokenBag`;
6. statistik training pada classifier;
7. log scoring dan `PredictionScores`;
8. `SpamTrainingDataset` dan concrete service; lalu
9. dependency injection dari `Challenge6App`.

Setelah setiap langkah, jawab empat pertanyaan: siapa yang memanggilnya, input-nya apa, output-nya apa, dan data pergi ke mana berikutnya.

## Automated checks

Jalankan:

```bash
./Scripts/run-classifier-checks.sh
```

Runner tersebut mengompilasi source nyata bersama test executable. Coverage saat ini melindungi tokenisasi, sparse counts, score selection, training validation, prediksi classifier, normalisasi request, serta transisi ViewModel untuk empty input, success, error, cancellation, dan stale result.

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

1. Tambahkan test untuk pesan berisi token yang semuanya tidak dikenal, lalu jelaskan mengapa prior menentukan hasil.
2. Tambahkan batas minimal panjang teks melalui `AnalysisRequest`, bukan di View.
3. Buat service tertunda dan amati state `.loading` sebelum result dilepas.
4. Ubah tie policy di `PredictionScores` hanya setelah menulis test untuk keputusan baru.
5. Tambahkan tombol reset melalui method ViewModel, bukan dengan mengubah `state` dari View.
6. Setelah alur saat ini dipahami, buat `CoreMLService` baru yang memenuhi protocol `MLService`, lalu ganti satu baris dependency di `Challenge6App`.

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
- Membuat `MultinomialNaiveBayesService` langsung di dalam ViewModel sehingga dependency sulit diganti.
- Membiarkan View mengubah `state` secara langsung.
- Menggunakan beberapa boolean seperti `isLoading`, `hasError`, dan `hasResult` yang dapat saling bertentangan.
- Menaruh warna atau nama SF Symbol di Model.
- Menganggap output `DemoMLService` sebagai prediksi nyata.
- Membuat folder baru tanpa tanggung jawab yang dapat dijelaskan.

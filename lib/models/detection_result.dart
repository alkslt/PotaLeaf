import 'dart:convert';

/// Represents a single plant disease detection result.
class DetectionResult {
  final String id;
  final String diseaseName;
  final String diseaseType; // Virus, Pest, Healthy, Fungi, Bacteria
  final double confidence; // 0–100
  final String imageUrl;
  final bool isLocalFile;
  final DateTime date;
  final String gejala;
  final String penyebab;
  final String caraPencegahan;

  DetectionResult({
    required this.id,
    required this.diseaseName,
    required this.diseaseType,
    required this.confidence,
    required this.imageUrl,
    this.isLocalFile = false,
    required this.date,
    required this.gejala,
    required this.penyebab,
    required this.caraPencegahan,
  });

  // ── JSON serialization ──

  Map<String, dynamic> toJson() => {
        'id': id,
        'diseaseName': diseaseName,
        'diseaseType': diseaseType,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'isLocalFile': isLocalFile,
        'date': date.toIso8601String(),
        'gejala': gejala,
        'penyebab': penyebab,
        'caraPencegahan': caraPencegahan,
      };

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'] as String,
      diseaseName: json['diseaseName'] as String,
      diseaseType: json['diseaseType'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      isLocalFile: json['isLocalFile'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
      gejala: json['gejala'] as String,
      penyebab: json['penyebab'] as String,
      caraPencegahan: json['caraPencegahan'] as String,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory DetectionResult.fromJsonString(String source) =>
      DetectionResult.fromJson(jsonDecode(source) as Map<String, dynamic>);

  // ── Static samples data for demo/testing mapped to local assets ──

  static List<DetectionResult> get staticSamples => [
        DetectionResult(
          id: 'sample_bacteria',
          diseaseName: 'Bacteria',
          diseaseType: 'Bacteria',
          confidence: 92.5,
          imageUrl: 'assets/placeholder/bacteria.jpg',
          date: DateTime.now().subtract(const Duration(days: 4)),
          gejala: 'Daun layu mendadak, timbul bercak basah kehitaman berair, dan kadang batang tanaman membusuk mengeluarkan lendir berbau.',
          penyebab: 'Disebabkan oleh serangan bakteri patogen tanaman (seperti Ralstonia atau Xanthomonas) yang menyebar melalui air tanah dan alat perkebunan.',
          caraPencegahan: 'Gunakan bibit steril bebas bakteri, perbaiki sistem drainase tanah agar air tidak menggenang, cabut tanaman sakit, dan semprot bakterisida tembaga.',
        ),
        DetectionResult(
          id: 'sample_fungi',
          diseaseName: 'Fungi',
          diseaseType: 'Fungi',
          confidence: 85.7,
          imageUrl: 'assets/placeholder/fungi.jpg',
          date: DateTime.now().subtract(const Duration(days: 6)),
          gejala: 'Timbul bercak kecoklatan konsentris melingkar pada daun, bercak bertepung putih di bawah permukaan daun, hingga daun mengering dan rontok.',
          penyebab: 'Infeksi spora jamur patogen karena kelembaban udara yang terlalu tinggi dan sirkulasi udara kebun yang kurang optimal.',
          caraPencegahan: 'Atur jarak tanam ideal agar sirkulasi udara lancar, kurangi kelembaban tajuk, potong daun terinfeksi, dan semprotkan fungisida secara teratur.',
        ),
        DetectionResult(
          id: 'sample_healthy',
          diseaseName: 'Healthy',
          diseaseType: 'Healthy',
          confidence: 98.1,
          imageUrl: 'assets/placeholder/healthy.JPG',
          date: DateTime.now().subtract(const Duration(days: 1)),
          gejala: 'Daun berwarna hijau segar mengkilap sempurna, memiliki tekstur kenyal dan kokoh, tidak terdapat noda bercak karat ataupun bekas gigitan hama.',
          penyebab: 'Kondisi tanaman sangat sehat karena sistem pemeliharaan yang baik, pengairan teratur, dan pemupukan nutrisi seimbang.',
          caraPencegahan: 'Pertahankan teknik budidaya tanaman yang baik, lakukan penyiraman rutin pagi/sore secara teratur, serta lakukan pemupukan organik periodik.',
        ),
        DetectionResult(
          id: 'sample_nematode',
          diseaseName: 'Nematode',
          diseaseType: 'Nematode',
          confidence: 88.2,
          imageUrl: 'assets/placeholder/nematode.jpg',
          date: DateTime.now().subtract(const Duration(days: 8)),
          gejala: 'Tanaman tumbuh kerdil terhambat, daun menguning layu layaknya kekurangan air, serta terbentuk bintil-bintil bengkak pada bagian akar saat dicabut.',
          penyebab: 'Disebabkan oleh serangan cacing mikroskopis Nematoda puru akar (Meloidogyne spp.) yang merusak sistem penyerapan unsur hara akar.',
          caraPencegahan: 'Gunakan nematisida organik berbahan alami, lakukan rotasi tanaman dengan bunga marigold (tagetes) untuk mengusir cacing nematoda.',
        ),
        DetectionResult(
          id: 'sample_pest',
          diseaseName: 'Pest',
          diseaseType: 'Pest',
          confidence: 87.3,
          imageUrl: 'assets/placeholder/pest.jpg',
          date: DateTime.now().subtract(const Duration(days: 3)),
          gejala: 'Daun robek berlubang-lubang besar, keriting menggulung, terdapat bekas gigitan ulat atau koloni serangga kutu daun berkumpul di balik pucuk muda.',
          penyebab: 'Serangan serangga hama pemakan jaringan daun seperti ulat grayak, belalang, ataupun kutu daun penghisap cairan sel.',
          caraPencegahan: 'Lakukan sanitasi kebun dari gulma inang, pasang perangkap lem kuning berperekat, dan aplikasikan insektisida nabati secara berkala.',
        ),
        DetectionResult(
          id: 'sample_phytophthora',
          diseaseName: 'Phytophthora',
          diseaseType: 'Phytophthora',
          confidence: 89.4,
          imageUrl: 'assets/placeholder/phytophthora.jpg',
          date: DateTime.now().subtract(const Duration(days: 5)),
          gejala: 'Bercak coklat basah kehitaman lebar yang merambat cepat pada daun dan batang utama, pangkal batang melunak membusuk berwarna coklat gelap.',
          penyebab: 'Serangan oomycete patogen busuk Phytophthora yang sangat aktif menyebar di lingkungan bersuhu dingin dengan kelembaban sangat tinggi.',
          caraPencegahan: 'Hindari menyiram tanaman dari atas tajuk daun, musnahkan sisa tanaman sakit, semprot fungisida sistemik berbahan aktif metalaksil.',
        ),
        DetectionResult(
          id: 'sample_virus',
          diseaseName: 'Virus',
          diseaseType: 'Virus',
          confidence: 92.5,
          imageUrl: 'assets/placeholder/virus.jpg',
          date: DateTime.now().subtract(const Duration(days: 2)),
          gejala: 'Daun tanaman mengeriting mengkerut kaku, muncul pola belang mosaik kuning-hijau pada permukaan daun, dan buah mengerdil tidak sempurna.',
          penyebab: 'Infeksi virus mosaik tanaman (seperti Gemini virus atau ToMV) yang ditularkan lewat hisapan serangga pembawa (vektor) kutu kebul.',
          caraPencegahan: 'Kendalikan serangga kutu kebul pembawa virus menggunakan perangkap kuning, cabut tanaman sakit agar tidak menular, gunakan benih steril.',
        ),
      ];

  /// Factory constructor to map TFLite prediction results to rich descriptive templates
  factory DetectionResult.fromClassification({
    required String detectedLabel,
    required double confidence,
    required String customImagePath,
    bool isLocalFile = true,
  }) {
    final template = staticSamples.firstWhere(
      (item) => item.diseaseName.toLowerCase() == detectedLabel.toLowerCase(),
      orElse: () => staticSamples.firstWhere((item) => item.diseaseName == 'Healthy'),
    );

    return DetectionResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      diseaseName: template.diseaseName,
      diseaseType: template.diseaseType,
      confidence: confidence,
      imageUrl: customImagePath,
      isLocalFile: isLocalFile,
      date: DateTime.now(),
      gejala: template.gejala,
      penyebab: template.penyebab,
      caraPencegahan: template.caraPencegahan,
    );
  }
}

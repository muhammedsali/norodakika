// NÖRODAKİKA - MEMORY BANK (Tüm Uygulama Hafıza Yapısı)

class MemoryBank {
  // 1) Bilişsel Kategoriler
  static const categories = [
    "Hafıza",
    "Dikkat",
    "Refleks",
    "Mantık",
    "Sayısal Zeka",
    "Görsel Algı",
    "Dil"
  ];

  // 2) Mini Oyun Listesi
  static const games = [
    {
      "id": "REF01",
      "name": "Reflex Tap",
      "area": "Refleks",
      "intelligence": "bodily",
      "description": "Tepki süresi ölçümü + Go/No-Go mekanizması."
    },
    {
      "id": "REF02",
      "name": "Reflex Dash",
      "area": "Refleks",
      "intelligence": "bodily",
      "description": "Şeritler üzerinde kayan hedeflere hızlı tepki."
    },
    {
      "id": "ATT01",
      "name": "Stroop Tap",
      "area": "Dikkat",
      "intelligence": "intrapersonal",
      "description": "Renk-kelime uyumsuzluğu ile dikkat testi."
    },
    {
      "id": "ATT02",
      "name": "Focus Line",
      "area": "Dikkat + Görsel Algı",
      "intelligence": "visual",
      "description": "Yatay çizgi üzerindeki hedef renk noktalara odaklanma."
    },
    {
      "id": "MEM01",
      "name": "N-Back Mini",
      "area": "Hafıza + Dikkat",
      "intelligence": "intrapersonal",
      "description": "Çalışan bellek testi (1-back / 2-back)."
    },
    {
      "id": "LOG01",
      "name": "Logic Puzzle",
      "area": "Mantık + Görsel Algı",
      "intelligence": "logical",
      "description": "Mantık dizisi çözme + görsel algı."
    },
    {
      "id": "NUM01",
      "name": "Quick Math",
      "area": "Sayısal Zeka",
      "intelligence": "logical",
      "description": "Zaman baskılı mental aritmetik."
    },
    {
      "id": "MEM02",
      "name": "Memory Board",
      "area": "Hafıza + Görsel Algı",
      "intelligence": "visual",
      "description": "Kart eşleştirme + görsel hafıza."
    },
    {
      "id": "MEM03",
      "name": "Recall Phase",
      "area": "Dil + Hafıza",
      "intelligence": "verbal",
      "description": "Kelime gösterim ve hatırlama testi."
    },
    {
      "id": "MEM04",
      "name": "Sequence Echo",
      "area": "Hafıza + Dikkat",
      "intelligence": "musical",
      "description": "Gösterilen hücre sırasını aynen tekrar et."
    },
    {
      "id": "VIS02",
      "name": "Odd One Out",
      "area": "Görsel Algı + Dikkat",
      "intelligence": "visual",
      "description": "Farklı kartı hızlıca bulma oyunu."
    },
    {
      "id": "LANG02",
      "name": "Word Sprint",
      "area": "Dil",
      "intelligence": "verbal",
      "description": "Gerçek ve uydurma kelimeleri ayırt etme oyunu."
    },
    {
      "id": "MUS01",
      "name": "Rhythm Match",
      "area": "Dikkat + Refleks",
      "intelligence": "musical",
      "description": "Ritmi tekrar et: kısa ses/ritim dizilerini doğru sırayla yakala."
    },
    {
      "id": "SOC01",
      "name": "Emotion Mirror",
      "area": "Dil + Dikkat",
      "intelligence": "social",
      "description": "Duygu ifadelerini eşleştir: hızlı karar + sosyal ipuçlarını ayırt etme."
    },
    {
      "id": "NAT01",
      "name": "Nature Sort",
      "area": "Mantık + Görsel Algı",
      "intelligence": "naturalist",
      "description": "Doğa temalı nesneleri kategorilere ayır: örüntü tanıma ve sınıflandırma."
    },
    {
      "id": "KIN01",
      "name": "Balance Tap",
      "area": "Refleks",
      "intelligence": "bodily",
      "description": "Dengeyi koru: ekranın iki yanına hızlı ve dengeli dokunuşlarla hedefi ortada tut."
    },
    {
      "id": "SPA01",
      "name": "Route Builder",
      "area": "Mantık + Görsel Algı",
      "intelligence": "visual",
      "description": "En kısa yolu kur: ızgara üzerinde engelleri aşarak rota planla."
    },
    {
      "id": "INT01",
      "name": "Focus Check-In",
      "area": "Dikkat",
      "intelligence": "intrapersonal",
      "description": "Kısa odak check-in: dikkatini toparla ve gün içi mini hedefi tamamla."
    }
  ];

  // 3) Kullanıcı Data Modelleri
  static Map<String, dynamic> createUserModel(String uid) {
    return {
      "uid": uid,
      "dailyPlan": [],
      "stats": {
        "Hafıza": 0,
        "Dikkat": 0,
        "Refleks": 0,
        "Mantık": 0,
        "Sayısal Zeka": 0,
        "Görsel Algı": 0,
        "Dil": 0,
      },
      "history": [],
      "createdAt": DateTime.now().toIso8601String(),
    };
  }

  // 4) Adaptif Zorluk Sistemi
  static double updateDifficulty(double currentMu, double successRate) {
    const double k = 24; // ELO benzeri katsayı
    double expected = 0.65; // hedef başarı oranı
    double newMu = currentMu + k * (successRate - expected);
    
    // Alt-üst limit
    if (newMu < 0.5) newMu = 0.5;
    if (newMu > 3.0) newMu = 3.0;
    
    return double.parse(newMu.toStringAsFixed(2));
  }

  // 5) Günlük Plan Üretimi (1–3 dakikalık seanslar)
  static List<Map<String, dynamic>> generateDailyPlan() {
    return [
      {
        "id": "REF01",
        "duration": 30,
      },
      {
        "id": "MEM01",
        "duration": 45,
      },
      {
        "id": "ATT01",
        "duration": 45,
      },
    ];
  }

  // 6) API endpoint hafızası
  static const api = {
    "register": "/auth/register",
    "login": "/auth/login",
    "attempt": "/attempt", // oyun bitince gönderilecek
    "dailyPlan": "/daily-plan",
    "history": "/history",
    "stats": "/stats",
  };

  // 7) Radar Graph İçin Stat Hesaplama
  static Map<String, double> calculateRadarStats(List history) {
    Map<String, List<double>> grouped = {
      "Hafıza": [],
      "Dikkat": [],
      "Refleks": [],
      "Mantık": [],
      "Sayısal Zeka": [],
      "Görsel Algı": [],
      "Dil": [],
    };

    for (var h in history) {
      if (h is Map && h.containsKey("area") && h.containsKey("score")) {
        final rawArea = h["area"].toString();
        final score = (h["score"] as num).toDouble();

        // "Hafıza + Dikkat" gibi çok alanlı etiketleri parçala
        final parts = rawArea.split("+").map((s) => s.trim()).where((s) => s.isNotEmpty);
        for (final part in parts) {
          if (grouped.containsKey(part)) {
            grouped[part]!.add(score);
          }
        }
      }
    }

    Map<String, double> result = {};
    grouped.forEach((key, value) {
      if (value.isEmpty) {
        result[key] = 0;
      } else {
        result[key] = value.reduce((a, b) => a + b) / value.length;
      }
    });

    // 0–100 normalize et: en yüksek alan 100 olacak şekilde ölçekle
    double maxVal = 0;
    result.forEach((_, v) {
      if (v > maxVal) maxVal = v;
    });

    if (maxVal > 0) {
      result.updateAll((key, value) => double.parse(((value / maxVal) * 100).toStringAsFixed(1)));
    }

    return result;
  }

}


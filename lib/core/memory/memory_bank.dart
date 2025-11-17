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
      "description": "Tepki süresi ölçümü + Go/No-Go mekanizması."
    },
    {
      "id": "ATT01",
      "name": "Stroop Tap",
      "area": "Dikkat",
      "description": "Renk-kelime uyumsuzluğu ile dikkat testi."
    },
    {
      "id": "MEM01",
      "name": "N-Back Mini",
      "area": "Hafıza + Dikkat",
      "description": "Çalışan bellek testi (1-back / 2-back)."
    },
    {
      "id": "LOG01",
      "name": "Logic Puzzle",
      "area": "Mantık + Görsel Algı",
      "description": "Mantık dizisi çözme + görsel algı."
    },
    {
      "id": "NUM01",
      "name": "Quick Math",
      "area": "Sayısal Zeka",
      "description": "Zaman baskılı mental aritmetik."
    },
    {
      "id": "MEM02",
      "name": "Memory Board",
      "area": "Hafıza + Görsel Algı",
      "description": "Kart eşleştirme + görsel hafıza."
    },
    {
      "id": "MEM03",
      "name": "Recall Phase",
      "area": "Dil + Hafıza",
      "description": "Kelime gösterim ve hatırlama testi."
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
        String area = h["area"].toString();
        if (grouped.containsKey(area)) {
          grouped[area]!.add((h["score"] as num).toDouble());
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

    return result;
  }

}


import firebase_admin
from firebase_admin import credentials, firestore
import csv
import sys
import os

# Firebase admin SDK ile bağlanmak için gereken API dosyasının yolu.
SERVICE_ACCOUNT_KEY_PATH = "serviceAccountKey.json"

if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
    print(f"\n[!] HATA: '{SERVICE_ACCOUNT_KEY_PATH}' dosyası ile ayni klasörde bulunamadı!")
    print("\nLÜTFEN ŞU ADIMLARI İZLEYİN:")
    print("1. Firebase Konsoluna gidin (https://console.firebase.google.com/)")
    print("2. Proje Ayarları (Sol üstteki çark) -> 'Hizmet Hesapları' (Service Accounts) sekmesine tıklayın.")
    print("3. 'Yeni özel anahtar oluştur' (Generate new private key) butonuna basın.")
    print("4. İndirilecek olan .json dosyasının adını 'serviceAccountKey.json' olarak değiştirin.")
    print("5. Bu dosyayı python dosyasının (export_surveys.py) bulunduğu klasörün içine koyun.")
    print("6. Ardından kodu tekrar çalıştırın.\n")
    sys.exit(1)

print("Firebase'e güvenli bağlantı kuruluyor...")
try:
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print(f"Bağlantı sırasında hata oluştu: {e}")
    sys.exit(1)

print("Veritabanından kullanıcı verileri ve anketleri çekiliyor. Lütfen bekleyin...")
users_ref = db.collection('users')
users = users_ref.stream()

data_list = []

for user in users:
    uid = user.id
    user_data = user.to_dict()
    
    # Kullanıcının temel bilgileri
    row = {
        "User_ID": uid,
        "Isim": user_data.get('displayName', 'Bilinmiyor'),
        "On_Testi_Bitirdi_Mi": "Evet" if user_data.get('hasCompletedPreTest', False) else "Hayır",
        "Son_Testi_Bitirdi_Mi": "Evet" if user_data.get('hasCompletedPostTest', False) else "Hayır",
    }

    # Pre Test (Ön Test) verilerini çek (Eğer varsa)
    pre_test_ref = users_ref.document(uid).collection('surveys').document('pre_test').get()
    if pre_test_ref.exists:
        pt_data = pre_test_ref.to_dict()
        row["Cinsiyet"] = pt_data.get("cinsiyet", "")
        row["Sinif"] = pt_data.get("sinif", "")
        row["Not_Ortalamasi"] = pt_data.get("not_ortalamasi", "")
        row["Mobil_Oyun_Suresi"] = pt_data.get("mobil_oyun_suresi", "")
        row["Casual_Oyun_Suresi"] = pt_data.get("casual_oyun_suresi", "")
        row["Masaustu_Oyun_Suresi"] = pt_data.get("masaustu_oyun_suresi", "")
        row["Internet_Suresi"] = pt_data.get("internet_kullanim_suresi", "")
        
        # Ön Test Likert Soruları (q8 ile q12 arası)
        for i in range(8, 13):
            row[f"OnTest_Tutum_Soru_{i}"] = pt_data.get(f"q{i}", "")

    # Post Test (Son Test) verilerini çek (Eğer varsa)
    post_test_ref = users_ref.document(uid).collection('surveys').document('post_test').get()
    if post_test_ref.exists:
        post_data = post_test_ref.to_dict()
        # Son test İlk 5 soru (Ön testteki sorularla aynı)
        for i in range(1, 6):
            row[f"SonTest_Tutum_Soru_{i}"] = post_data.get(f"q{i}", "")
            
        # Son test Oyuna Özel Değerlendirme (10 Soru)
        for i in range(6, 16):
            row[f"SonTest_Oyun_Degerlendirme_{i}"] = post_data.get(f"q{i}", "")

    data_list.append(row)

if not data_list:
    print("Hiç kullanıcı verisi bulunamadı.")
    sys.exit(0)

# CSV alan adlarını (Sütunları) düzenli bir sıraya sokalım
fieldnames = [
    "User_ID", "Isim", "On_Testi_Bitirdi_Mi", "Son_Testi_Bitirdi_Mi",
    "Cinsiyet", "Sinif", "Not_Ortalamasi", 
    "Mobil_Oyun_Suresi", "Casual_Oyun_Suresi", "Masaustu_Oyun_Suresi", "Internet_Suresi"
]

# Ön Test sorularını ekle
for i in range(8, 13):
    fieldnames.append(f"OnTest_Tutum_Soru_{i}")

# Son Test sorularını ekle
for i in range(1, 6):
    fieldnames.append(f"SonTest_Tutum_Soru_{i}")
for i in range(6, 16):
    fieldnames.append(f"SonTest_Oyun_Degerlendirme_{i}")

# CSV (Excel uyumlu) formatında kaydetme işlemi
OUTPUT_FILE = "anket_sonuclari.csv"
with open(OUTPUT_FILE, mode='w', encoding='utf-8-sig', newline='') as file:
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(data_list)

print(f"\n✅ BAŞARILI! Toplam {len(data_list)} kullanıcının sisteme kayıtlı verisi '{OUTPUT_FILE}' dosyasına aktarıldı.")
print("Bu belgeyi çift tıklayarak yönergeleri izleyip Excel ile hızlıca açıp analizlerinizi yapabilirsiniz.")

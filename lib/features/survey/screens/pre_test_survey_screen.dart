import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/survey_likert_scale.dart';

class PreTestSurveyScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onCompleted;

  const PreTestSurveyScreen({super.key, required this.onCompleted});

  @override
  ConsumerState<PreTestSurveyScreen> createState() => _PreTestSurveyScreenState();
}

class _PreTestSurveyScreenState extends ConsumerState<PreTestSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form State
  String? _gender;
  String? _grade;
  final _gpaController = TextEditingController();
  final _mobileGameController = TextEditingController();
  final _casualGameController = TextEditingController();
  final _desktopGameController = TextEditingController();
  final _internetController = TextEditingController();

  final Map<int, int> _likertAnswers = {};

  final List<String> _grades = [
    'Üniversite 1', 
    'Üniversite 2', 
    'Üniversite 3', 
    'Üniversite 4'
  ];

  final List<String> _likertQuestions = [
    'Mezuniyet sonrası oyun sektöründe çalışmayı düşünüyorum.',
    'Eğitsel içerikli oyunlar eğlenceli olabilir.',
    'Eğitsel içerikli oyunlar kullanıcıların akademik başarısını arttırır.',
    'Eğitsel içerikli oyun oynayan kullanıcılar daha az saldırgan davranış gösterir.',
    'Eğitsel içerikli oyunlar diğer oyunlara göre daha az bağımlılık yapar.',
  ];

  @override
  void dispose() {
    _gpaController.dispose();
    _mobileGameController.dispose();
    _casualGameController.dispose();
    _desktopGameController.dispose();
    _internetController.dispose();
    super.dispose();
  }

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if gender and grade are selected
    if (_gender == null || _grade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen cinsiyet ve sınıf bilgilerinizi seçin.')),
      );
      return;
    }

    // Check if all likert questions are answered
    if (_likertAnswers.length < _likertQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm derecelendirme sorularını cevaplayın.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userResponse = ref.read(currentUserProvider).value;
      if (userResponse == null) throw 'Kullanıcı bulunamadı';

      final firestoreService = ref.read(firestoreServiceProvider);

      final answers = {
        'cinsiyet': _gender,
        'sinif': _grade,
        'not_ortalamasi': _gpaController.text,
        'mobil_oyun_suresi': num.tryParse(_mobileGameController.text) ?? 0,
        'casual_oyun_suresi': num.tryParse(_casualGameController.text) ?? 0,
        'masaustu_oyun_suresi': num.tryParse(_desktopGameController.text) ?? 0,
        'internet_kullanim_suresi': num.tryParse(_internetController.text) ?? 0,
        ...Map.fromEntries(_likertAnswers.entries.map((e) => MapEntry('q${e.key + 8}', e.value))),
      };

      await firestoreService.saveSurveyResult(
        userId: userResponse.uid,
        surveyType: 'pre_test',
        answers: answers,
      );

      await widget.onCompleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, String hint, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(color: isDarkMode ? Colors.white70 : Colors.black54),
      hintStyle: GoogleFonts.inter(color: isDarkMode ? Colors.white30 : Colors.black38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D59F2), width: 2),
      ),
      filled: true,
      fillColor: isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.7) : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0D59F2);
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Nörodakika Ön Test Anketi',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textColor),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Hoş Geldiniz!',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Oyuna başlamadan önce sizi daha iyi tanımak ve oyunların etkisini ölçmek için bu kısa anketi doldurmanızı rica ediyoruz. Vereceğiniz bilgiler tamamen gizli tutulacak ve sadece bilimsel araştırma amacıyla kullanılacaktır. Tüm soruların cevaplanması zorunludur.',
                      style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Text('1. Demografik Bilgiler', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('Cinsiyet', 'Cinsiyetinizi seçin', isDarkMode),
                dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                initialValue: _gender,
                items: ['Kadın', 'Erkek', 'Belirtmek İstemiyorum'].map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) => setState(() => _gender = val),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('Sınıf', 'Sınıfınızı seçin', isDarkMode),
                dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                initialValue: _grade,
                items: _grades.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) => setState(() => _grade = val),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _gpaController,
                style: GoogleFonts.inter(color: textColor),
                decoration: _buildInputDecoration('Not Ortalaması', 'Örn: 85 veya 3.20', isDarkMode),
                validator: (val) => val == null || val.isEmpty ? 'Lütfen not ortalamanızı girin' : null,
              ),
              const SizedBox(height: 40),

              Text('2. Oyun ve İnternet Kullanım Alışkanlıkları', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              Text('(Sınav haftası dışındaki ortalama haftalık saat süresi)', style: GoogleFonts.inter(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 13)),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _mobileGameController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: textColor),
                decoration: _buildInputDecoration('Mobil Oyun Oynama Süresi', 'Saat cinsinden (örn: 5)', isDarkMode),
                validator: (val) => val == null || val.isEmpty ? 'Lütfen bir değer girin' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _casualGameController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: textColor),
                decoration: _buildInputDecoration('Gündelik (Casual) Oyun Oynama Süresi', 'Saat cinsinden (örn: 3)', isDarkMode),
                validator: (val) => val == null || val.isEmpty ? 'Lütfen bir değer girin' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _desktopGameController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: textColor),
                decoration: _buildInputDecoration('Masaüstü Oyun Oynama Süresi', 'Saat cinsinden (örn: 10)', isDarkMode),
                validator: (val) => val == null || val.isEmpty ? 'Lütfen bir değer girin' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _internetController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: textColor),
                decoration: _buildInputDecoration('Aylık Toplam İnternet Kullanım Süresi', 'Saat cinsinden (örn: 40)', isDarkMode),
                validator: (val) => val == null || val.isEmpty ? 'Lütfen bir değer girin' : null,
              ),
              const SizedBox(height: 40),

              Text('3. Eğitsel Oyunlara Karşı Tutum', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),

              ...List.generate(_likertQuestions.length, (index) {
                return SurveyLikertScale(
                  questionIndex: index + 8, // Previous questions were 1 to 7
                  questionText: _likertQuestions[index],
                  selectedValue: _likertAnswers[index],
                  onChanged: (val) => setState(() => _likertAnswers[index] = val),
                );
              }),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitSurvey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: primaryColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text('Anketi Tamamla ve Oyuna Başla', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

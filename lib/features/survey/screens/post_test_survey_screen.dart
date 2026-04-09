import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/survey_likert_scale.dart';

class PostTestSurveyScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onCompleted;

  const PostTestSurveyScreen({super.key, required this.onCompleted});

  @override
  ConsumerState<PostTestSurveyScreen> createState() => _PostTestSurveyScreenState();
}

class _PostTestSurveyScreenState extends ConsumerState<PostTestSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Map<int, int> _likertAnswers = {};

  final List<String> _generalQuestions = [
    'Mezuniyet sonrası oyun sektöründe çalışmayı düşünüyorum.',
    'Eğitsel içerikli oyunlar eğlenceli olabilir.',
    'Eğitsel içerikli oyunlar kullanıcıların akademik başarısını arttırır.',
    'Eğitsel içerikli oyun oynayan kullanıcılar daha az saldırgan davranış gösterir.',
    'Eğitsel içerikli oyunlar diğer oyunlara göre daha az bağımlılık yapar.',
  ];

  final List<String> _gameSpecificQuestions = [
    'Genel olarak kullanıcı arayüzünü (UI) beğendim.',
    'Oyunlar sürükleyiciydi.',
    'Oyunlar genel olarak yeterliydi.',
    'Oyunlarda meydan okuma (Challenge) vardı.',
    'Oyunlar pozitif etki bıraktı. / Oyunlar çoklu zeka için faydalıydı.',
    'Odaklanmayı güçlendirebilir (focus).',
    'Mantıksal zekayı geliştirebilir (Logic).',
    'Görsel zekayı (Visual) geliştirebilir.',
    'Refleksleri/hızı (reflex/speed) geliştirebilir.',
    'Sözel zekayı geliştirebilir.',
  ];

  Future<void> _submitSurvey() async {
    final totalQuestionsCount = _generalQuestions.length + _gameSpecificQuestions.length;
    
    // Check if all likert questions are answered
    if (_likertAnswers.length < totalQuestionsCount) {
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
        ...Map.fromEntries(_likertAnswers.entries.map((e) => MapEntry('q${e.key + 1}', e.value))),
      };

      await firestoreService.saveSurveyResult(
        userId: userResponse.uid,
        surveyType: 'post_test',
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
          'Nörodakika Son Test Anketi',
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
                        const Icon(Icons.stars_rounded, color: primaryColor, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Tebrikler!',
                          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belirli bir ilerlemeye ulaştınız. Oyun deneyiminizi ve oyunların sizlere etkisini ölçmek için bu son anketi doldurmanızı rica ediyoruz. İlginiz ve katılımınız için çok teşekkür ederiz.',
                      style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Text('1. Eğitsel Oyunlara Karşı Tutum', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),

              ...List.generate(_generalQuestions.length, (index) {
                return SurveyLikertScale(
                  questionIndex: index + 1,
                  questionText: _generalQuestions[index],
                  selectedValue: _likertAnswers[index],
                  onChanged: (val) => setState(() => _likertAnswers[index] = val),
                );
              }),

              const SizedBox(height: 40),
              
              Text('2. Nörodakika Değerlendirmesi', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 20),

              ...List.generate(_gameSpecificQuestions.length, (index) {
                final globalIdx = index + _generalQuestions.length;
                return SurveyLikertScale(
                  questionIndex: globalIdx + 1,
                  questionText: _gameSpecificQuestions[index],
                  selectedValue: _likertAnswers[globalIdx],
                  onChanged: (val) => setState(() => _likertAnswers[globalIdx] = val),
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
                    : Text('Anketi Tamamla', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
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

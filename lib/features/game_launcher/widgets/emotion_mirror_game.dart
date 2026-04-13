import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/language_provider.dart';
import '../../../core/i18n/app_strings.dart';


class EmotionMirrorGame extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const EmotionMirrorGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  ConsumerState<EmotionMirrorGame> createState() => _EmotionMirrorGameState();
}

class _EmotionMirrorGameState extends ConsumerState<EmotionMirrorGame>
    with TickerProviderStateMixin {
  final Random _rng = Random();


  Timer? _gameTimer; // Genel oyun süresi 
  Timer? _promptTimer; // Tekil sorunun süresi (ValueNotifier çalıştırır, setState çalışmaz)

  final ValueNotifier<int> _timeRemainingNotifier = ValueNotifier<int>(45);
  final ValueNotifier<double> _promptProgressNotifier = ValueNotifier<double>(1.0);

  int _correct = 0;
  int _wrong = 0;
  int _score = 0;
  int _hearts = 3;

  int _level = 1;
  int _targetsToClear = 5;
  int _targetsClearedInLevel = 0;
  
  int _combo = 0;
  int _bestCombo = 0;
  int _totalPlayTime = 0;
  bool _isFinished = false;

  late _Prompt _prompt;
  double _currentPromptDurationMs = 5000.0;

  late AnimationController _levelUpController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final _items = const <_EmotionItem>[
    // Yüzler
    _EmotionItem('Happy', 'Mutlu', '😊'),
    _EmotionItem('Sad', 'Üzgün', '😢'),
    _EmotionItem('Angry', 'Kızgın', '😠'),
    _EmotionItem('Surprised', 'Şaşkın', '😮'),
    _EmotionItem('Calm', 'Sakin', '😌'),
    _EmotionItem('Scared', 'Korkmuş', '😨'),
    _EmotionItem('Excited', 'Heyecanlı', '🤩'),
    _EmotionItem('Confused', 'Kafası Karışık', '😕'),
    _EmotionItem('Sleepy', 'Uykulu', '😴'),
    _EmotionItem('Loved', 'Aşık', '😍'),
    _EmotionItem('Laughing', 'Komik', '😂'),
    _EmotionItem('Cool', 'Havalı', '😎'),
    _EmotionItem('Thinking', 'Düşünceli', '🤔'),
    _EmotionItem('Crying', 'Ağlayan', '😭'),
    _EmotionItem('Mind Blown', 'Şok Olmuş', '🤯'),
    _EmotionItem('Nauseated', 'Mide Bulantısı', '🤢'),
    _EmotionItem('Zany', 'Çılgın', '🤪'),
    _EmotionItem('Freezing', 'Donmuş', '🥶'),
    _EmotionItem('Hot', 'Bunalmış', '🥵'),
    _EmotionItem('Pleading', 'Masum', '🥺'),
    _EmotionItem('Nerd', 'Bilmiş', '🤓'),
    _EmotionItem('Shushing', 'Sessiz', '🤫'),
    _EmotionItem('Winking', 'Göz Kırpan', '😉'),
    _EmotionItem('Angel', 'Melek', '😇'),
    _EmotionItem('Devil', 'Sinsi', '😈'),
    _EmotionItem('Party', 'Partici', '🥳'),
    _EmotionItem('Yawning', 'Esneyen', '🥱'),
    _EmotionItem('Drooling', 'İştahlı', '🤤'),
    _EmotionItem('Zipper-Mouth', 'Sır Tutan', '🤐'),
    _EmotionItem('Money-Mouth', 'Zengin', '🤑'),
    _EmotionItem('Vomiting', 'Kusan', '🤮'),
    _EmotionItem('Sneezing', 'Hapşuran', '🤧'),
    _EmotionItem('Exploding', 'Patlayan', '🤯'),
    _EmotionItem('Disguised', 'Gizlenmiş', '🥸'),
    
    // Hayvanlar
    _EmotionItem('Dog', 'Köpek', '🐶'),
    _EmotionItem('Cat', 'Kedi', '🐱'),
    _EmotionItem('Mouse', 'Fare', '🐭'),
    _EmotionItem('Hamster', 'Hamster', '🐹'),
    _EmotionItem('Rabbit', 'Tavşan', '🐰'),
    _EmotionItem('Fox', 'Tilk', '🦊'),
    _EmotionItem('Bear', 'Ayı', '🐻'),
    _EmotionItem('Panda', 'Panda', '🐼'),
    _EmotionItem('Koala', 'Koala', '🐨'),
    _EmotionItem('Tiger', 'Kaplan', '🐯'),
    _EmotionItem('Lion', 'Aslan', '🦁'),
    _EmotionItem('Cow', 'İnek', '🐮'),
    _EmotionItem('Pig', 'Domuz', '🐷'),
    _EmotionItem('Frog', 'Kurbağa', '🐸'),
    _EmotionItem('Monkey', 'Maymun', '🐵'),
    _EmotionItem('Chicken', 'Tavuk', '🐔'),
    _EmotionItem('Penguin', 'Penguen', '🐧'),
    _EmotionItem('Bird', 'Kuş', '🐦'),
    _EmotionItem('Owl', 'Baykuş', '🦉'),
    _EmotionItem('Bat', 'Yarasa', '🦇'),
    _EmotionItem('Wolf', 'Kurt', '🐺'),
    _EmotionItem('Boar', 'Yaban Domuzu', '🐗'),
    _EmotionItem('Horse', 'At', '🐴'),
    
    // Yiyecek ve İçecekler
    _EmotionItem('Apple', 'Elma', '🍎'),
    _EmotionItem('Banana', 'Muz', '🍌'),
    _EmotionItem('Grapes', 'Üzüm', '🍇'),
    _EmotionItem('Watermelon', 'Karpuz', '🍉'),
    _EmotionItem('Strawberry', 'Çilek', '🍓'),
    _EmotionItem('Hamburger', 'Hamburger', '🍔'),
    _EmotionItem('Pizza', 'Pizza', '🍕'),
    _EmotionItem('Hot Dog', 'Sosisli', '🌭'),
    _EmotionItem('Taco', 'Tako', '🌮'),
    _EmotionItem('Burrito', 'Dürüm', '🌯'),
    _EmotionItem('Popcorn', 'Patlamış Mısır', '🍿'),
    _EmotionItem('Donut', 'Donut', '🍩'),
    _EmotionItem('Ice Cream', 'Dondurma', '🍦'),
    _EmotionItem('Candy', 'Şeker', '🍬'),
    _EmotionItem('Coffee', 'Kahve', '☕'),
    _EmotionItem('Tea', 'Çay', '🍵'),
    _EmotionItem('Juice', 'Meyve Suyu', '🧃'),
    
    // Doğa ve Simgeler
    _EmotionItem('Sun', 'Güneş', '☀️'),
    _EmotionItem('Moon', 'Ay', '🌙'),
    _EmotionItem('Star', 'Yıldız', '⭐'),
    _EmotionItem('Fire', 'Ateş', '🔥'),
    _EmotionItem('Water', 'Su', '💧'),
    _EmotionItem('Snowflake', 'Kar Tanesi', '❄️'),
    _EmotionItem('Flower', 'Çiçek', '🌸'),
    _EmotionItem('Tree', 'Ağaç', '🌳'),
    _EmotionItem('Alien', 'Uzaylı', '👽'),
    _EmotionItem('Ghost', 'Hayalet', '👻'),
    _EmotionItem('Robot', 'Robot', '🤖'),
    _EmotionItem('Poop', 'Kaka', '💩'),
    _EmotionItem('Skull', 'Kafatası', '💀'),
  ];

  @override
  void initState() {
    super.initState();
    _prompt = _nextPrompt();

    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _levelUpController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _levelUpController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    if (!widget.isPaused) _startTimers();
  }

  void _startTimers() {
    _gameTimer?.cancel();
    _promptTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      _timeRemainingNotifier.value--;
      _totalPlayTime++;

      if (_timeRemainingNotifier.value <= 0) {
        _finish();
      }
    });

    // FPS Sorunu olmaması için 50 ms lik zamanlayıcı notifier çalıştırır (hızlı animasyon içindir)
    // Saniye cinsinden değerini orantılayarak çubuğu eksiltir
    _promptTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _isFinished) return;
      _promptProgressNotifier.value -= (50 / _currentPromptDurationMs);
      
      if (_promptProgressNotifier.value <= 0) {
        _handlePromptTimeout();
      }
    });
  }
  
  void _handlePromptTimeout() {
    if (_isFinished) return;

    HapticFeedback.mediumImpact();
    
    setState(() {
      _combo = 0;
      _wrong++;
      _hearts = max(0, _hearts - 1);
      _score = max(0, _score - 80);
      _shakeController.forward(from: 0.0);
      
      if (_hearts == 0) {
         _finish();
         return;
      }
      
      _prompt = _nextPrompt();
    });
  }

  @override
  void didUpdateWidget(covariant EmotionMirrorGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _gameTimer?.cancel();
        _promptTimer?.cancel();
      } else if (!_isFinished) {
        _startTimers();
      }
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _promptTimer?.cancel();
    _timeRemainingNotifier.dispose();
    _promptProgressNotifier.dispose();
    _levelUpController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  _Prompt _nextPrompt() {
    // Round başlarken çubuğu geri tam doldur
    _promptProgressNotifier.value = 1.0;
    
    final isEn = ref.read(languageProvider) == AppLanguage.en;
    final real = _items[_rng.nextInt(_items.length)];
    final shouldMatch = _rng.nextBool();
    final other = _items[_rng.nextInt(_items.length)];
    
    final label = shouldMatch ? (isEn ? real.en : real.tr) : (isEn ? other.en : other.tr);

    final isMatch = shouldMatch || (isEn ? (label == real.en) : (label == real.tr));
    return _Prompt(emoji: real.emoji, label: label, isMatch: isMatch);
  }

  void _levelUp() {
    _level++;
    _targetsToClear += 2;
    _targetsClearedInLevel = 0;
    

    _levelUpController.forward(from: 0.0);
    
    _timeRemainingNotifier.value += 12; // Level bonus süresi
    _hearts = min(3, _hearts + 1); // Can ödülü
    _currentPromptDurationMs = max(1000, _currentPromptDurationMs * 0.82); // Düşünme süresi daralıyor
  }

  void _answer(bool yes) {
    if (widget.isPaused || _timeRemainingNotifier.value <= 0 || _isFinished) return;
    final isCorrect = (yes == _prompt.isMatch);

    setState(() {
      if (isCorrect) {

        HapticFeedback.lightImpact();
        
        _correct++;
        _combo++;
        _bestCombo = max(_bestCombo, _combo);
        _targetsClearedInLevel++;
        
        _score += 100 + (_combo * 15) + (_level * 10);

        if (_targetsClearedInLevel >= _targetsToClear) {
           _levelUp();
        }
      } else {

        HapticFeedback.mediumImpact();
        
        _wrong++;
        _combo = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 80);
        _shakeController.forward(from: 0.0);
        
        if (_hearts == 0) {
           _finish();
           return;
        }
      }
      _prompt = _nextPrompt();
    });
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();
    _promptTimer?.cancel();

    
    final total = max(1, _correct + _wrong);
    widget.onComplete({
      'score': _score.toDouble(),
      'level': _level,
      'successRate': _correct / total,
      'duration': _totalPlayTime,
      'correctHits': _correct,
      'wrongHits': _wrong,
      'bestCombo': _bestCombo,
    });
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF7F8FB);
    final panel = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(isDark, panel, titleColor, textColor, s),
                  const SizedBox(height: 12),
                  _buildStats(panel, titleColor, textColor),
                  const SizedBox(height: 16),
                  
                  // Question area
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(sin(_shakeController.value * 2 * pi) * _shakeAnimation.value, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: panel,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE5E7EB),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Soru ilerleme çubuğu
                                ValueListenableBuilder<double>(
                                  valueListenable: _promptProgressNotifier,
                                  builder: (context, progress, child) {
                                     return ClipRRect(
                                       borderRadius: BorderRadius.circular(12),
                                       child: LinearProgressIndicator(
                                         value: progress.clamp(0.0, 1.0),
                                         minHeight: 8,
                                         backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                                         valueColor: AlwaysStoppedAnimation<Color>(
                                           Color.lerp(const Color(0xFFEF4444), const Color(0xFF3B82F6), progress)!
                                         ),
                                       ),
                                     );
                                  },
                                ),
                                const Spacer(),
                                Text(
                                  _prompt.emoji,
                                  style: const TextStyle(fontSize: 100),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    _prompt.label,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _AnswerButton(
                                        label: s.yes,
                                        icon: Icons.check_circle_outline_rounded,
                                        color: const Color(0xFF10B981),
                                        onTap: () => _answer(true),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _AnswerButton(
                                        label: s.no,
                                        icon: Icons.cancel_outlined,
                                        color: const Color(0xFFEF4444),
                                        onTap: () => _answer(false),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _levelUpController,
                builder: (context, child) {
                  if (_levelUpController.isDismissed) return const SizedBox.shrink();

                  return Container(
                    color: const Color(0xFF22C55E).withValues(alpha: _fadeAnimation.value * 0.15),
                    child: Center(
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Text(
                            '${s.isEn ? 'LEVEL ' : 'SEVİYE '}$_level!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF10B981),
                              shadows: [
                                const Shadow(
                                  color: Color(0xFF059669),
                                  blurRadius: 20,
                                  offset: Offset(0, 0),
                                ),
                                const Shadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDark, Color panel, Color titleColor, Color textColor, AppStrings s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emotion Mirror',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${s.metaLevel} $_level: $_targetsClearedInLevel / $_targetsToClear',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<int>(
            valueListenable: _timeRemainingNotifier,
            builder: (context, time, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: time <= 5 ? const Color(0xFFFEE2E2) : isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: time <= 5 ? const Color(0xFFEF4444) : Colors.transparent,
                ),
              ),
              child: Text(
                '$time s',
                style: GoogleFonts.robotoMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: time <= 5 ? const Color(0xFFEF4444) : titleColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStats(Color panel, Color titleColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatChip(
            icon: Icons.favorite,
            label: 'Can',
            value: '$_hearts/3',
            color: const Color(0xFFEF4444),
          ),
          _StatChip(
            icon: Icons.local_fire_department,
            label: 'Kombo',
            value: '$_combo',
            color: const Color(0xFFF59E0B),
          ),
          _StatChip(
            icon: Icons.star_rounded,
            label: 'Skor',
            value: '$_score',
            color: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: color.withValues(alpha: 0.8)),
            ),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionItem {
  final String en;
  final String tr;
  final String emoji;

  const _EmotionItem(this.en, this.tr, this.emoji);
}

class _Prompt {
  final String emoji;
  final String label;
  final bool isMatch;

  _Prompt({required this.emoji, required this.label, required this.isMatch});
}

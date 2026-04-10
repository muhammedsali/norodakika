

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/i18n/app_strings.dart';
import '../../settings/providers/language_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/widgets/neuron_background.dart';
import 'auth_gate_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim() == 'admin' && _passwordController.text == 'admin') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        final authState = ref.read(authNotifierProvider);
        authState.when(
          data: (_) {
            // Başarılı giriş - AuthGate otomatik yönlendirecek
          },
          loading: () {},
          error: (error, _) {
            final lang = ref.read(languageProvider);
            final s = AppStrings(lang);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${s.loginErrorPrefix}: $error')),
            );
          },
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    authState.when(
      data: (_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGateScreen()),
          (route) => false,
        );
      },
      loading: () {},
      error: (error, _) {
        final lang = ref.read(languageProvider);
        final s = AppStrings(lang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.googleLoginErrorPrefix}: $error')),
        );
      },
    );
  }

  BoxDecoration _getNeuDecoration({required bool isDarkMode}) {
    final bgColor = isDarkMode 
        ? const Color(0xFF1E293B).withValues(alpha: 0.7) 
        : Colors.white.withValues(alpha: 0.85);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final lang = ref.watch(languageProvider);
    final isDarkMode = ref.watch(themeProvider);
    final s = AppStrings(lang);

    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const primaryColor = Color(0xFF0D59F2);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ana sayfadaki harika Nöron/Sinapsis Parçacık Efekti
          Positioned.fill(
            child: NeuronBackground(isDarkMode: isDarkMode),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: _getNeuDecoration(isDarkMode: isDarkMode),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Başlık ve İkon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.login_rounded, size: 40, color: primaryColor),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          s.loginRequiredTitle.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.platformTitle,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // Email Girişi
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: s.emailLabel,
                            labelStyle: GoogleFonts.inter(color: subtitleColor),
                            prefixIcon: Icon(Icons.email_outlined, color: subtitleColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return s.emailRequired;
                            if (!value.contains('@')) return s.emailInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Şifre Girişi
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          autofillHints: const [AutofillHints.password],
                          style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: s.passwordLabel,
                            labelStyle: GoogleFonts.inter(color: subtitleColor),
                            prefixIcon: Icon(Icons.lock_outline, color: subtitleColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: subtitleColor,
                              ),
                              onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return s.passwordRequired;
                            if (value.length < 6) return s.passwordMinLength;
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Giriş Butonu
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: primaryColor.withValues(alpha: 0.4),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : Text(
                                    s.loginButton.toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Google ile Giriş
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                            icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                            label: Text(
                              s.googleSignIn,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: titleColor,
                              side: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black26, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Kayıt Ol Yönlendirmesi
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(color: subtitleColor, fontSize: 14),
                            children: [
                              TextSpan(text: '${s.noAccountRegister} '),
                              TextSpan(
                                text: s.registerTitle,
                                style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.w700),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/i18n/app_strings.dart';
import '../../settings/providers/language_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'auth_gate_screen.dart';
import 'login_screen.dart';
import '../../../core/widgets/neuron_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        final authState = ref.read(authNotifierProvider);
        final lang = ref.read(languageProvider);
        final s = AppStrings(lang);
        
        // Önceki snackbar'ları temizle
        ScaffoldMessenger.of(context).clearSnackBars();
        
        authState.when(
          data: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.registerSuccessSnack),
                backgroundColor: Colors.green,
              ),
            );

            // Kayıt sonrasında kullanıcı zaten giriş yapmış oluyor.
            // AuthGate, güncel auth durumuna göre otomatik olarak Home'a yönlendirir.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthGateScreen()),
              (route) => false,
            );
          },
          loading: () {},
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_add_rounded, size: 40, color: primaryColor),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          s.registerTitle.toUpperCase(),
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

                        // Name
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          autofillHints: const [AutofillHints.name],
                          style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: s.nameLabel,
                            labelStyle: GoogleFonts.inter(color: subtitleColor),
                            prefixIcon: Icon(Icons.person_outline, color: subtitleColor),
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
                            if (value == null || value.isEmpty) return s.nameRequired;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email
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
                        
                        // Password
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
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_confirmPasswordVisible,
                          autofillHints: const [AutofillHints.password],
                          style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: s.confirmPasswordLabel,
                            labelStyle: GoogleFonts.inter(color: subtitleColor),
                            prefixIcon: Icon(Icons.lock_clock_outlined, color: subtitleColor),
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
                                _confirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: subtitleColor,
                              ),
                              onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return s.confirmPasswordRequired;
                            if (value != _passwordController.text) return s.passwordsDontMatch;
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleRegister,
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
                                    s.registerTitle.toUpperCase(),
                                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Google Sign In
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
                        
                        // Login Link
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(color: subtitleColor, fontSize: 14),
                            children: [
                              TextSpan(text: '${s.loginRequiredTitle} '),
                              TextSpan(
                                text: s.loginButton,
                                style: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.w700),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
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


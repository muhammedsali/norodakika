import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/i18n/app_strings.dart';
import '../../settings/providers/language_provider.dart';
import '../../shared/widgets/radial_gradient_container.dart';
import '../providers/auth_provider.dart';
import 'auth_gate_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).register(
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


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);

    return Scaffold(
      backgroundColor: const Color(0xFF221B26),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/Objects_(2).png',
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.35,
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(-1, 1),
                      child: Transform.translate(
                        offset: const Offset(-200, 0),
                        child: const RadialGradientContainer(
                          width: 400,
                          height: 400,
                          startColor: Color(0x97D25A63),
                          endColor: Color(0x00FFFFFF),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(-1, 1),
                      child: Transform.translate(
                        offset: const Offset(200, 0),
                        child: const RadialGradientContainer(
                          width: 400,
                          height: 400,
                          startColor: Color(0x7DB379DF),
                          endColor: Color(0x00FFFFFF),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(1, -1),
                      child: Transform.translate(
                        offset: const Offset(200, -51),
                        child: const RadialGradientContainer(
                          width: 400,
                          height: 400,
                          startColor: Color(0x43B379DF),
                          endColor: Color(0x00FFFFFF),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(1, 0),
                      child: Image.asset(
                        'assets/images/Illustration.png',
                        width: MediaQuery.sizeOf(context).width * 0.7,
                        height: double.infinity,
                        fit: BoxFit.fitWidth,
                        alignment: const Alignment(1, -1),
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    const SizedBox(height: 32),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.sizeOf(context).height * 0.8,
                              decoration: const BoxDecoration(
                                color: Color(0x7550323F),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(60),
                                  topRight: Radius.circular(60),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 570),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      s.registerTitle,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      s.platformTitle,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [AutofillHints.email],
                                      decoration: InputDecoration(
                                        labelText: s.emailLabel,
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.white70,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFABA4AD),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFF9C3FE4),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF544A56),
                                      ),
                                      style: GoogleFonts.poppins(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return s.emailRequired;
                                        }
                                        if (!value.contains('@')) {
                                          return s.emailInvalid;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      autofillHints: const [AutofillHints.password],
                                      obscureText: !_passwordVisible,
                                      decoration: InputDecoration(
                                        labelText: s.passwordLabel,
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.white70,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFABA4AD),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFF9C3FE4),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF544A56),
                                        suffixIcon: InkWell(
                                          onTap: () => setState(
                                            () => _passwordVisible = !_passwordVisible,
                                          ),
                                          child: Icon(
                                            _passwordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      style: GoogleFonts.poppins(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return s.passwordRequired;
                                        }
                                        if (value.length < 6) {
                                          return s.passwordMinLength;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      autofillHints: const [AutofillHints.password],
                                      obscureText: !_confirmPasswordVisible,
                                      decoration: InputDecoration(
                                        labelText: s.confirmPasswordLabel,
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.white70,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFFABA4AD),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Color(0xFF9C3FE4),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF544A56),
                                        suffixIcon: InkWell(
                                          onTap: () => setState(
                                            () => _confirmPasswordVisible =
                                                !_confirmPasswordVisible,
                                          ),
                                          child: Icon(
                                            _confirmPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      style: GoogleFonts.poppins(color: Colors.white),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return s.confirmPasswordRequired;
                                        }
                                        if (value != _passwordController.text) {
                                          return s.passwordsDontMatch;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF9C3FE4),
                                              Color(0xFFC65647),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: authState.isLoading
                                              ? null
                                              : _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: authState.isLoading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  s.registerTitle,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
                                      child: Text(
                                        s.googleSignIn,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: OutlinedButton(
                                        onPressed: authState.isLoading
                                            ? null
                                            : _handleGoogleSignIn,
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: const Color(0xFF544A56),
                                          side: const BorderSide(
                                            color: Color(0xFFABA4AD),
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const FaIcon(
                                          FontAwesomeIcons.google,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(text: '${s.loginRequiredTitle}  '),
                                          TextSpan(
                                            text: s.loginButton,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFB379DF),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen(),
                                                  ),
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


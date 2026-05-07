import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';
import '../theme/bk_theme.dart';
import '../models/usuarios_model.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isRegister) {
        final cred = await FirebaseService.register(
            _emailCtrl.text.trim(), _passwordCtrl.text.trim());
        await FirebaseService.guardarUsuario(UsuarioBK(
          uid: cred.user!.uid,
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          rol: RolBK.empleado,
        ));
      } else {
        await FirebaseService.signIn(
            _emailCtrl.text.trim(), _passwordCtrl.text.trim());
      }
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: BKColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0A00),
                  Color(0xFF3D0900),
                  Color(0xFF1A0A00),
                ],
              ),
            ),
          ),
          // ── Decorative circles ──
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BKColors.red.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BKColors.yellow.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ──
                    _BKLogo()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.7, 0.7)),
                    const SizedBox(height: 12),

                    Text(
                      'BK ACCESS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: BKColors.yellow,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: BKColors.red.withOpacity(0.8),
                            blurRadius: 12,
                          )
                        ],
                      ),
                    )
                        .animate(delay: 200.ms)
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),

                    Text(
                      'Panel de Administración',
                      style: TextStyle(
                        color: BKColors.textSecondary,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(),

                    const SizedBox(height: 40),

                    // ── Form Card ──
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: BKColors.cardBg.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: BKColors.brown.withOpacity(0.5), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: BKColors.red.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              _isRegister ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
                              style: const TextStyle(
                                color: BKColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (_isRegister) ...[
                              TextFormField(
                                controller: _nombreCtrl,
                                style: const TextStyle(
                                    color: BKColors.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Nombre completo',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) =>
                                    (v == null || v.isEmpty) ? 'Requerido' : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            TextFormField(
                              controller: _emailCtrl,
                              style:
                                  const TextStyle(color: BKColors.textPrimary),
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) =>
                                  (v == null || !v.contains('@'))
                                      ? 'Email inválido'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              style:
                                  const TextStyle(color: BKColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  color: BKColors.yellow,
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Mínimo 6 caracteres'
                                  : null,
                            ),
                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        _isRegister
                                            ? '🍔  REGISTRARME'
                                            : '🔥  ENTRAR AL SISTEMA',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextButton(
                              onPressed: () =>
                                  setState(() => _isRegister = !_isRegister),
                              child: Text(
                                _isRegister
                                    ? '¿Ya tienes cuenta? Iniciar sesión'
                                    : '¿No tienes cuenta? Registrarse',
                                style: const TextStyle(
                                    color: BKColors.yellow, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BKLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFD700), Color(0xFFF5A623)],
        ),
        boxShadow: [
          BoxShadow(
            color: BKColors.yellow.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: BKColors.red.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'BK',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: BKColors.red,
            letterSpacing: -2,
          ),
        ),
      ),
    );
  }
}

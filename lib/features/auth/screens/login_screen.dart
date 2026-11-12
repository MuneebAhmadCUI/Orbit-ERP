import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    // UI prototype only: replace with backend authentication before production.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(24)),
                      child: const Icon(Icons.dashboard_customize_rounded, color: AppColors.primary, size: 34),
                    ),
                    const SizedBox(height: 25),
                    const Text('Welcome back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.dark)),
                    const SizedBox(height: 8),
                    const Text('Sign in to manage your business in one place.', style: TextStyle(fontSize: 14, color: AppColors.muted)),
                    const SizedBox(height: 34),
                    const Text('Work email', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.dark)),
                    const SizedBox(height: 9),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'you@company.com', prefixIcon: Icon(Icons.mail_outline_rounded)),
                      validator: (value) {
                        final email = (value ?? '').trim();
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.dark)),
                    const SizedBox(height: 9),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidden,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _hidden = !_hidden),
                          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) => (value ?? '').length < 6 ? 'Password must be at least 6 characters' : null,
                      onFieldSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset will be available after backend integration.'))),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _signIn,
                        child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text('Prototype: any valid email + 6-character password', style: TextStyle(fontSize: 12, color: AppColors.muted), textAlign: TextAlign.center)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  final auth = context.read<AuthProvider>();

  final error = await auth.login(
    email: _emailCtrl.text.trim(),
    password: _passCtrl.text,
  );

  if (!mounted) return;

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  } else {
    // ✅ NOW token is saved → safe to call API
    await context.read<TaskProvider>().loadTasks();

    context.go('/dashboard');
  }
}

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),
              Container(width: 60, height: 60,
                decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.school, color: Colors.white, size: 32)),
              const SizedBox(height: 24),
              Text('Welcome back!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Sign in to Student Planner Pro', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 40),
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) { if (v == null || v.isEmpty) return 'Enter your email'; if (!v.contains('@')) return 'Enter a valid email'; return null; }),
              const SizedBox(height: 16),
              TextFormField(controller: _passCtrl, obscureText: _obscure,
                decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))),
                validator: (v) { if (v == null || v.isEmpty) return 'Enter your password'; if (v.length < 6) return 'Minimum 6 characters'; return null; }),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _login,
                child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Sign In'),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ", style: theme.textTheme.bodyMedium),
                TextButton(onPressed: () => context.go('/register'), child: const Text('Sign Up')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

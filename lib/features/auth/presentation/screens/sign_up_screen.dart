import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_providers.dart';
import '../widgets/auth_shell.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authActionControllerProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            context.go('/dashboard');
          });
        },
        error: (error, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error.toString())));
          });
        },
      );
    });

    final actionState = ref.watch(authActionControllerProvider);

    return AuthShell(
      title: 'Create your FinSense',
      subtitle:
          'Build healthy money habits with a premium workspace for your personal finances.',
      footer: TextButton(
        onPressed: () => context.go('/sign-in'),
        child: const Text('Already have an account? Sign in'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              label: 'Full name',
              controller: _nameController,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => (value == null || !value.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              validator: (value) => (value == null || value.length < 6)
                  ? 'Minimum 6 characters'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: actionState.isLoading
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        ref
                            .read(authActionControllerProvider.notifier)
                            .signUp(
                              fullName: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                      },
                child: Text(
                  actionState.isLoading
                      ? 'Creating account...'
                      : 'Create account',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

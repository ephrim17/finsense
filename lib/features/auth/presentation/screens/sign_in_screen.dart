import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_providers.dart';
import '../widgets/auth_shell.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
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
      title: 'Welcome back',
      subtitle:
          'Track spending, manage budgets, and grow your savings with calm clarity.',
      footer: TextButton(
        onPressed: () => context.go('/sign-up'),
        child: const Text('Create an account'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
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
                            .signIn(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );
                      },
                child: Text(
                  actionState.isLoading ? 'Signing in...' : 'Sign in',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

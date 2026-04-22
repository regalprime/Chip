import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      context.read<AuthBloc>().add(SignUpWithEmailEvent(
            email: email,
            password: password,
          ));
    } else {
      context.read<AuthBloc>().add(SignInWithEmailEvent(
            email: email,
            password: password,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          DSErrorDialog.show(context, message: state.error);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App icon
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isSignUp ? 'Tạo tài khoản' : 'Đăng nhập',
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? 'Nhập email và mật khẩu để đăng ký'
                              : 'Chào mừng bạn quay lại',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!value.contains('@')) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isSignUp ? 'Đăng ký' : 'Đăng nhập'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle sign in / sign up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignUp
                                  ? 'Đã có tài khoản? '
                                  : 'Chưa có tài khoản? ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                });
                              },
                              child: Text(
                                _isSignUp ? 'Đăng nhập' : 'Đăng ký',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'hoặc',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google sign-in button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<AuthBloc>()
                                        .add(SignInWithGoogleEvent());
                                  },
                            icon: const Icon(Icons.g_mobiledata, size: 28),
                            label: const Text('Tiếp tục với Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

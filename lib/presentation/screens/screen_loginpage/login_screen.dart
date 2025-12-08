// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/core/colors.dart';

import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';
import 'package:zestyvibe/presentation/screens/screen_registerpage/register_screen.dart';
import 'package:zestyvibe/widgets/customnavigation.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Appcolors.kprimarycolor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) setState(() => _loading = true);
            else setState(() => _loading = false);

            if (state is AuthAuthenticated) {
            CustomNavigation.pushReplaceWithTransition(context, ScreenMainPage());
            }

            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Column(
            children: [
              TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () {
                        final email = _emailCtl.text.trim();
                        final pass = _passCtl.text;
                        context.read<AuthBloc>().add(AuthLoginRequested(email: email, password: pass));
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Appcolors.kprimarycolor),
                child: _loading ? const CircularProgressIndicator() : const Text('Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text("Don't have account? Register"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

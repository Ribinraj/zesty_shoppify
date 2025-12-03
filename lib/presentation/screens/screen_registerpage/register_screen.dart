// lib/presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';
import 'package:zestyvibe/widgets/customnavigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstCtl = TextEditingController();
  final _lastCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), backgroundColor: Appcolors.kprimarycolor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) setState(() => _loading = true);
            else setState(() => _loading = false);

            if (state is AuthAuthenticated) {
       CustomNavigation.pushReplaceWithTransition(context,ScreenMainPage());
            }

            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _firstCtl, decoration: const InputDecoration(labelText: 'First name')),
                const SizedBox(height: 12),
                TextField(controller: _lastCtl, decoration: const InputDecoration(labelText: 'Last name')),
                const SizedBox(height: 12),
                TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          final first = _firstCtl.text.trim();
                          final last = _lastCtl.text.trim();
                          final email = _emailCtl.text.trim();
                          final pass = _passCtl.text;
                          context.read<AuthBloc>().add(AuthRegisterRequested(
                                firstName: first,
                                lastName: last.isEmpty ? null : last,
                                email: email,
                                password: pass,
                              ));
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Appcolors.kprimarycolor),
                  child: _loading ? const CircularProgressIndicator() : const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

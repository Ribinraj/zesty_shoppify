import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/data/models/customer_model.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _acceptsMarketing = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    CustomerModel? customer;
    if (state is AuthAuthenticated) {
      customer = state.customer;
    }

    _firstNameController =
        TextEditingController(text: customer?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: customer?.lastName ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _acceptsMarketing = customer?.acceptsMarketing ?? false;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

void _onSave() {
  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();
  final phoneRaw = _phoneController.text.trim();

  if (firstName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('First name required')),
    );
    return;
  }

  // Simple example: if user enters 10-digit Indian number, prefix with +91
  String? phone;
  if (phoneRaw.isNotEmpty) {
    if (phoneRaw.startsWith('+')) {
      phone = phoneRaw; // user already entered full format
    } else if (phoneRaw.length == 10) {
      phone = '+91$phoneRaw'; // assume India
    } else {
      // show error for invalid local format
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
  }

  context.read<AuthBloc>().add(
        AuthUpdateProfileRequested(
          firstName: firstName,
          lastName: lastName.isEmpty ? null : lastName,
          phone: phone, // use formatted phone
          acceptsMarketing: _acceptsMarketing,
        ),
      );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Appcolors.kprimarycolor,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // success
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated')),
            );
            Navigator.of(context).pop(); // go back to profile screen
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return AbsorbPointer(
            absorbing: isLoading,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Accept marketing emails'),
                    value: _acceptsMarketing,
                    onChanged: (v) {
                      setState(() {
                        _acceptsMarketing = v;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolors.kprimarycolor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

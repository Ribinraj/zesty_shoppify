import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/data/models/customer_model.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();

    final state = context.read<AuthBloc>().state;
    CustomerModel? customer;
    if (state is AuthAuthenticated) {
      customer = state.customer;
    }

    final addr = customer?.defaultAddress ?? {};

_address1Controller =
    TextEditingController(text: addr['address1']?.toString() ?? '');

_address2Controller =
    TextEditingController(text: addr['address2']?.toString() ?? '');

_cityController =
    TextEditingController(text: addr['city']?.toString() ?? '');

_provinceController =
    TextEditingController(text: addr['province']?.toString() ?? '');

_zipController =
    TextEditingController(text: addr['zip']?.toString() ?? '');

_countryController =
    TextEditingController(text: addr['country']?.toString() ?? '');

  }

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _onSave() {
    final address1 = _address1Controller.text.trim();
    if (address1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address line 1 is required')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthUpdateAddressRequested(
            address1: address1,
            address2: _address2Controller.text.trim().isEmpty
                ? null
                : _address2Controller.text.trim(),
            city: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
            province: _provinceController.text.trim().isEmpty
                ? null
                : _provinceController.text.trim(),
            zip: _zipController.text.trim().isEmpty
                ? null
                : _zipController.text.trim(),
            country: _countryController.text.trim().isEmpty
                ? null
                : _countryController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit address'),
        backgroundColor: Appcolors.kprimarycolor,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address updated')),
            );
            Navigator.of(context).pop();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _address1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Address line 1 *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _address2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Address line 2',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'State / Province',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _zipController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP / Postal code',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                    ),
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

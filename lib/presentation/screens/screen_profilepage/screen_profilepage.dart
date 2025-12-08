// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/data/models/customer_model.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/presentation/screens/edit_adress_screen/edit_adressscreen.dart';
import 'package:zestyvibe/presentation/screens/screen_editprofile/screen_editprofile.dart';
import 'package:zestyvibe/presentation/screens/screen_loginpage/login_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(child: Text(value ?? '-', style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: const Text('My Account'),
  backgroundColor: Appcolors.kprimarycolor,
  actions: [
    IconButton(
      onPressed: () {
        context.read<AuthBloc>().add(AuthCheckRequested());
      },
      icon: const Icon(Icons.refresh),
    ),
    IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      },
      icon: const Icon(Icons.edit),
      tooltip: 'Edit profile',
    ),
  ],
),

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // if not logged in, go to login screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthAuthenticated) {
            final CustomerModel customer = state.customer;
            final displayName = (customer.firstName ?? '') + (customer.lastName != null && customer.lastName!.isNotEmpty ? ' ${customer.lastName}' : '');

            return SingleChildScrollView(
              child: Column(
                children: [
                  // header
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFD84315)]),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              (customer.firstName != null && customer.firstName!.isNotEmpty) ? customer.firstName![0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFD84315)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName.isNotEmpty ? displayName : 'Your name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(customer.email ?? '-', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text(customer.phone ?? '-', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // info card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow('Email', customer.email),
                            _buildInfoRow('Phone', customer.phone),
                            _buildInfoRow('Marketing', customer.acceptsMarketing == true ? 'Yes' : 'No'),
                            const Divider(),
                         Text('Default address', style: const TextStyle(fontWeight: FontWeight.w600)),
const SizedBox(height: 8),
if (customer.defaultAddress != null)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        customer.defaultAddress?['address1'] ?? '-',
        style: const TextStyle(color: Colors.black87),
      ),
      const SizedBox(height: 4),
      Text('${customer.defaultAddress?['city'] ?? ''} ${customer.defaultAddress?['zip'] ?? ''}'),
      const SizedBox(height: 4),
      Text(customer.defaultAddress?['country'] ?? ''),
    ],
  )
else
  const Text('No default address set'),

const SizedBox(height: 8),

// ⬇️ New button (Add / Edit address)
Align(
  alignment: Alignment.centerRight,
  child: TextButton.icon(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EditAddressScreen()),
      );
    },
    icon: const Icon(Icons.edit_location_alt),
    label: Text(
      customer.defaultAddress == null ? 'Add address' : 'Edit address',
    ),
  ),
),

                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // dispatch logout
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolors.kprimarycolor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }

          // fallback
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Not logged in'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Login'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

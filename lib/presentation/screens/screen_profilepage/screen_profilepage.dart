// lib/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/data/models/customer_model.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/presentation/screens/edit_adress_screen/edit_adressscreen.dart';
import 'package:zestyvibe/presentation/screens/screen_editprofile/screen_editprofile.dart';
import 'package:zestyvibe/presentation/screens/screen_loginpage/login_screen.dart';

import 'package:zestyvibe/widgets/custom_snackbar.dart';
import 'package:zestyvibe/widgets/customnavigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtils.wp(25),
            child: TextStyles.medium(
              text: label,
              weight: FontWeight.w600,
              color: Appcolors.kgreyColor.withOpacity(0.8),
            ),
          ),
          SizedBox(width: ResponsiveUtils.wp(3)),
          Expanded(
            child: TextStyles.medium(
              text: value ?? '-',
              color: Appcolors.kblackcolor,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.kbackgroundcolor,
      // appBar: CustomAppBar(title: 'My Account'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
          if (state is AuthError) {
            CustomSnackbar.show(
              context,
              message: state.message,
              type: SnackbarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Appcolors.kprimarycolor),
            );
          }

          if (state is AuthAuthenticated) {
            final CustomerModel customer = state.customer;
            final displayName =
                (customer.firstName ?? '') +
                (customer.lastName != null && customer.lastName!.isNotEmpty
                    ? ' ${customer.lastName}'
                    : '');

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AuthBloc>().add(AuthCheckRequested());
                await Future.delayed(const Duration(seconds: 1));
              },
              color: Appcolors.kprimarycolor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Appcolors.kprimarycolor,
                            Appcolors.kprimarycolor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.hp(3),
                        horizontal: ResponsiveUtils.wp(5),
                      ),
                      child: Column(
                        children: [
                          ResponsiveSizedBox.height50,
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: ResponsiveUtils.wp(22),
                                height: ResponsiveUtils.wp(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Appcolors.kwhitecolor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Appcolors.kblackcolor.withOpacity(
                                        0.1,
                                      ),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    (customer.firstName != null &&
                                            customer.firstName!.isNotEmpty)
                                        ? customer.firstName![0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.sp(10),
                                      fontWeight: FontWeight.bold,
                                      color: Appcolors.kprimarycolor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.wp(4)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextStyles.subheadline(
                                      text: displayName.isNotEmpty
                                          ? displayName
                                          : 'Your name',
                                      color: Appcolors.kwhitecolor,
                                      weight: FontWeight.bold,
                                    ),
                                    SizedBox(height: ResponsiveUtils.hp(0.5)),
                                    TextStyles.medium(
                                      text: customer.email ?? '-',
                                      color: Appcolors.kwhitecolor.withOpacity(
                                        0.9,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveUtils.hp(0.3)),
                                    TextStyles.medium(
                                      text: customer.phone ?? '-',
                                      color: Appcolors.kwhitecolor.withOpacity(
                                        0.9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          ResponsiveSizedBox.height20,
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.hp(2)),

                    // Info Card
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.wp(4),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Appcolors.kwhitecolor,
                          borderRadius: BorderRadiusStyles.kradius15(),
                          boxShadow: [
                            BoxShadow(
                              color: Appcolors.kblackcolor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextStyles.subheadline(
                                    text: 'Account Information',
                                    color: Appcolors.kprimarycolor,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Appcolors.kprimarycolor
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadiusStyles.kradius10(),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        CustomNavigation.pushWithTransition(
                                          context,
                                          EditProfileScreen(),
                                        );
                                      },
                                      icon: Icon(
                                        customer.defaultAddress == null
                                            ? Icons.add_location_alt
                                            : Icons.edit_location_alt,
                                        color: Appcolors.kprimarycolor,
                                        size: ResponsiveUtils.sp(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveUtils.hp(2)),
                              _buildInfoRow('Email', customer.email),
                              _buildInfoRow('Phone', customer.phone),
                              _buildInfoRow(
                                'Marketing',
                                customer.acceptsMarketing == true
                                    ? 'Yes'
                                    : 'No',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.hp(2)),

                    // Address Card
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.wp(4),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Appcolors.kwhitecolor,
                          borderRadius: BorderRadiusStyles.kradius15(),
                          boxShadow: [
                            BoxShadow(
                              color: Appcolors.kblackcolor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextStyles.subheadline(
                                    text: 'Default Address',
                                    color: Appcolors.kprimarycolor,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Appcolors.kprimarycolor
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadiusStyles.kradius10(),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const EditAddressScreen(),
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        customer.defaultAddress == null
                                            ? Icons.add_location_alt
                                            : Icons.edit_location_alt,
                                        color: Appcolors.kprimarycolor,
                                        size: ResponsiveUtils.sp(5),
                                      ),
                                      tooltip: customer.defaultAddress == null
                                          ? 'Add address'
                                          : 'Edit address',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveUtils.hp(2)),
                              if (customer.defaultAddress != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Appcolors.kprimarycolor,
                                          size: ResponsiveUtils.sp(5),
                                        ),
                                        SizedBox(width: ResponsiveUtils.wp(2)),
                                        Expanded(
                                          child: TextStyles.medium(
                                            text:
                                                customer
                                                    .defaultAddress?['address1'] ??
                                                '-',
                                            color: Appcolors.kblackcolor,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: ResponsiveUtils.hp(1)),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: ResponsiveUtils.wp(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextStyles.medium(
                                            text:
                                                '${customer.defaultAddress?['city'] ?? ''} ${customer.defaultAddress?['zip'] ?? ''}',
                                            color: Appcolors.kgreyColor,
                                          ),
                                          SizedBox(
                                            height: ResponsiveUtils.hp(0.5),
                                          ),
                                          TextStyles.medium(
                                            text:
                                                customer
                                                    .defaultAddress?['country'] ??
                                                '',
                                            color: Appcolors.kgreyColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      color: Appcolors.kgreyColor,
                                      size: ResponsiveUtils.sp(5),
                                    ),
                                    SizedBox(width: ResponsiveUtils.wp(2)),
                                    TextStyles.medium(
                                      text: 'No default address set',
                                      color: Appcolors.kgreyColor,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.hp(3)),

                    // Logout Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.wp(4),
                      ),
                      child: Container(
                        height: ResponsiveUtils.hp(6.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusStyles.kradius15(),
                          boxShadow: [
                            BoxShadow(
                              color: Appcolors.kprimarycolor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                          icon: Icon(
                            Icons.logout,
                            size: ResponsiveUtils.sp(5),
                            color: Appcolors.kwhitecolor,
                          ),
                          label: TextStyles.body(
                            text: 'Logout',
                            color: Appcolors.kwhitecolor,
                            weight: FontWeight.bold,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolors.kprimarycolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusStyles.kradius15(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.hp(3)),
                  ],
                ),
              ),
            );
          }

          // Fallback - Not logged in
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: ResponsiveUtils.wp(20),
                  color: Appcolors.kgreyColor,
                ),
                SizedBox(height: ResponsiveUtils.hp(2)),
                TextStyles.subheadline(
                  text: 'Not logged in',
                  color: Appcolors.kgreyColor,
                ),
                SizedBox(height: ResponsiveUtils.hp(2)),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusStyles.kradius10(),
                    boxShadow: [
                      BoxShadow(
                        color: Appcolors.kprimarycolor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.kprimarycolor,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.wp(10),
                        vertical: ResponsiveUtils.hp(1.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusStyles.kradius10(),
                      ),
                    ),
                    child: TextStyles.body(
                      text: 'Login',
                      color: Appcolors.kwhitecolor,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_cubit_state.dart';
import '../widgets/create_family_form.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/join_family_form.dart';

class FamilySetupPage extends StatefulWidget {
  const FamilySetupPage({super.key});

  @override
  State<FamilySetupPage> createState() => _FamilySetupPageState();
}

class _FamilySetupPageState extends State<FamilySetupPage> {
  bool _isJoinFamily = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isJoinFamily ? 'Join a Family' : 'Create Your Family',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isJoinFamily
                          ? 'Enter the family ID to join an existing family'
                          : 'Create a new family to get started',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Toggle between create and join forms
                    _isJoinFamily
                        ? const JoinFamilyForm()
                        : const CreateFamilyForm(),

                    const SizedBox(height: 24),

                    // Toggle button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isJoinFamily
                              ? 'Need to create a family?'
                              : 'Have a family ID?',
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isJoinFamily = !_isJoinFamily;
                            });
                          },
                          child: Text(
                            _isJoinFamily ? 'Create Family' : 'Join Family',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              BlocBuilder<AuthCubit, AuthCubitState>(
                builder: (context, state) {
                  return SafeArea(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: Colors.red),
                      ),
                      onPressed: state is AuthDeleting
                          ? null
                          : () => DeleteAccountDialog.show(
                              context,
                              () => context.read<AuthCubit>().deleteAccount(),
                            ),
                      child: state is AuthDeleting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.red,
                              ),
                            )
                          : const Text(
                              'Delete Account',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

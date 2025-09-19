import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_cubit_state.dart';

class JoinFamilyForm extends StatefulWidget {
  const JoinFamilyForm({super.key});

  @override
  State<JoinFamilyForm> createState() => _JoinFamilyFormState();
}

class _JoinFamilyFormState extends State<JoinFamilyForm> {
  final _formKey = GlobalKey<FormState>();
  final _familyIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _familyIdController,
            decoration: InputDecoration(
              labelText: 'Family ID',
              hintText: 'Enter the family ID you want to join',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the family ID';
              }
              // Basic UUID format validation
              if (!RegExp(
                r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
              ).hasMatch(value.trim())) {
                return 'Please enter a valid family ID';
              }
              return null;
            },
          ),
          SizedBox(height: 24),

          BlocBuilder<AuthCubit, AuthCubitState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is AuthLoading ? null : _handleJoinFamily,
                  child: state is AuthLoading
                      ? CircularProgressIndicator()
                      : Text('Join Family'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleJoinFamily() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().joinExistingFamily(
        _familyIdController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _familyIdController.dispose();
    super.dispose();
  }
}

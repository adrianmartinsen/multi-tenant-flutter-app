import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_cubit_state.dart';

class CreateFamilyForm extends StatefulWidget {
  const CreateFamilyForm({super.key});

  @override
  State<CreateFamilyForm> createState() => _CreateFamilyFormState();
}

class _CreateFamilyFormState extends State<CreateFamilyForm> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _familyNameController,
            decoration: InputDecoration(
              labelText: 'Family Name',
              hintText: 'e.g., Johnson ',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your family name';
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
                  onPressed: state is AuthLoading ? null : _handleCreateFamily,
                  child: state is AuthLoading
                      ? CircularProgressIndicator()
                      : Text('Create Family'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleCreateFamily() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().createAndJoinFamily(
        _familyNameController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }
}

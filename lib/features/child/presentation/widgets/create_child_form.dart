import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../family/presentation/pages/family_dashboard_page.dart';
import '../cubit/child_cubit.dart';
import '../cubit/child_cubit_state.dart';

class CreateChildForm extends StatefulWidget {
  const CreateChildForm({super.key, required this.familyId});
  final String familyId;

  @override
  State<CreateChildForm> createState() => _CreateChildFormState();
}

class _CreateChildFormState extends State<CreateChildForm> {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _childAgeController = TextEditingController();
  final _initialBalance = TextEditingController();

  // ALLOWANCE FEATURE NOT YET IMPLEMENTED
  bool _allowanceEnabled = false;
  final _allowanceAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _childNameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter child\'s name',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _childAgeController,
            decoration: const InputDecoration(
              labelText: 'Age',
              hintText: 'Enter child\'s age',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final age = int.tryParse(value);
                if (age == null || age < 0) {
                  return 'Please enter a valid age';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _initialBalance,
            decoration: const InputDecoration(
              labelText: 'Initial Balance',
              hintText: 'Defaults to 0',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final balance = double.tryParse(value);
                if (balance == null) {
                  return 'Please enter a valid amount';
                }
              }

              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Allowance Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Allowance'),
            value: _allowanceEnabled,
            onChanged: (value) {
              setState(() {
                _allowanceEnabled = value;
              });
            },
          ),
          if (_allowanceEnabled) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _allowanceAmount,
              decoration: const InputDecoration(
                labelText: 'Allowance Amount',

                // TBD - question if we want a currency prefix...
                // prefixText: '\$',
                hintText: 'Recurring allowance amount',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (_allowanceEnabled) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 32),
          BlocBuilder<ChildCubit, ChildCubitState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state is ChildOperationInProgress
                          ? null
                          : _handleCreateChild,
                      child: state is ChildOperationInProgress
                          ? CircularProgressIndicator()
                          : Text('Create Child'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleCreateChild() {
    if (_formKey.currentState!.validate()) {
      context.read<ChildCubit>().createChild(
        name: _childNameController.text.trim(),
        familyId: widget.familyId,
      );
    }
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _childAgeController.dispose();
    _allowanceAmount.dispose();
    super.dispose();
  }
}

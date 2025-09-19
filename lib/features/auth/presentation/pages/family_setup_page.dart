import 'package:flutter/material.dart';

import '../widgets/create_family_form.dart';
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isJoinFamily ? 'Join a Family' : 'Create Your Family',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                _isJoinFamily
                    ? 'Enter the family ID to join an existing family'
                    : 'Create a new family to get started',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),

              // Toggle between create and join forms
              _isJoinFamily ? JoinFamilyForm() : CreateFamilyForm(),

              SizedBox(height: 24),

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
      ),
    );
  }
}

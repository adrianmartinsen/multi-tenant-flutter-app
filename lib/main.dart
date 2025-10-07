import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/data/supabase_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit_state.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/auth/presentation/pages/family_setup_page.dart';
import 'features/family/data/supabase_family_repository.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jmvzipazvpnaficvvzvy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImptdnppcGF6dnBuYWZpY3Z2enZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2Mzk0MDgsImV4cCI6MjA3MzIxNTQwOH0.6aDm92w_nTtRHOwp-XNcxv1GQq5-X5F_wULc9E_Xpno',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(
        authRepository: SupabaseAuthRepository(),
        familyRepository: SupabaseFamilyRepository(),
      ),
      child: MaterialApp(
        title: 'AllowMe - Family Chore and Allowance Tracker',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state is AuthError) {
          print(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return HomePage();
        } else if (state is AuthUserWithoutFamily) {
          return FamilySetupPage();
        } else {
          return AuthPage();
        }
      },
    );
  }
}

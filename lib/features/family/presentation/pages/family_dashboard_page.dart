import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../child/data/supabase_child_repository.dart';
import '../../data/supabase_family_repository.dart';
import '../cubit/family_dashboard_cubit.dart';
import 'family_dashboard_view.dart';

class FamilyDashboardPage extends StatelessWidget {
  const FamilyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FamilyDashboardCubit(
        familyRepository: SupabaseFamilyRepository(),
        childRepository: SupabaseChildRepository(),
      ),
      child: const FamilyDashboardView(),
    );
  }
}

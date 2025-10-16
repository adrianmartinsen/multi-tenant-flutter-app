import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/family_dashboard_cubit.dart';
import '../cubit/family_dashboard_cubit_state.dart';
import '../widgets/child_card.dart';

class FamilyDashboardView extends StatelessWidget {
  const FamilyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
      builder: (context, state) {
        if (state is FamilyDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FamilyDashboardError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is FamilyDashboardLoaded) {
          // You can use state.family and state.members here if needed
          // For example: Text(state.family.name)

          if (state.children.isEmpty) {
            return const Center(child: Text('No children found. Add one!'));
          }

          return ListView.builder(
            itemCount: state.children.length,
            itemBuilder: (context, index) {
              final child = state.children[index];
              return ChildCard(child: child);
            },
          );
        }
        // Initial state
        return const Center(child: Text('Welcome to the Family Dashboard!'));
      },
    );
  }
}

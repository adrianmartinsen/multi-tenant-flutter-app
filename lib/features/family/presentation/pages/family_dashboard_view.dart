import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/family_dashboard_cubit.dart';
import '../cubit/family_dashboard_cubit_state.dart';

class FamilyDashboardView extends StatelessWidget {
  const FamilyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Dashboard')),
      body: BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
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
                return ListTile(
                  leading: const Icon(Icons.child_care),
                  title: Text(child.name),
                  onTap: () {
                    // TODO: Navigate to child detail screen
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChildDetailScreen(childId: child.id)));
                  },
                );
              },
            );
          }
          // Initial state
          return const Center(child: Text('Welcome to the Family Dashboard!'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to a screen to create a new child.
          // This screen would use the ChildCubit we refactored earlier.
          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddChildScreen()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigate to create child screen...')),
          );
        },
        label: const Text('Add Child'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

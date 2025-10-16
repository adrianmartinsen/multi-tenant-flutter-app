import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit_state.dart';
import '../../../child/data/supabase_child_repository.dart';
import '../../../child/presentation/cubit/child_cubit.dart';
import '../../../child/presentation/cubit/child_cubit_state.dart';
import '../../../child/presentation/pages/add_child_page.dart';
import '../../data/supabase_family_repository.dart';
import '../cubit/family_dashboard_cubit.dart';
import 'family_dashboard_view.dart';

class FamilyDashboardPage extends StatelessWidget {
  const FamilyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FamilyDashboardCubit(
            familyRepository: SupabaseFamilyRepository(),
            childRepository: SupabaseChildRepository(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              ChildCubit(childRepository: SupabaseChildRepository()),
        ),
      ],
      child: BlocListener<ChildCubit, ChildCubitState>(
        listener: (context, state) {
          if (state is ChildOperationSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Child deleted.')));
            context.read<FamilyDashboardCubit>().getFamilyData();
          }
          if (state is ChildOperationFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Failed to delete child: ${state.message}'),
                ),
              );
          }
        },
        child: BlocBuilder<AuthCubit, AuthCubitState>(
          // AuthCubit is only necessary to provide the logout button...
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Family Dashboard'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthCubit>().signOut();
                    },
                  ),
                ],
              ),
              body: const FamilyDashboardView(),

              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddChildPage()),
                  );

                  if (result == true) {
                    if (context.mounted) {
                      context.read<FamilyDashboardCubit>().getFamilyData();
                    }
                  }
                },
                child: const Icon(Icons.person_add),
              ),
            );
          },
        ),
      ),
    );
  }
}

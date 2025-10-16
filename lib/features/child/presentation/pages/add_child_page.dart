import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit_state.dart';
import '../../data/supabase_child_repository.dart';
import '../cubit/child_cubit.dart';
import '../cubit/child_cubit_state.dart';
import '../widgets/create_child_form.dart';

class AddChildPage extends StatelessWidget {
  const AddChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthCubitState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocProvider(
            create: (context) =>
                ChildCubit(childRepository: SupabaseChildRepository()),
            child: BlocListener<ChildCubit, ChildCubitState>(
              listener: (context, state) {
                if (state is ChildOperationSuccess) {
                  Navigator.pop(context, true);
                }
              },
              child: Scaffold(
                appBar: AppBar(title: const Text("Create new child")),
                body: SafeArea(
                  child: Center(
                    child: CreateChildForm(familyId: state.family.id),
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

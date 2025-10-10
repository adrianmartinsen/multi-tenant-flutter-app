import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/user_model.dart';
import '../../../child/domain/child_model.dart';
import '../../../child/domain/child_repo.dart';
import '../../domain/family_repo.dart';
import 'family_dashboard_cubit_state.dart';

class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  final FamilyRepository _familyRepository;
  final ChildRepository _childRepository;

  FamilyDashboardCubit({
    required FamilyRepository familyRepository,
    required ChildRepository childRepository,
  }) : _familyRepository = familyRepository,
       _childRepository = childRepository,
       super(FamilyDashboardInitial()) {
    getFamilyData();
  }

  Future<void> getFamilyData() async {
    emit(FamilyDashboardLoading());
    try {
      final family = await _familyRepository.getCurrentFamily();

      if (family != null) {
        final [members, children] = await Future.wait([
          _familyRepository.getFamilyMembers(),
          _childRepository.getChildrenForFamily(family.id),
        ]);

        emit(
          FamilyDashboardLoaded(
            family: family,
            members: members as List<UserModel>,
            children: children as List<Child>,
          ),
        );
      } else {
        emit(
          const FamilyDashboardError('No family found for the current user.'),
        );
      }
    } catch (e) {
      emit(FamilyDashboardError(e.toString()));
    }
  }
}

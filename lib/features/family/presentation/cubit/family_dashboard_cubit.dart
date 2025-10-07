import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_tenant_app_v2/features/family/domain/family_repo.dart';
import 'package:multi_tenant_app_v2/features/family/presentation/cubit/family_dashboard_cubit_state.dart';

class FamilyDashboardCubit extends Cubit<FamilyDashboardState> {
  final FamilyRepository _familyRepository;

  FamilyDashboardCubit({required FamilyRepository familyRepository})
      : _familyRepository = familyRepository,
        super(FamilyDashboardInitial());

  Future<void> getFamilyData() async {
    emit(FamilyDashboardLoading());
    try {
      final family = await _familyRepository.getCurrentFamily();
      if (family != null) {
        final members = await _familyRepository.getFamilyMembers();
        emit(FamilyDashboardLoaded(family: family, members: members));
      } else {
        emit(const FamilyDashboardError('No family found for the current user.'));
      }
    } catch (e) {
      emit(FamilyDashboardError(e.toString()));
    }
  }
}


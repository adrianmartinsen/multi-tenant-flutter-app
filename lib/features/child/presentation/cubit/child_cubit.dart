import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/child_model.dart';
import '../../domain/child_repo.dart';
import 'child_cubit_state.dart';

class ChildCubit extends Cubit<ChildCubitState> {
  final ChildRepository _childRepository;

  ChildCubit({required ChildRepository childRepository})
    : _childRepository = childRepository,
      super(ChildInitial());

  /// Create a new child.
  /// Emits [ChildOperationInProgress], then [ChildOperationSuccess] or [ChildOperationFailure].
  Future<void> createChild(
      {required String name, required String familyId}) async {
    emit(ChildOperationInProgress());
    try {
      final createdChild = await _childRepository.createChild(
        name: name,
        familyId: familyId,
      );
      emit(
        ChildOperationSuccess(
          message: 'Child created successfully',
          child: createdChild,
        ),
      );
    } catch (e) {
      emit(ChildOperationFailure('Failed to create child: ${e.toString()}'));
    }
  }

  /// Update an existing child.
  /// Emits [ChildOperationInProgress], then [ChildOperationSuccess] or [ChildOperationFailure].
  Future<void> updateChild(Child child) async {
    emit(ChildOperationInProgress());
    try {
      final updatedChild = await _childRepository.updateChild(child);
      emit(
        ChildOperationSuccess(
          message: 'Child updated successfully',
          child: updatedChild,
        ),
      );
    } catch (e) {
      emit(ChildOperationFailure('Failed to update child: ${e.toString()}'));
    }
  }

  /// Delete a child by their ID.
  /// Emits [ChildOperationInProgress], then [ChildOperationSuccess] or [ChildOperationFailure].
  Future<void> deleteChild(String childId) async {
    emit(ChildOperationInProgress());
    try {
      await _childRepository.deleteChild(childId);
      emit(const ChildOperationSuccess(message: 'Child deleted successfully'));
    } catch (e) {
      emit(ChildOperationFailure('Failed to delete child: ${e.toString()}'));
    }
  }

  /// Reset to initial state. Useful after an operation is complete and the UI has reacted.
  void reset() {
    emit(ChildInitial());
  }
}

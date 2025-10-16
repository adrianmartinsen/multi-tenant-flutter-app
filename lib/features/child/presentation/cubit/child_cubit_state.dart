import 'package:equatable/equatable.dart';
import '../../domain/child_model.dart';

abstract class ChildCubitState extends Equatable {
  const ChildCubitState();

  @override
  List<Object?> get props => [];
}

/// Initial state, cubit has been created.
class ChildInitial extends ChildCubitState {}

/// State when an operation (creating, updating, deleting) is in progress.
class ChildOperationInProgress extends ChildCubitState {}

/// State when an operation has completed successfully.
class ChildOperationSuccess extends ChildCubitState {
  final String message;
  final Child?
  child; // The affected child, if applicable (e.g., on create/update)

  const ChildOperationSuccess({required this.message, this.child});

  ChildOperationSuccess copyWith({String? message, Child? child}) {
    return ChildOperationSuccess(
      message: message ?? this.message,
      child: child ?? this.child,
    );
  }

  @override
  List<Object?> get props => [message, child];
}

/// State when an operation has failed.
class ChildOperationFailure extends ChildCubitState {
  final String message;

  const ChildOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import '../../domain/child_model.dart';

abstract class ChildState extends Equatable {
  const ChildState();

  @override
  List<Object?> get props => [];
}

/// Initial state, cubit has been created.
class ChildInitial extends ChildState {}

/// State when an operation (creating, updating, deleting) is in progress.
class ChildOperationInProgress extends ChildState {}

/// State when an operation has completed successfully.
class ChildOperationSuccess extends ChildState {
  final String message;
  final Child? child; // The affected child, if applicable (e.g., on create/update)

  const ChildOperationSuccess({required this.message, this.child});

  @override
  List<Object?> get props => [message, child];
}

/// State when an operation has failed.
class ChildOperationFailure extends ChildState {
  final String message;

  const ChildOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
part of 'delete_data_bloc.dart';


abstract class DeleteDataEvent extends Equatable {
  const DeleteDataEvent();

  @override
  List<Object?> get props => [];
}

class DeleteDataRequested extends DeleteDataEvent{}
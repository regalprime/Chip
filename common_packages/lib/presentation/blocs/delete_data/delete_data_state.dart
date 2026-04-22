part of 'delete_data_bloc.dart';

class DeleteDataState extends Equatable {
  const DeleteDataState({this.isDeleted = false});

  final bool isDeleted;

  DeleteDataState copyWith({bool? isDeleted}){
    return DeleteDataState(
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [isDeleted];
}
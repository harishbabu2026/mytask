import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Value Events
abstract class ValueEvent extends Equatable {
  const ValueEvent();

  @override
  List<Object?> get props => [];
}

class ValueFetched extends ValueEvent {}

class ValueIncremented extends ValueEvent {}

// Value States
abstract class ValueState extends Equatable {
  const ValueState();

  @override
  List<Object?> get props => [];
}

class ValueInitial extends ValueState {}

class ValueLoadSuccess extends ValueState {
  final int value;

  const ValueLoadSuccess(this.value);

  @override
  List<Object?> get props => [value];
}

class ValueLoadFailure extends ValueState {
  final String message;

  const ValueLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Value BLoC
class ValueBloc extends Bloc<ValueEvent, ValueState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  ValueBloc(this.userId) : super(ValueInitial()) {
    on<ValueFetched>(_onValueFetched);
    on<ValueIncremented>(_onValueIncremented);
  }

  Future<void> _onValueFetched(ValueFetched event, Emitter<ValueState> emit) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        emit(ValueLoadSuccess(doc.data()?['value'] ?? 0));
      } else {
        emit(ValueLoadSuccess(0));
      }
    } catch (e) {
      emit(ValueLoadFailure('Failed to fetch value: ${e.toString()}'));
    }
  }

  Future<void> _onValueIncremented(ValueIncremented event, Emitter<ValueState> emit) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await docRef.get();
      final currentValue = doc.data()?['value'] ?? 0;
      await docRef.set({'value': currentValue + 1}, SetOptions(merge: true));
      emit(ValueLoadSuccess(currentValue + 1));
    } catch (e) {
      emit(ValueLoadFailure('Failed to increment value: ${e.toString()}'));
    }
  }
}

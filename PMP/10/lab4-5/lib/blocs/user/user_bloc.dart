import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../services/hive_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<InitializeUsers>(_onInitializeUsers);
    on<SelectUser>(_onSelectUser);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onInitializeUsers(
      InitializeUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      var users = HiveService.getUsers();
      if (users.isEmpty) {
        await _addDefaultUsers();
        users = HiveService.getUsers();
      }
      emit(UserLoaded(users, null));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _addDefaultUsers() async {
    await HiveService.addUser(User(id: '1', name: 'Админ', role: 'admin'));
    await HiveService.addUser(User(id: '2', name: 'Менеджер', role: 'manager'));
    await HiveService.addUser(User(id: '3', name: 'Пользователь', role: 'user'));
  }

  void _onSelectUser(SelectUser event, Emitter<UserState> emit) {
    final currentState = state;
    if (currentState is UserLoaded) {
      emit(UserLoaded(currentState.users, event.user));
    }
  }

  void _onLogoutUser(LogoutUser event, Emitter<UserState> emit) {
    final currentState = state;
    if (currentState is UserLoaded) {
      emit(UserLoaded(currentState.users, null));
    }
  }
}
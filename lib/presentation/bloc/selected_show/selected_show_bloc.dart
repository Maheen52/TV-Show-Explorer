import 'package:flutter_bloc/flutter_bloc.dart';

import 'selected_show_event.dart';
import 'selected_show_state.dart';

class SelectedShowBloc extends Bloc<SelectedShowEvent, SelectedShowState> {
  SelectedShowBloc() : super(const SelectedShowState()) {
    on<ShowSelected>((event, emit) {
      emit(SelectedShowState(show: event.show));
    });
  }
}

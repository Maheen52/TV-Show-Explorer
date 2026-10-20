import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/show_model.dart';
import '../../bloc/selected_show/selected_show_bloc.dart';
import '../../bloc/selected_show/selected_show_event.dart';

// Called when a show is tapped. The Details, Episodes and Cast screens
// (screens 3, 4 and 5 of the design) all show the selected show.
void selectShow(BuildContext context, Show show) {
  context.read<SelectedShowBloc>().add(ShowSelected(show));

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Opened "${show.name}" in Details, Episodes and Cast'),
        duration: const Duration(seconds: 2),
      ),
    );
}

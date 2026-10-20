import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/bloc/selected_show/selected_show_bloc.dart';
import 'presentation/bloc/show_list/show_list_bloc.dart';
import 'presentation/bloc/show_list/show_list_event.dart';
import 'presentation/bloc/watchlist/watchlist_bloc.dart';
import 'presentation/bloc/watchlist/watchlist_event.dart';
import 'presentation/ui/app_colors.dart';
import 'presentation/ui/showcase_page.dart';

void main() {
  runApp(const MyApp());
}

// Lets the mouse drag lists (needed in Chrome to scroll the horizontal rows).
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider is above MaterialApp, so every phone window
    // on the page uses the same shows, watchlist and selected show.
    return MultiBlocProvider(
      providers: [
        // the first page of shows starts loading when the app starts
        BlocProvider(create: (_) => ShowListBloc()..add(const ShowsFetched())),
        // reads the saved watchlist from the browser / phone
        BlocProvider(
            create: (_) => WatchlistBloc()..add(const WatchlistStarted())),
        // the show shown in Details, Episodes and Cast
        BlocProvider(create: (_) => SelectedShowBloc()),
      ],
      child: MaterialApp(
        title: 'TV Show Explorer',
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        // dark theme like the design
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const ShowcasePage(),
      ),
    );
  }
}

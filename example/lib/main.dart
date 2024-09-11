import 'dart:io';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:flutter_quill/extension/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        ChangeSource,
        Document,
        QuillController,
        QuillEditor,
        QuillEditorConfigurations,
        QuillSimpleToolbar,
        QuillSimpleToolbarConfigurations,
        QuillToolbarCustomButtonOptions;
import 'package:flutter_quill/translations.dart' show FlutterQuillLocalizations;
import 'package:hydrated_bloc/hydrated_bloc.dart'
    show HydratedBloc, HydratedStorage;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'screens/home/widgets/home_screen.dart';
import 'screens/quill/quill_screen.dart';
import 'screens/quill/samples/quill_default_sample.dart';
import 'screens/quill/samples/quill_images_sample.dart';
import 'screens/quill/samples/quill_text_sample.dart';
import 'screens/quill/samples/quill_videos_sample.dart';
import 'screens/settings/cubit/settings_cubit.dart';
import 'screens/settings/widgets/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  FlutterQuillExtensions.useSuperClipboardPlugin();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final QuillController _controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          QuillSimpleToolbar(
            configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
                showDividers: false,
                showFontFamily: false,
                showFontSize: true,
                showBoldButton: true,
                showItalicButton: true,
                showSmallButton: false,
                showUnderLineButton: true,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showAlignmentButtons: false,
                showLeftAlignment: false,
                showCenterAlignment: false,
                showRightAlignment: false,
                showJustifyAlignment: false,
                showHeaderStyle: false,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: false,
                showIndent: false,
                showLink: false,
                showUndo: true,
                showRedo: true,
                showDirection: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: Icon(Icons.image),
                    onPressed: () {
                      _pickImage();
                    },
                  ),
                ]),
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                showCursor: true,
                // embedBuilders: kIsWeb
                //     ? FlutterQuillEmbeds.editorWebBuilders()
                //     : FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Method to pick an image from the device's gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Use ImagePicker to select an image from the gallery
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    // Check if an image was successfully picked
    if (pickedImage != null) {
      // Extract the file path of the picked image
      final String imagePath = pickedImage.path;
      // Create a File object from the picked image path
      final File file = File(imagePath);

      // Create a Delta representing the image to insert into the editor
      final Delta imageDelta = Delta()
        // Insert a new line before the image
        ..insert("\n")
        // Insert the image data as a map
        ..insert({
          // 'image' key represents the image data, in this case, the file path
          'image': file.path.toString(),
        })
        // Insert a new line after the image
        ..insert("\n");

      // Compose the image Delta into the Quill controller
      _controller.compose(
        imageDelta, // Delta representing the image
        // Set the text selection to the end of the inserted image
        TextSelection.collapsed(offset: imageDelta.length),
        // Specify that the change was made locally
        ChangeSource.local,
      );
    }
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => SettingsCubit(),
//         ),
//       ],
//       child: BlocBuilder<SettingsCubit, SettingsState>(
//         builder: (context, state) {
//           return MaterialApp(
//             title: 'Flutter Quill Demo',
//             theme: ThemeData(
//               useMaterial3: true,
//               visualDensity: VisualDensity.adaptivePlatformDensity,
//               colorScheme: ColorScheme.fromSeed(
//                 brightness: Brightness.light,
//                 seedColor: Colors.red,
//               ),
//             ),
//             darkTheme: ThemeData(
//               useMaterial3: true,
//               visualDensity: VisualDensity.adaptivePlatformDensity,
//               colorScheme: ColorScheme.fromSeed(
//                 brightness: Brightness.dark,
//                 seedColor: Colors.red,
//               ),
//             ),
//             themeMode: state.themeMode,
//             debugShowCheckedModeBanner: false,
//             localizationsDelegates: const [
//               GlobalMaterialLocalizations.delegate,
//               GlobalWidgetsLocalizations.delegate,
//               GlobalCupertinoLocalizations.delegate,
//               // Uncomment this line to use provide flutter quill localizations
//               // in your widgets app, otherwise the quill widgets will provide it
//               // internally:
//               // FlutterQuillLocalizations.delegate,
//             ],
//             supportedLocales: FlutterQuillLocalizations.supportedLocales,
//             routes: {
//               SettingsScreen.routeName: (context) => const SettingsScreen(),
//             },
//             onGenerateRoute: (settings) {
//               final name = settings.name;
//               if (name == HomeScreen.routeName) {
//                 return MaterialPageRoute(
//                   builder: (context) {
//                     return const HomeScreen();
//                   },
//                 );
//               }
//               if (name == QuillScreen.routeName) {
//                 return MaterialPageRoute(
//                   builder: (context) {
//                     final args = settings.arguments as QuillScreenArgs;
//                     return QuillScreen(
//                       args: args,
//                     );
//                   },
//                 );
//               }
//               return null;
//             },
//             onUnknownRoute: (settings) {
//               return MaterialPageRoute(
//                 builder: (context) => Scaffold(
//                   appBar: AppBar(
//                     title: const Text('Not found'),
//                   ),
//                   body: const Text('404'),
//                 ),
//               );
//             },
//             home: Builder(
//               builder: (context) {
//                 final screen = switch (state.defaultScreen) {
//                   DefaultScreen.home => const HomeScreen(),
//                   DefaultScreen.settings => const SettingsScreen(),
//                   DefaultScreen.imagesSample => QuillScreen(
//                       args: QuillScreenArgs(
//                         document: Document.fromJson(quillImagesSample),
//                       ),
//                     ),
//                   DefaultScreen.videosSample => QuillScreen(
//                       args: QuillScreenArgs(
//                         document: Document.fromJson(quillVideosSample),
//                       ),
//                     ),
//                   DefaultScreen.textSample => QuillScreen(
//                       args: QuillScreenArgs(
//                         document: Document.fromJson(quillTextSample),
//                       ),
//                     ),
//                   DefaultScreen.emptySample => QuillScreen(
//                       args: QuillScreenArgs(
//                         document: Document(),
//                       ),
//                     ),
//                   DefaultScreen.defaultSample => QuillScreen(
//                       args: QuillScreenArgs(
//                         document: Document.fromJson(quillDefaultSample),
//                       ),
//                     ),
//                 };
//                 return AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 330),
//                   transitionBuilder: (child, animation) {
//                     // This animation is from flutter.dev example
//                     const begin = Offset(0, 1);
//                     const end = Offset.zero;
//                     const curve = Curves.ease;

//                     final tween = Tween(
//                       begin: begin,
//                       end: end,
//                     ).chain(
//                       CurveTween(curve: curve),
//                     );

//                     return SlideTransition(
//                       position: animation.drive(tween),
//                       child: child,
//                     );
//                   },
//                   child: screen,
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

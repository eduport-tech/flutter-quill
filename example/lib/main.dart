import 'dart:io';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/extension/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        ChangeSource,
        QuillController,
        QuillEditor,
        QuillEditorConfigurations,
        QuillSimpleToolbar,
        QuillSimpleToolbarConfigurations,
        QuillToolbarCustomButtonOptions;
import 'package:hydrated_bloc/hydrated_bloc.dart'
    show HydratedBloc, HydratedStorage;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final QuillController _controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill Demo'),
      ),
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
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                ]),
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                showCursor: true,
                embedBuilders: kIsWeb
                    ? FlutterQuillEmbeds.editorWebBuilders()
                    : FlutterQuillEmbeds.editorBuilders(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Use ImagePicker to select an image from the gallery
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    // Check if an image was successfully picked
    if (pickedImage != null) {
      // Create a File object from the picked image path
      final file = File(pickedImage.path);

      // Get the current selection
      final index = _controller.selection.baseOffset;
      final length =
          _controller.selection.extentOffset - _controller.selection.baseOffset;

      // Create a Delta representing the image to insert into the editor with extra spacing
      final imageDelta = Delta()
        ..insert('\n')
        ..insert({
          'image': file.path.toString(),
        })
        ..insert('\n\n');

      // Delete selected text if there is a selection
      if (length > 0) {
        _controller.replaceText(index, length, '', null);
      }

      // Insert at current position
      _controller
        ..replaceText(
          index,
          0,
          imageDelta,
          null,
        )

        // Move cursor to end of inserted content
        ..updateSelection(
          TextSelection.collapsed(offset: index + imageDelta.length),
          ChangeSource.local,
        );
    }
  }
}

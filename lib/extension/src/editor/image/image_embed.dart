import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide OptionalSize;
import 'package:flutter_quill/translations.dart';

import '../../common/utils/element_utils/element_utils.dart';
import '../../editor_toolbar_shared/shared_configurations.dart';
import 'image_menu.dart';
import 'models/image_configurations.dart';
import 'widgets/image.dart';

class QuillEditorImageEmbedBuilder extends EmbedBuilder {
  QuillEditorImageEmbedBuilder({
    required this.configurations,
  });
  final QuillEditorImageEmbedConfigurations configurations;

  @override
  String get key => BlockEmbed.imageType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    // assert(!kIsWeb, 'Please provide image EmbedBuilder for Web');

    final imageSource = standardizeImageUrl(node.value.data);
    final ((imageSize), margin, alignment) = getElementAttributes(
      node,
      context,
    );

    final width = imageSize.width;
    final height = imageSize.height;

    // Check if this image is currently selected
    final isSelected = controller.selection.baseOffset <= node.documentOffset && 
                       node.documentOffset < controller.selection.extentOffset;

    final image = getImageWidgetByImageSource(
      context: context,
      imageSource,
      imageProviderBuilder: configurations.imageProviderBuilder,
      imageErrorWidgetBuilder: configurations.imageErrorWidgetBuilder,
      alignment: alignment,
      height: height,
      width: width,
      assetsPrefix: QuillSharedExtensionsConfigurations.get(context: context)
          .assetsPrefix,
    );

    final imageSaverService =
        QuillSharedExtensionsConfigurations.get(context: context)
            .imageSaverService;
            
    return GestureDetector(
      onTap: () {
        // Set selection to this image when tapped
        moveToCursorPosition(controller, node.documentOffset);
      },
      onLongPress: () {
        // Ensure cursor position is set to this image before showing menu
        moveToCursorPosition(controller, node.documentOffset);
        
        final onImageClicked = configurations.onImageClicked;
        if (onImageClicked != null) {
          onImageClicked(imageSource);
          return;
        }
        
        showDialog(
          context: context,
          builder: (_) => FlutterQuillLocalizationsWidget(
            child: ImageOptionsMenu(
              controller: controller,
              configurations: configurations,
              imageSource: imageSource,
              imageSize: imageSize,
              isReadOnly: readOnly,
              imageSaverService: imageSaverService,
              nodeOffset: node.documentOffset,
            ),
          ),
        );
      },
      child: Builder(
        builder: (context) {
          // Create a container with a highlight border if selected
          Widget imageWidget = image;
          
          // Add a colored border when the image is selected
          if (isSelected) {
            imageWidget = Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
              child: image,
            );
          }
          
          if (margin != null) {
            return Container(
              color: Colors.grey.shade200,
              child: Padding(
                padding: EdgeInsets.all(margin),
                child: imageWidget,
              ),
            );
          }
          return Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade200,
              child: imageWidget);
        },
      ),
    );
  }
}

void moveToCursorPosition(QuillController controller, int offset) {
  // Ensure the offset is within the bounds of the document
  final clampedOffset = offset.clamp(0, controller.document.length - 1);

  // Move the cursor to the specified position
  controller.updateSelection(
    TextSelection.collapsed(offset: clampedOffset),
    ChangeSource.local,
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:wenku8/utils/extensions/build_context.dart';

class ImageViewer extends StatefulWidget {
  final Widget child;

  const ImageViewer({super.key, required this.child});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final TransformationController _controller = TransformationController();
  bool isUiHidden = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: SizedBox.expand(
              child: InteractiveViewer(
                transformationController: _controller,
                onInteractionUpdate: (details) {
                  if (_controller.value.getMaxScaleOnAxis() == 1.0) {
                    if (isUiHidden) {
                      setState(() => isUiHidden = false);
                    }
                  } else {
                    if (!isUiHidden) {
                      setState(() => isUiHidden = true);
                    }
                  }
                },
                onInteractionEnd: (details) {
                  if (details.pointerCount == 0 && Velocity.zero == details.velocity) {
                    if (isUiHidden) {
                      setState(() => isUiHidden = false);
                    } else {
                      setState(() => isUiHidden = true);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.child,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isUiHidden ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Stack(children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton.filled(
                    icon: const Icon(Symbols.close_rounded),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(context.colors.onSurface),
                      backgroundColor: MaterialStateProperty.all(context.colors.surface.withOpacity(0.8)),
                    ),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: TextButton.icon(
                    icon: const Icon(Symbols.save_rounded),
                    label: const Text("儲存"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(context.colors.onSurface),
                      backgroundColor: MaterialStateProperty.all(context.colors.surface.withOpacity(0.8)),
                    ),
                    onPressed: () {},
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}

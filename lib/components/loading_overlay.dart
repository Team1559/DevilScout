import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  State<LoadingOverlay> createState() => LoadingOverlayState();

  static LoadingOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<LoadingOverlayState>()!;
  }
}

class LoadingOverlayState extends State<LoadingOverlay> {
  bool _loading = false;

  void show() {
    setState(() => _loading = true);
  }

  void hide() {
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Visibility(
          visible: _loading,
          child: const Stack(
            children: [
              Opacity(
                opacity: 0.5,
                child: ModalBarrier(
                  dismissible: false,
                  color: Colors.black,
                ),
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

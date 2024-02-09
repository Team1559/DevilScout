import 'package:flutter/material.dart';

abstract class HorizontalPageView<T> extends StatefulWidget {
  final List<T> pages;
  final String? lastPageButtonLabel;

  const HorizontalPageView({
    super.key,
    required this.pages,
    this.lastPageButtonLabel,
  });
}

abstract class HorizontalPageViewState<T, H extends HorizontalPageView<T>>
    extends State<H> {
  final PageController controller = PageController();

  int currentPage = 0;

  Widget buildPage(T page);

  void Function()? lastPageButtonAction() => null;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (page) => setState(() => currentPage = page),
              children: List.generate(widget.pages.length,
                  (index) => buildPage(widget.pages[index])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                FilledButton(
                  onPressed: currentPage == 0 ? null : _previousPage,
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: currentPage == widget.pages.length - 1
                      ? lastPageButtonAction()
                      : _nextPage,
                  child: widget.lastPageButtonLabel != null &&
                          currentPage == widget.pages.length - 1
                      ? Text(widget.lastPageButtonLabel!)
                      : const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (currentPage != widget.pages.length - 1) {
      setState(() => currentPage++);
      _gotoPage();
    }
  }

  void _previousPage() {
    if (currentPage != 0) {
      setState(() => currentPage--);
      _gotoPage();
    }
  }

  void _gotoPage() {
    controller.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}

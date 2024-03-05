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
      minimum: const EdgeInsets.symmetric(vertical: 0),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Theme.of(context).colorScheme.onBackground,
                height: .1,
              ),
              Expanded(
                child: PageView(
                  controller: controller,
                  onPageChanged: (page) => setState(() => currentPage = page),
                  children: List.generate(widget.pages.length,
                      (index) => buildPage(widget.pages[index])),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  onPressed: currentPage == 0 ? null : _previousPage,
                  style: ButtonStyle(
                    minimumSize: const MaterialStatePropertyAll(
                      Size(80, 48),
                    ),
                    maximumSize: const MaterialStatePropertyAll(
                      Size(double.infinity, 48),
                    ),
                    shape: const MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  icon: const Icon(Icons.navigate_before_rounded, size: 32),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: currentPage == widget.pages.length - 1
                        ? lastPageButtonAction()
                        : _nextPage,
                    child: widget.lastPageButtonLabel != null &&
                            currentPage == widget.pages.length - 1
                        ? Text(widget.lastPageButtonLabel!)
                        : const Text('Next'),
                  ),
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

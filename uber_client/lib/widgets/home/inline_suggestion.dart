import 'package:flutter/material.dart';

class InlineSuggestion {
  final String title;
  final String id;
  final String subtitle;
  final String thirdtitle;

  final String image;
  final int quantity;

  final VoidCallback onTap;

  InlineSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.thirdtitle,
    required this.image,
    required this.quantity,
    required this.onTap,
  });
}

class InlineSuggestions extends StatefulWidget {
  final List<InlineSuggestion> suggestions;
  final void Function(int index) onView;

  const InlineSuggestions({
    super.key,
    required this.suggestions,
    required this.onView,
  });

  @override
  State<InlineSuggestions> createState() => _InlineSuggestionsState();
}

class _InlineSuggestionsState extends State<InlineSuggestions> {
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    pageController = PageController(
      viewportFraction: .8,
      initialPage: currentPage,
    );

    pageController.addListener(() {
      final rounded = pageController.page!.round();
      if (currentPage == rounded) return;
      widget.onView(rounded);
      currentPage = rounded;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: pageController,
        itemCount: widget.suggestions.length,
        itemBuilder: (ctx, index) {
          final suggestion = widget.suggestions[index];
          return Container(
            margin: const EdgeInsets.only(right: 16, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${index + 1} of ${widget.suggestions.length}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  onTap: suggestion.onTap,
                  leading: SizedBox(
                    height: 45,
                    width: 45,
                    child: Stack(
                      children: [
                        Hero(
                          tag: "Bag-Seller-Photo${suggestion.id}",
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(suggestion.image),
                          ),
                        ),
                        if (suggestion.quantity < 5)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: suggestion.quantity < 1
                                  ? Colors.grey.shade200
                                  : Colors.yellow.shade200,
                              child: Center(
                                child: Text(
                                  suggestion.quantity < 1
                                      ? "-"
                                      : suggestion.quantity.toString(),
                                  style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  title: Text(
                    suggestion.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    suggestion.subtitle,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

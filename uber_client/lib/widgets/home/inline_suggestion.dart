import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_cubit.dart';
import '../../models/ad.dart';

abstract class InlineSuggestionBase {}

class InlineAd extends InlineSuggestionBase {
  final String id;
  final String photo;
  final String link;

  InlineAd({
    required this.id,
    required this.photo,
    required this.link,
  });

  factory InlineAd.fromAd(Ad ad) {
    return InlineAd(id: ad.id, link: ad.link, photo: ad.photo);
  }
}

class InlineSuggestion extends InlineSuggestionBase {
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
  final List<InlineSuggestionBase> suggestions;
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

  List<InlineSuggestionBase> inlineSuggestions = [];

  List<InlineAd> ads = [];

  @override
  void initState() {
    pageController = PageController(
      viewportFraction: .8,
      initialPage: currentPage,
    );

    pageController.addListener(() {
      final rounded = pageController.page!.round();
      if (currentPage == rounded) return;

      final focused = inlineSuggestions[rounded];
      if (focused is InlineSuggestion) {
        final viewIndex = widget.suggestions.indexWhere(
          (element) => element is InlineSuggestion && element.id == focused.id,
        );

        widget.onView(viewIndex);
      }
      currentPage = rounded;
    });
    super.initState();
  }

  void mergeAds(
    List<Ad> newAds, {
    bool force = false,
  }) {
    if (widget.suggestions.isEmpty) return;

    if (newAds.isNotEmpty && !force) {
      if (newAds.every((prev) => ads.any((ne) => ne.id == prev.id))) {
        return;
      }
    }
    ads = newAds.map((e) => InlineAd.fromAd(e)).toList();
    inlineSuggestions = [...widget.suggestions];

    final adsSet =
        ads.sublist(0, min(ads.length, max(1, inlineSuggestions.length ~/ 7)));

    adsSet.shuffle();

    var randomIndices =
        _generateRandomIndices(adsSet.length, widget.suggestions.length);
    for (var i = 0; i < adsSet.length; i++) {
      inlineSuggestions.insert(randomIndices[i], adsSet[i]);
    }

    setState(() => {});
  }

  @override
  void didUpdateWidget(covariant InlineSuggestions oldWidget) {
    if (widget.suggestions.length != oldWidget.suggestions.length) {
      print("dependecining");
      mergeAds([], force: true);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    mergeAds([]); // todo remove this is useless!
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AppCubit>().state.ads;
    final target = ads.where((element) => element.location == "home").toList();
    mergeAds(target);

    return SizedBox(
        height: 110,
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          itemCount: inlineSuggestions.length,
          itemBuilder: (ctx, index) {
            final suggestion = inlineSuggestions[index];
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
              child: suggestion is InlineAd
                  ? GestureDetector(
                      onTap: () => AndroidIntent(
                        action: 'action_view',
                        data: suggestion.link,
                      ).launch(),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(suggestion.photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${index + 1} of ${inlineSuggestions.length}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (suggestion is InlineSuggestion)
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
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          NetworkImage(suggestion.image),
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
                                                : suggestion.quantity
                                                    .toString(),
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
        ));
  }
}

List<int> _generateRandomIndices(int count, int range) {
  var random = Random();
  var uniqueIndices = <int>{};
  while (uniqueIndices.length < count) {
    uniqueIndices.add(random.nextInt(range));
  }
  return uniqueIndices.toList();
}

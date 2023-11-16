import 'dart:async';
import 'dart:math';

import "../utils/utils.dart";

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:bsahtak/cubits/app_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/sliver_multi_box_adaptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';
import 'package:bsahtak/widgets/shared/location_picker.dart';
import 'package:go_router/go_router.dart';

import '../cubits/home_cubit.dart';
import '../models/ad.dart';
import '../models/bag.dart';
import '../widgets/shared/suggestion_card.dart';
import 'bag_screen.dart';
import 'filters.dart';
import 'location_selector.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final searchNode = FocusNode();
  final search = TextEditingController();

  bool doSearch = false;

  @override
  void initState() {
    searchNode.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  List<Bag> getSearchResults() {
    final cubit = context.watch<BagsQubit>().state;

    final bags = cubit.visibleBags;

    var filtredBags = bags.where((bag) {
      return bag.name.toLowerCase().contains(search.text.toLowerCase()) ||
          bag.description.toLowerCase().contains(search.text.toLowerCase()) ||
          bag.sellerName.toLowerCase().contains(search.text.toLowerCase()) ||
          bag.tags.toLowerCase().contains(search.text.toLowerCase());
    }).toList();

    return filtredBags;
  }

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<BagsQubit>().state.availableTags;
    final currentFilter = context.watch<HomeCubit>().state.filter;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).canvasColor,
              elevation: 3,
              expandedHeight: 130,
              flexibleSpace: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LocationPicker(
                      onTap: () {
                        context.push("/discover/location-picker");
                      },
                      isTransparent: true,
                    ),
                    SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                                child: TextField(
                              controller: search,
                              focusNode: searchNode,
                              onSubmitted: (value) {
                                setState(() {
                                  doSearch = value.length > 2;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .discover_search,
                                contentPadding: EdgeInsets.all(0),
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(.5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                            SizedBox(width: 8),
                            AspectRatio(
                              aspectRatio: 1,
                              child: SizedBox(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.push("/discover/filters");
                                  },
                                  child: Icon(
                                    Icons.settings,
                                    color: currentFilter != null
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.withOpacity(.5),
                                      width: 1,
                                    ),
                                    backgroundColor: currentFilter != null
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(0),
                                  ),
                                ),
                                height: double.infinity,
                              ),
                            ),
                            if (searchNode.hasFocus || doSearch)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    doSearch = false;
                                    searchNode.unfocus();
                                    search.text = "";
                                  });
                                },
                                child: Text("cancel"),
                              )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              floating: true,
              collapsedHeight: 130,
              snap: true,
            ),
            if (doSearch == true)
              SliverList(
                key: Key("search"),
                delegate: SliverChildListDelegate([
                  ...getSearchResults().map((spot) {
                    final cubit = context.watch<BagsQubit>().state;

                    final quantity = cubit.quantities[spot.id.toString()] ?? 0;
                    if (currentFilter?.check(spot, quantity) == false) {
                      return SizedBox.shrink();
                    }

                    return SuggestionCard(
                      aspectRatio: 16 / 12,
                      id: spot.id,
                      title: spot.name,
                      subtitle: spot.sellerAddress,
                      chip: quantity < 5
                          ? quantity != 0
                              ? "$quantity"
                              : null
                          : null,
                      discountPrice: spot.originalPrice.toString(),
                      distance: (Geolocator.distanceBetween(
                                spot.latitude,
                                spot.longitude,
                                cubit.currentLocation!.latitude,
                                cubit.currentLocation!.longitude,
                              ) /
                              1000)
                          .toStringAsFixed(2),
                      picture: spot.photo,
                      price: spot.price.toString(),
                      rating: spot.rating.toStringAsFixed(1),
                      storeName: spot.sellerName,
                      storePicture: spot.sellerPhoto,
                      onTap: () => BagScreen.go(context, spot),
                      onFavoriteTap: () =>
                          context.read<HomeCubit>().toggleLiked(spot),
                    );
                  })
                ]),
              ),
            if (doSearch != true) ...[
              SliverToBoxAdapter(
                child: DiscoverAd(
                  where: "discover-top",
                ),
              ),
              SliverToBoxAdapter(
                child: AutoSuggestionView(
                  label: AppLocalizations.of(context)!.discover_recommanded,
                  description: "Bags we think you'll love.",
                  secondFilter: (b, d, q) => currentFilter?.check(b, q) ?? true,
                  filter: (bag, distance, quantity) =>
                      quantity > 3 || distance < 2,
                  max: 5,
                ),
              ),
              SliverToBoxAdapter(
                child: AutoSuggestionView(
                  label: AppLocalizations.of(context)!.discover_before_end,
                  secondFilter: (b, d, q) => currentFilter?.check(b, q) ?? true,
                  description:
                      "Bags won't be on sale for long.. but there's still a chance to save them!",
                  filter: (bag, distance, quantity) =>
                      quantity < 2 && quantity > 0,
                ),
              ),
              SliverToBoxAdapter(
                child: DiscoverAd(
                  where: "discover-center",
                ),
              ),
              ...tags.map(
                (e) => SliverToBoxAdapter(
                  child: AutoSuggestionView(
                      label: e,
                      secondFilter: (b, d, q) =>
                          currentFilter?.check(b, q) ?? true,
                      filter: (bag, distance, quantity) {
                        return bag.tags.toLowerCase().contains(e.toLowerCase());
                      }),
                ),
              ),
              SliverToBoxAdapter(
                child: DiscoverAd(
                  where: "discover-end",
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class DiscoverAd extends StatefulWidget {
  final String where;
  const DiscoverAd({
    super.key,
    required this.where,
  });

  @override
  State<DiscoverAd> createState() => _DiscoverAdState();
}

class _DiscoverAdState extends State<DiscoverAd> {
  final controller = PageController();
  Timer? timer;

  int maxPage = 1;
  int currentPage = 0;
  int direction = 1;

  @override
  void initState() {
    super.initState();
  }

  void startAutoScrolling() {
    // timer?.cancel();
    // timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   if (currentPage == maxPage || currentPage == -1) {
    //     direction *= -1;
    //   }
    //   currentPage = currentPage + direction;
    //   controller.animateToPage( // todo there is a bug here, however this functionality as been droped
    //     currentPage,
    //     duration: Duration(milliseconds: 350),
    //     curve: Curves.easeInExpo,
    //   );
    // });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<Ad> getAds(List<Ad> all) {
    return all.where((element) => element.location == widget.where).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppState>(
        listenWhen: (n, o) => n.ads != o.ads,
        listener: (ctx, state) {
          maxPage = getAds(state.ads).length;
          startAutoScrolling();
        },
        builder: (context, state) {
          final ads = getAds(state.ads);
          if (ads.isEmpty) return SizedBox.shrink();

          return AspectRatio(
            aspectRatio: 16 / 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: PageView(
                controller: controller,
                children: [
                  ...ads.map((e) => Material(
                        child: InkWell(
                          onTap: () => AndroidIntent(
                            action: 'action_view',
                            data: e.link,
                          ).launch(),
                          child: Image.network(
                            e.photo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          );
        });
  }
}

class AutoSuggestionView extends StatelessWidget {
  final String label;
  final String? description;
  final int max;
  final bool Function(Bag bag, double distance, int quantity) filter;
  final bool Function(Bag bag, double distance, int quantity)? secondFilter;

  const AutoSuggestionView({
    super.key,
    required this.label,
    this.description,
    required this.filter,
    this.secondFilter,
    this.max = 10000,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<BagsQubit>().state;

    final bags = cubit.visibleBags;

    var filtredBags = bags.where((bag) {
      final distance = Geolocator.distanceBetween(
            bag.latitude,
            bag.longitude,
            cubit.currentLocation!.latitude,
            cubit.currentLocation!.longitude,
          ) /
          1000;

      final quantity = cubit.quantities[bag.id.toString()];
      if (quantity == null) return false;

      if (secondFilter != null && !secondFilter!(bag, distance, quantity))
        return false;

      return filter(bag, distance, quantity);
    }).toList();

    if (filtredBags.length < 2) return const SizedBox.shrink();

    // if (random) filtredBags.shuffle();
    filtredBags = filtredBags.sublist(0, min(max, filtredBags.length));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Label(Utils.splitTranslation(label, context)),
            TextButton(
              child: Text(AppLocalizations.of(context)!.discover_seeall),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        title: Text(Utils.splitTranslation(label, context)),
                        elevation: 0,
                        foregroundColor: Colors.black87,
                      ),
                      body: ListView.builder(
                        padding: EdgeInsets.only(top: 12),
                        clipBehavior: Clip.none,
                        itemBuilder: (ctx, index) {
                          final spot = filtredBags[index];
                          final quantity =
                              cubit.quantities[spot.id.toString()] ?? 0;
                          return SuggestionCard(
                            aspectRatio: 16 / 12,
                            id: spot.id,
                            title: spot.name,
                            subtitle: spot.sellerAddress,
                            chip: quantity < 5
                                ? quantity != 0
                                    ? "$quantity"
                                    : null
                                : null,
                            discountPrice: spot.originalPrice.toString(),
                            distance: (Geolocator.distanceBetween(
                                      spot.latitude,
                                      spot.longitude,
                                      cubit.currentLocation!.latitude,
                                      cubit.currentLocation!.longitude,
                                    ) /
                                    1000)
                                .toStringAsFixed(2),
                            picture: spot.photo,
                            price: spot.price.toString(),
                            rating: spot.rating.toStringAsFixed(1),
                            storeName: spot.sellerName,
                            storePicture: spot.sellerPhoto,
                            onTap: () => BagScreen.go(context, spot),
                            onFavoriteTap: () =>
                                context.read<HomeCubit>().toggleLiked(spot),
                          );
                        },
                        itemCount: filtredBags.length,
                      ),
                      // body: ListView.
                    ),
                  ),
                );
              },
            )
          ],
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final spot = filtredBags[index];
              final quantity = cubit.quantities[spot.id.toString()] ?? 0;

              return SuggestionCard(
                aspectRatio: 16 / 14,
                id: spot.id,
                title: spot.name,
                subtitle: spot.sellerAddress,
                chip: quantity < 5
                    ? quantity != 0
                        ? "$quantity"
                        : null
                    : null,
                discountPrice: spot.originalPrice.toString(),
                distance: (Geolocator.distanceBetween(
                          spot.latitude,
                          spot.longitude,
                          cubit.currentLocation!.latitude,
                          cubit.currentLocation!.longitude,
                        ) /
                        1000)
                    .toStringAsFixed(2),
                picture: spot.photo,
                price: spot.price.toString(),
                rating: spot.rating.toStringAsFixed(1),
                storeName: spot.sellerName,
                storePicture: spot.sellerPhoto,
                onTap: () => BagScreen.go(context, spot),
                onFavoriteTap: () =>
                    context.read<HomeCubit>().toggleLiked(spot),
              );
            },
            itemCount: filtredBags.length,
          ),
        ),
      ],
    );
  }
}

class Label extends StatelessWidget {
  final String label;
  const Label(
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 26, bottom: 16),
          child: Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

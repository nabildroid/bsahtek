import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/widgets/shared/location_picker.dart';

import '../cubits/home_cubit.dart';
import '../models/bag.dart';
import '../widgets/shared/suggestion_card.dart';
import 'bag_screen.dart';
import 'location_selector.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    final tags = context.watch<BagsQubit>().state.availableTags;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 3,
              expandedHeight: 100,
              flexibleSpace: Padding(
                padding: EdgeInsets.only(top: 20),
                child: LocationPicker(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => LocationSelector(),
                    );
                  },
                  isTransparent: true,
                ),
              ),
              floating: true,
              collapsedHeight: 100,
              snap: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                AutoSuggestionView(
                  label: "Recommended for you",
                  filter: (bag, distance, quantity) =>
                      quantity > 3 || distance < 2,
                  random: true,
                  max: 5,
                ),
                AutoSuggestionView(
                  label: "Save before end",
                  filter: (bag, distance, quantity) => quantity < 2,
                ),
                ...tags.map(
                  (e) => AutoSuggestionView(
                    label: e,
                    filter: (bag, distance, quantity) => bag.tags.contains(e),
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}

class AutoSuggestionView extends StatelessWidget {
  final String label;
  final bool random;
  final int max;
  final bool Function(Bag bag, double distance, int quantity) filter;

  const AutoSuggestionView({
    super.key,
    required this.label,
    required this.filter,
    this.random = false,
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

      final quantity = cubit.quantities[bag.id.toString()] ?? 0;
      if (quantity == 0) return false;
      return filter(bag, distance, quantity);
    }).toList();

    if (filtredBags.length < 2) return const SizedBox.shrink();

    if (random) filtredBags.shuffle();
    filtredBags = filtredBags.sublist(0, min(max, filtredBags.length));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Label(label),
        SizedBox(
          height: 240,
          child: ListView.builder(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              final spot = filtredBags[index];
              return SuggestionCard(
                aspectRatio: 16 / 14,
                id: spot.id,
                title: spot.name,
                subtitle: spot.sellerAddress,
                chip: "Bag 1",
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
          padding: EdgeInsets.only(left: 20, top: 26, bottom: 16),
          child: Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

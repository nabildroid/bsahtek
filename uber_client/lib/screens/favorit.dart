import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/cubits/home_cubit.dart';
import 'package:uber_client/widgets/shared/suggestion_card.dart';

import 'bag_screen.dart';

class FavoritScreen extends StatelessWidget {
  const FavoritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liked Bag",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
        final currentLocation =
            context.watch<BagsQubit>().state.currentLocation;
        return SingleChildScrollView(
          child: Column(
            children: state.liked
                .map((bag) => SuggestionCard(
                      id: bag.id,
                      title: bag.name,
                      subtitle: bag.sellerAddress,
                      picture: bag.photo,
                      rating: bag.rating.toStringAsFixed(1),
                      price: bag.originalPrice.toString(),
                      discountPrice: bag.price.toString(),
                      chip: bag.tags,
                      distance: (Geolocator.distanceBetween(
                                bag.latitude,
                                bag.longitude,
                                currentLocation!.latitude,
                                currentLocation.longitude,
                              ) /
                              1000)
                          .toStringAsFixed(2),
                      storeName: bag.sellerName,
                      storePicture: bag.sellerPhoto,
                      onTap: () => BagScreen.go(context, bag),
                      onFavoriteTap: () =>
                          context.read<HomeCubit>().toggleLiked(bag),
                    ))
                .toList(),
          ),
        );
      }),
    );
  }
}

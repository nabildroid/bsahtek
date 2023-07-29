import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_client/cubits/home_cubit.dart';

class SuggestionCard extends StatelessWidget {
  // todo why not accepting the entire bag as a parameter?
  final String title;
  final int id;
  final String subtitle;
  final String picture;
  final String rating;
  final String price;
  final String discountPrice;

  final String chip;
  final String distance;

  final String storeName;
  final String storePicture;

  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  final double aspectRatio;

  const SuggestionCard({
    super.key,
    required this.title,
    required this.id,
    required this.subtitle,
    required this.picture,
    required this.rating,
    required this.price,
    required this.discountPrice,
    required this.chip,
    required this.distance,
    required this.storeName,
    required this.storePicture,
    required this.onTap,
    required this.onFavoriteTap,
    this.aspectRatio = 16 / 11,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = context.watch<HomeCubit>().isLiked(id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Expanded(
                      flex: 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(0.2),
                                  BlendMode.color),
                              child: Image.network(
                                picture,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Chip(
                                      //   label: Text(
                                      //     chip,
                                      //     style: TextStyle(color: Colors.white),
                                      //   ),
                                      //   backgroundColor: Colors.black,
                                      // ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: onFavoriteTap,
                                        icon: Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLiked
                                              ? const Color.fromARGB(
                                                  255, 26, 17, 17)
                                              : Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(storePicture),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        storeName,
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )
                                  ])
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "\$$price",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.green.shade800,
                                ),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Divider(
                                  color: Colors.black,
                                  endIndent: 4,
                                  indent: 4,
                                  thickness: 4,
                                ),
                                Text(
                                  "$distance km",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "\$$discountPrice",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

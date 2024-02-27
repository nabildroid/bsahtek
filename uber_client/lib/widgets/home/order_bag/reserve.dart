import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/bag.dart';
import '../../../utils/utils.dart';

class Reserve extends StatelessWidget {
  final Bag bag;
  final int quantity;
  final int maxQuantity;
  final double distance;
  final bool loading;
  final bool done;
  final Function(int quantity) setQuantity;
  final Function() reserve;

  const Reserve({
    super.key,
    required this.bag,
    required this.quantity,
    required this.maxQuantity,
    required this.setQuantity,
    required this.distance,
    required this.reserve,
    required this.loading,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          child: Text(
            bag.sellerName +
                "\n" +
                (bag.name == bag.sellerName
                    ? ""
                    : Utils.splitTranslation(bag.name, context)),
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(height: 32),
        Text(
          AppLocalizations.of(context)!.bag_order_quantity,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 16),
        Row(
          // create 2 icon button in cirlceAvarat and in center number of quantity
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: quantity < 2
                  ? Colors.black12
                  : Theme.of(context).colorScheme.primary,
              child: IconButton(
                onPressed: () {
                  if (quantity > 1) {
                    setQuantity(quantity - 1);
                  }
                },
                icon: Icon(
                  Icons.remove,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: "monospace",
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(
              width: 16,
            ),
            CircleAvatar(
              backgroundColor: quantity >= maxQuantity
                  ? Colors.black12
                  : Theme.of(context).colorScheme.primary,
              child: IconButton(
                onPressed: () {
                  if (quantity < maxQuantity) setQuantity(quantity + 1);
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Spacer(),
        // ListTile(
        //   title: Text("Pickup"),
        //   trailing: Switch(
        //     value: isPickup,
        //     onChanged: (value) {
        //       // todo for now we don't need this
        //       // setState(() {
        //       //   isPickup = value;
        //       // });
        //     },
        //   ),
        // ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.bag_order_total),
          trailing: Text(
            (bag.price * quantity).toStringAsFixed(2) +
                AppLocalizations.of(context)!.bag_price_unit,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontFamily: "monospace",
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: distance > 50
                      ? MaterialStateProperty.all(Colors.grey.shade600)
                      : MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: reserve,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: loading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : done
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : distance > 50
                              ? Text("Too Far")
                              : Text(
                                  AppLocalizations.of(context)!
                                      .bag_order_reserve,
                                  key: ValueKey("Reserve Now"),
                                ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      // if the scroll has moved little then expand isExpanded, if the scroll riched the top then collapse isExpanded
      setState(() {
        isExpanded = _scrollController.offset > 10;
      });
    });
    super.initState();
  }

  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  image: DecorationImage(
                    image: AssetImage('assets/texture.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                child: AnimatedSlide(
                  duration: Duration(milliseconds: 500),
                  offset: isExpanded ? Offset(0, 0.2) : Offset(0, 0),
                  curve: Curves.easeInExpo,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 350),
                    opacity: isExpanded ? 0.6 : 1,
                    child: AnimatedScale(
                      duration: Duration(milliseconds: 350),
                      scale: isExpanded ? 0.9 : 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: '5',
                                      style: TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' bags',
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white.withOpacity(.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      "Available Bags for Clients",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        'https://picsum.photos/200'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ActionButton(
                                label: "Add",
                                icon: Icons.add_shopping_cart_rounded,
                              ),
                              ActionButton(
                                  label: "Subtract",
                                  icon: Icons.remove_circle_outline_sharp),
                              SizedBox(width: 5),
                              ActionButton(
                                  label: "Pause",
                                  icon: Icons.remove_shopping_cart_outlined),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: Duration(milliseconds: 500),
              alignment: Alignment.bottomCenter,
              heightFactor: isExpanded ? 0.9 : 0.62,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20)
                      .copyWith(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Basket",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 12),
                        BagPreview(),
                        SizedBox(height: 16),
                        Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...List.generate(
                          10,
                          (index) => OrderTile(),
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class BagPreview extends StatelessWidget {
  const BagPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 18,
              offset: const Offset(0, 6),
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
                              Colors.white.withOpacity(0.2), BlendMode.color),
                          child: Image.network(
                            "https://picsum.photos/200",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                              Row(children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://arib.shop/logo1.png"),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Supirate zigadi",
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
                          "Suprise Bag",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Lorem ipsum dolor sit amet",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "\$15.0",
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
                              "4.4",
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
                              "15 km",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "\$12.2",
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
    );
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.playlist_add_check_circle_outlined,
      ),
      title: Text("#Order ${1}"),
      subtitle: Text("+2156896562 "),
      trailing: Text(
        "+ 12.2\$",
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
    );
  }
}

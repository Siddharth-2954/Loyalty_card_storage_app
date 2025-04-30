import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Item {
  final String image;
  final String label;
  final double point;
  final String description;

  const Item({
    required this.image,
    required this.label,
    required this.point,
    required this.description,
  });
}

class ItemList extends StatelessWidget {
  const ItemList({Key? key, required this.label}) : super(key: key);
  final String label;

  @override
  Widget build(BuildContext context) {
    final List<Item> items = [
      const Item(
        image: "https://cdn.mos.cms.futurecdn.net/eW8gPh9RFcpAwYDsyM3t7Q.jpg",
        label: "Get 1x Playstation 4",
        description: "Sony Playstation 4",
        point: 140000,
      ),
      const Item(
        image: "https://cdn.mos.cms.futurecdn.net/eW8gPh9RFcpAwYDsyM3t7Q.jpg",
        label: "Get 1x Playstation 4",
        description: "Sony Playstation 4",
        point: 140000,
      ),
      const Item(
        image: "https://cdn.mos.cms.futurecdn.net/eW8gPh9RFcpAwYDsyM3t7Q.jpg",
        label: "Get 1x Playstation 4",
        description: "Sony Playstation 4",
        point: 140000,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: <Widget>[
          Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    "See all",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final Item item = items[index];
                return buildItem(context, item, index);
              },
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }

  Container buildItem(BuildContext context, Item item, int index) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(left: 12, right: 4),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            bottom: 20,
            child: Image.network(
              item.image,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 24,
            child: Card(
              margin: const EdgeInsets.all(1),
              child: Container(
                height: 80,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      NumberFormat("###,###,### P").format(item.point),
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.all(0),
              height: 32,
              width: 72,
              child: FloatingActionButton.extended(
                heroTag: "$label-${item.label}-$index",
                elevation: 1,
                onPressed: () {},
                label: Text(
                  "Redeem",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

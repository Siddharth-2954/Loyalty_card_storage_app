import 'package:dashboard_template/helpers/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category {
  final Widget icon;
  final String label;

  const Category(this.icon, this.label);
}

class CategoriesList extends StatelessWidget {
  const CategoriesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = [
      Category(const Icon(FontAwesomeIcons.award), "All"),
      Category(const Icon(FontAwesomeIcons.utensils), "Food & Beverage"),
      Category(const Icon(FontAwesomeIcons.tag), "Limited Edition"),
      Category(const Icon(FontAwesomeIcons.tools), "Services"),
      Category(const Icon(FontAwesomeIcons.shoppingBag), "Shopping"),
      Category(const Icon(FontAwesomeIcons.luggageCart), "Travel"),
      Category(const Icon(FontAwesomeIcons.ticketAlt), "Entertainment"),
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final Category category = categories[index];
          return Container(
            width: 72,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                  ),
                  height: 60,
                  width: 60,
                  child: IconTheme(
                    data: Theme.of(context).iconTheme.copyWith(
                          color: ColorHelper.keepOrWhite(
                            Theme.of(context).primaryColor,
                            Theme.of(context).cardColor,
                            alternateColor: Colors.white,
                          ),
                        ),
                    child: category.icon,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  category.label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
        itemCount: categories.length,
      ),
    );
  }
}

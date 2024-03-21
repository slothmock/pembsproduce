import 'package:flutter/material.dart';

import '../../main.dart';

import '../helpers/constants/colors.dart';
import '../helpers/models/farmshop.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key, required this.shop});

  final Farmshop? shop;

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  late Image shopImage;

  Image getShopImage(String shopName) {
    shopName = shopName.replaceAll(" ", "_");
    final shopImageURL =
        supabase.storage.from('shop_images').getPublicUrl(shopName);

    shopImage = Image.network(
      shopImageURL,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
    return shopImage;
  }

  @override
  void initState() {
    super.initState();
    shopImage = getShopImage(widget.shop!.name!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.shop!.name!),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.shopImageBG,
              alignment: Alignment.topCenter,
              height: MediaQuery.sizeOf(context).height / 2.25,
              child: shopImage,
            ),
            const SizedBox(height: 18.0),
            Expanded(
                child: Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          widget.shop!.description!,
                          style: const TextStyle(fontSize: 22.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

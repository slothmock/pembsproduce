import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:map_launcher/map_launcher.dart';
import 'package:pembs_produce/src/helpers/location.dart';

import '../../main.dart';

import '../helpers/constants/colors.dart';
import '../helpers/models/farmshop.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key, required this.shop});

  final Farmshop shop;


  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  late String shopDesc;
  late Image? shopImage;
  final Image placeholderImage =
      const Image(image: AssetImage("assets/no_image_placeholder.png"));

  final DirectionsMode _directionsMode = DirectionsMode.driving;

  Image? getShopImage(String shopName) {
    shopName = shopName.replaceAll(" ", "_");

    try {
      final shopImageURL =
          supabase.storage.from('avatars').getPublicUrl(shopName);

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
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print(error);
          }
          return Image(image: placeholderImage.image);
        },
      );

      return shopImage;
    } on NetworkImageLoadException catch (e) {
      if (kDebugMode) {
        print("## ERR ## - $e");
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    shopImage = getShopImage(widget.shop.name);
    shopDesc = widget.shop.description.isNotEmpty ? widget.shop.description : "No description available...";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.shop.name),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.primaryBackground,
              alignment: Alignment.center,
              height: MediaQuery.sizeOf(context).height / 2.25,
              child: shopImage,
            ),
            const SizedBox(height: 8.0),
            Expanded(
                child: Container(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                              child: Text(
                                shopDesc,
                                softWrap: true,
                                maxLines: 11,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 22.0, overflow: TextOverflow.clip),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Center(
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      minimumSize: MaterialStatePropertyAll(Size(192.0, 36.0))
                    ),
                    onPressed: () async { 
                      Position userLocation = await LocationHelper.getUserCurrentLocation();
                      await MapLauncher.showDirections(
                        mapType: MapType.google, 
                        origin: Coords(
                          userLocation.latitude, userLocation.longitude),
                        originTitle: "Your Location",
                        destination: Coords(widget.shop.lat, widget.shop.lon),
                        destinationTitle: widget.shop.name,
                        directionsMode: _directionsMode
                        );
                     },
                    child: const Text("Get Directions"),)
                )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

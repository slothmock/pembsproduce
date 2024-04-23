import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pembs_produce/src/pages/faq.dart';

const String appID = 'com.pembsproduceltd.pembsproduce.release';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  DonationPageState createState() => DonationPageState();
}

class DonationPageState extends State<DonationPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;

  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];

  // subscription that listens to a stream of updates to purchase details
  late StreamSubscription _subscription;

  Future<void> _initialize() async {
    _isAvailable = await _iap.isAvailable();

    // perform our async calls only when in-app purchase is available
    if (_isAvailable) {
      await _getUserProducts();

      // listen to new purchases and rebuild the widget whenever
      // there is a new purchase after adding the new purchase to our
      // purchase list

      _subscription = _iap.purchaseStream.listen((data) => setState(() {
            _purchases.addAll(data);
          }));
    }
  }

  Future<void> _getUserProducts() async {
    Set<String> ids = {appID};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    setState(() {
      _products = response.productDetails;
    });
  }

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    // cancelling the subscription
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make a donation"),
        centerTitle: true,
        leading: IconButton(
            onPressed: () =>
                Navigator.of(context).pushReplacement(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const FAQPage(),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (_, a, __, c) => FadeTransition(
                    opacity: a,
                    child: c,
                  ),
                )),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Center(
        child: Column(
          children: [
            if (_products.isEmpty) ...[
              const Text("Currently unavailable...")
            ] else ...[
              for (var product in _products) ...[
                Text(
                  product.title,
                ),
                Text(product.description),
                Text(product.price),
                ElevatedButton(
                    onPressed: () => _buyProduct(product),
                    child: const Text(''))
              ]
            ]
          ],
        ),
      ),
    );
  }
}

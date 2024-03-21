// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../main.dart' show supabase;
import '../helpers/constants/colors.dart';
import '../helpers/models/farmshop.dart';
import 'shop_details.dart';

class ShopMapPage extends StatefulWidget {
  const ShopMapPage({super.key});

  @override
  State<ShopMapPage> createState() => _ShopMapPageState();
}

class _ShopMapPageState extends State<ShopMapPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final _future = supabase.from('farmshops').select().eq('active', true);
  late dynamic _farmshopData;
  final Map<String, Farmshop> _farmshops = {};

  // ignore: unused_field
  late GoogleMapController _mapController;
  static const CameraPosition _kPembs = CameraPosition(
    target: LatLng(51.80704091358167, -4.957055690899498),
    zoom: 10.5,
  );
  final Map<String, Marker> _markers = {};

  late String? _shopLat;
  late String? _shopLon;

  @override
  void initState() {
    super.initState();
  }

  void _closeDialog() {
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    setState(() {
      _markers.clear();
      for (final shopMarker in _farmshopData) {
        final marker = Marker(
          markerId: MarkerId(shopMarker["name"]),
          position: LatLng(shopMarker["lat"], shopMarker["lon"]),
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  ShopDetailsPage(shop: _farmshops[shopMarker['name']]),
              transitionDuration: const Duration(seconds: 1),
              transitionsBuilder: (_, a, __, c) => FadeTransition(
                opacity: a,
                child: c,
              ),
            ));
          },
        );
        _markers[shopMarker["name"]] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('PembsProduce'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          elevation: 2.0,
                          scrollable: true,
                          title:
                              const Center(child: Text('Add to PembsProduce')),
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Place Name',
                                    ),
                                  ),
                                  TextFormField(
                                    maxLines: 4,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'A Short Description',
                                    ),
                                  ),
                                  GooglePlaceAutoCompleteTextField(
                                    textEditingController: _addressController,
                                    googleAPIKey:
                                        dotenv.env['GOOGLE_API_KEY'] ?? '',
                                    inputDecoration: const InputDecoration(
                                            labelText: "Address")
                                        .applyDefaults(ThemeData.dark()
                                            .inputDecorationTheme),
                                    boxDecoration:
                                        const BoxDecoration(border: null),
                                    debounceTime: 300,
                                    countries: const ["UK"],
                                    isLatLngRequired: true,
                                    getPlaceDetailWithLatLng:
                                        (Prediction prediction) {
                                      // this method will return latlng with place detail
                                      if (kDebugMode) {
                                        print("placeDetails${prediction.lng}");
                                      }
                                      _shopLat = prediction.lat;
                                      _shopLon = prediction.lng;
                                    },
                                    itemClick: (Prediction prediction) {
                                      _addressController.text =
                                          prediction.description!;
                                      _addressController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: prediction
                                                      .description!.length));
                                    },
                                    itemBuilder: (context, index,
                                        Prediction prediction) {
                                      return Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.location_on),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Expanded(
                                                child: Text(
                                                    prediction.description ??
                                                        ""))
                                          ],
                                        ),
                                      );
                                    },
                                    seperatedBuilder: const Divider(),
                                    isCrossBtnShown: false,
                                  )
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                  child: const Text("Submit for review"),
                                  onPressed: () async {
                                    await supabase.from('farmshops').insert({
                                      "name": _nameController.value.text,
                                      "description":
                                          _descriptionController.value.text,
                                      "lat": _shopLat,
                                      "lon": _shopLon,
                                      "active": false,
                                    });
                                    _closeDialog();
                                    await showDialog<void>(
                                        useSafeArea: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const Center(
                                            child: AlertDialog(
                                              content: SizedBox(
                                                height: 250,
                                                child: Center(
                                                  child: Text(
                                                    "Thanks!\n\nYour submission has been sent for review!",
                                                    style: TextStyle(
                                                      fontSize: 24.0,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }),
                            ),
                            const SizedBox(
                              height: 6.0,
                            ),
                            Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary),
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    _closeDialog();
                                  }),
                            )
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.add))
          ]),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          _farmshopData = snapshot.data!;

          for (var farmshop in _farmshopData) {
            farmshop = Farmshop(
                name: farmshop["name"],
                description: farmshop["description"],
                lat: farmshop["lat"],
                lon: farmshop["lon"]);
            _farmshops[farmshop.name] = farmshop;
          }

          return GoogleMap(
            initialCameraPosition: _kPembs,
            onMapCreated: (controller) => _onMapCreated(controller),
            myLocationEnabled: true,
            markers: _markers.values.toSet(),
          );
        },
      ),
    );
  }
}

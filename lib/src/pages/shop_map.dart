// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resend/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart' show resend, supabase;

import '../helpers/models/farmshop.dart';
import 'shop_details.dart';

class ShopMapPage extends StatefulWidget {
  const ShopMapPage({super.key});

  @override
  State<ShopMapPage> createState() => _ShopMapPageState();
}

class _ShopMapPageState extends State<ShopMapPage> {
  late FocusNode _focusNodeName;
  late FocusNode _focusNodeDesc;
  late FocusNode _focusNodeAddr;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final String googleAddressApiKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  final _future = supabase.from('farmshops').select().eq('active', true);
  late dynamic _farmshopData;
  final Map<String, Farmshop> _farmshops = {};

  late GoogleMapController _mapController;
  static const CameraPosition _kPembs = CameraPosition(
    target: LatLng(51.80704091358167, -4.957055690899498),
    zoom: 10.5,
  );
  final Map<String, Marker> _markers = {};
  final LatLngBounds _bounds = LatLngBounds(
    southwest: const LatLng(51.60036862143756, -5.429183658195824), 
    northeast: const LatLng(52.1912052978423, -4.374608878047448));

  late String? _shopLat;
  late String? _shopLon;

  @override
  void initState() {
    super.initState();

    _focusNodeName = FocusNode();
    _focusNodeDesc = FocusNode();
    _focusNodeAddr = FocusNode();

    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
  }

  @override
  void dispose() {
    _focusNodeName.dispose();
    _focusNodeDesc.dispose();
    _focusNodeAddr.dispose();

    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  void _closeDialog() {
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _image = null;
    Navigator.of(context).pop();
  }

  Future getImage(ImageSource media) async {
    var img = await _picker.pickImage(source: media);

    setState(() {
      _image = img;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload successful!")));
    });
  }

  void mediaSelectionAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Please choose media'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void refreshMarkers() async {
    var res = await supabase.from('farmshops').select().eq('active', true);
    setState(() {
      _markers.clear();
      for (var farmshop in res) {
      final marker = Marker(
          markerId: MarkerId(farmshop["name"]),
          position: LatLng(farmshop["lat"], farmshop["lon"]),
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  ShopDetailsPage(shop: _farmshops[farmshop['name']]),
              transitionDuration: const Duration(seconds: 1),
              transitionsBuilder: (_, a, __, c) => FadeTransition(
                opacity: a,
                child: c,
              ),
            ));
          },
        );
        _markers[farmshop["name"]] = marker;
      }
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    setState(() {
      _markers.clear();
      refreshMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('PembsProduce'),
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.refresh), onPressed: () => refreshMarkers(),),
          actions: [
            IconButton(
                onPressed: () async {
                  await showDialog<void>(
                      barrierDismissible: false,
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
                                    focusNode: _focusNodeName,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Place Name',
                                    ),
                                    onTap: () => _focusNodeName.requestFocus(),
                                    onTapOutside: (event) => _focusNodeName.unfocus(),
                                  ),
                                  TextFormField(
                                    focusNode: _focusNodeDesc,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'A Short Description',
                                    ),
                                    onTap: () => _focusNodeDesc.requestFocus(),
                                    onTapOutside: (event) => _focusNodeDesc.unfocus(),
                                  ),
                                  GooglePlaceAutoCompleteTextField(
                                    focusNode: _focusNodeAddr,
                                    textEditingController: _addressController,
                                    googleAPIKey:
                                        dotenv.maybeGet('GOOGLE_API_KEY') ?? '',
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
                                    isCrossBtnShown: true,
                                  )
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            Center(
                              child: IconButton(
                                onPressed: () {
                                  mediaSelectionAlert();
                                },
                                icon: const Icon(Icons.add_a_photo),
                                iconSize: 32,
                              ),
                            ),
                            const SizedBox(height: 32.0),
                            Center(
                              child: ElevatedButton(
                                  child: const Text("Submit for review"),
                                  onPressed: () async {
                                    try {
                                      if (_nameController.value.text.isEmpty ||
                                          _descriptionController.value.text.isEmpty ||
                                          _addressController.value.text.isEmpty ) {
                                        throw Exception("No values entered");
                                      }
                                      await supabase.from('farmshops').insert({
                                        "name": _nameController.value.text,
                                        "description":
                                            _descriptionController.value.text,
                                        "lat": _shopLat,
                                        "lon": _shopLon,
                                        "active": false,
                                      });
                                      var shopName = _nameController.value.text
                                          .replaceAll(" ", "_");
                                      await supabase.storage
                                          .from("avatars")
                                          .upload(shopName, File(_image!.path));
                                      await resend.sendEmail(
                                          from: "farmshops@resend.dev",
                                          to: ["pembsproduce@gmail.com"],
                                          subject: "Farmshop added by user",
                                          text:
                                              'Name: ${_nameController.value.text}');
                                    } on PostgrestException catch (e) {
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    } on ResendException catch (e) {
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    } on Exception catch (e) {
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    }
                                    _closeDialog();
                                    await showDialog<void>(
                                        useSafeArea: true,
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (BuildContext context) {
                                          return const Center(
                                            child: AlertDialog(
                                              content: SizedBox(
                                                height: 250,
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Thanks!\n\nYour submission has been sent for review!",
                                                        style: TextStyle(
                                                          fontSize: 24.0,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    SizedBox(height: 64),
                                                    Text(
                                                      "(Tap anywhere outside of the dialog to close)",
                                                      style: TextStyle(
                                                        fontSize: 10.0,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    ],
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
                                      backgroundColor: Colors.red.shade400),
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
            cameraTargetBounds: CameraTargetBounds(_bounds),
            minMaxZoomPreference: const MinMaxZoomPreference(9, 21),
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:google_places_flutter_api/google_places_flutter_api.dart'
    as mapPredition;
import 'package:google_places_flutter_api/google_places_flutter_api.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/base_model.dart';
import '../../../api/server_error.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/common_response.dart';

class AddLocation extends StatefulWidget {
  final double? currentLat;
  final double? currentLong;

  AddLocation({this.currentLat, this.currentLong});

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  bool loading = false;

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  String address = "";
  double selectLat = 0.0;
  double selectLang = 0.0;

  double? liveLat = 0.0;
  double? liveLang = 0.0;

  LatLng? _initialCameraPosition;
  GoogleMapController? _controller;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;

  TextEditingController _textFullAddress = new TextEditingController();
  TextEditingController _textAddressLabel = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('address services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('address permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'address permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();

    if (widget.currentLat != null && widget.currentLong != null)
      _initialCameraPosition = LatLng(widget.currentLat!, widget.currentLong!);
    _determinePosition();
  }

  void _onMapCreated(GoogleMapController _cnTlr) {
    _controller = _cnTlr;
  }

  Set<Marker> _createMarker() {
    if (widget.currentLat != null && widget.currentLong != null) {
      return <Marker>{
        Marker(
          markerId: MarkerId("marker_1"),
          position: LatLng(widget.currentLat!, widget.currentLong!),
          icon: _markerIcon,
        ),
      };
    } else {
      return <Marker>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          inAsyncCall: loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: Palette.primary,
            size: 3.h,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    GoogleMap(
                      myLocationEnabled: false,
                      markers: _createMarker(),
                      mapType: MapType.satellite,
                      initialCameraPosition: CameraPosition(
                        target: _initialCameraPosition ??
                            LatLng(9.161263189006533, 77.83093579245781),
                        zoom: 18,
                      ),
                      onMapCreated: _onMapCreated,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      child: Container(
                        height: 7.w,
                        width: 7.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Palette.lightGrey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                        padding: EdgeInsets.only(left: 1.5.w),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 6.w,
                              color: Palette.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Prediction? p = await mapPredition
                                      .PlacesAutocomplete.show(
                                    context: context,
                                    mode: Mode.overlay,
                                    apiKey: Preferences.map_key,
                                    offset: 0,
                                    radius: 1000,
                                    types: [],
                                    strictbounds: false,
                                    components: [],
                                  );
                                  displayPrediction(p);

                                  if (p != null && p.placeId != null) {
                                    final detail = await GoogleMapsPlaces(
                                      apiKey: Preferences.map_key,
                                    ).getDetailsByPlaceId(p.placeId!);

                                    final components =
                                        detail.result.addressComponents;

                                    // Helper to extract components
                                    String getComponent(String type) {
                                      return components
                                          .firstWhere(
                                            (c) => c.types.contains(type),
                                            orElse: () => AddressComponent(
                                              longName: '',
                                              shortName: '',
                                              types: [],
                                            ),
                                          )
                                          .longName;
                                    }

                                    String city = getComponent('locality');
                                    if (city.isEmpty)
                                      city = getComponent(
                                        'sublocality',
                                      ); // fallback
                                    String state = getComponent(
                                      'administrative_area_level_1',
                                    );
                                    String country = getComponent('country');
                                    String zip = getComponent('postal_code');

                                    String fullAddress =
                                        detail.result.formattedAddress ?? '';
                                    List<String> addressParts = fullAddress
                                        .split(',')
                                        .map((e) => e.trim())
                                        .toList();

                                    // Remove identified components
                                    addressParts.removeWhere(
                                      (part) =>
                                          part == city ||
                                          part == state ||
                                          part == country ||
                                          part == zip,
                                    );

                                    String remainingAddress = addressParts.join(
                                      ', ',
                                    );

                                    String formatted = [
                                      if (remainingAddress.isNotEmpty)
                                        remainingAddress,
                                      if (city.isNotEmpty) city,
                                      if (state.isNotEmpty) state,
                                      if (country.isNotEmpty) country,
                                      if (zip.isNotEmpty) zip,
                                    ].join(', ');

                                    setState(() {
                                      address = formatted;
                                      _textFullAddress.text = formatted;
                                    });
                                  }
                                },
                                child: Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  // height: 5.h,
                                  decoration: BoxDecoration(
                                    color: Palette.primary.withValues(
                                      alpha: .1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.all(3.w),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 1.w),
                                            child: SvgPicture.asset(
                                              'assets/icons/Map_Search.svg',
                                              width: 4.w,
                                              height: 4.w,
                                            ),
                                          ),
                                        ),
                                        if (address == "null" || address == "")
                                          TextSpan(
                                            text: "Search Location",
                                            // 'Search Location',
                                            style: TextStyle(
                                              color: Palette.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                          )
                                        else
                                          TextSpan(
                                            text: '$address',
                                            style: TextStyle(
                                              color: Palette.dark_grey,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Text(
                                  "Label",
                                  // 'Attach Label',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomTextField(
                                controller: _textAddressLabel,
                                textInputType: TextInputType.streetAddress,
                                textCapitalization: TextCapitalization.words,
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(
                                //     RegExp('[a-zA-Z0-9]'),
                                //   ),
                                // ],
                                hint: 'Add label for this location',
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "Please Enter Landmark";
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Text(
                                  "House No./Flat No./Floor/Building",
                                  // 'House No./Flat No./Floor/Building',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              CustomTextField(
                                minLines: 5,
                                controller: _textFullAddress,
                                textInputType: TextInputType.streetAddress,
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(
                                //     RegExp('[a-zA-Z0-9,]'),
                                //   ),
                                // ],
                                maxLines: 5,
                                hint: 'Type full address here',
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "Please Select Address";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 2.h),
                              Center(
                                child: SizedBox(
                                  width: 85.w,
                                  child: FilledButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        Palette.primary,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        if (selectLat != 0.0 &&
                                            selectLang != 0.0) {
                                          callApiAddAddress();
                                        } else {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Please Search Address & Select",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Palette.red,
                                            textColor: Palette.white,
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Add Address",
                                      style: TextStyle(
                                        color: Palette.white,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction? p) async {
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: Preferences.map_key,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );

      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        p.placeId!,
      );

      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;

      selectLang = double.parse('$lng');
      selectLat = double.parse('$lat');

      setState(() {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(selectLat, selectLang), zoom: 18),
          ),
        );
        _initialCameraPosition = LatLng(selectLat, selectLang);
        _createMarker();
      });
    }
  }

  Future<BaseModel<CommonResponse>> callApiAddAddress() async {
    CommonResponse response;
    Map<String, dynamic> body = {
      "address": _textFullAddress.text,
      "label": _textAddressLabel.text,
      "lat": '$selectLat',
      "lang": '$selectLang',
    };
    try {
      response = await RestClient(
        await RetroApi().dioData(context),
      ).addAddressRequest(body);
      if (response.success == true) {
        setState(() {
          Fluttertoast.showToast(
            msg: "Successfully address address!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.green,
            textColor: Palette.white,
          );
          Navigator.pop(context);
        });
      }
    } catch (error, stacktrace) {
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

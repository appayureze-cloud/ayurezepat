import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/model/v2/common_response.dart';
import 'package:doctro_patient/model/v2/show_address_model.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../api/base_model.dart';
import '../../../api/server_error.dart';
import '../../../const/Palette.dart';
import '../../utils/form_helper.dart';
import 'add_address.dart';

class AddressList extends StatefulWidget {
  @override
  _AddressListState createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  List<Address> showAddress = [];

  bool loading = false;

  int id = 0;

  int? addressId = 0;

  late LocationData _locationData;
  Location location = new Location();

  double currentLat = 0.0;
  double currentLong = 0.0;

  @override
  void initState() {
    super.initState();
    callApiShowAddress();
    getIsWhere();
  }

  getIsWhere() async {
    _locationData = await location.getLocation();
    currentLat = _locationData.latitude!;
    currentLong = _locationData.longitude!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header_v2(
                title: "Manage Your Locations",
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddLocation(
                              currentLong: currentLong, currentLat: currentLat),
                        ),
                      ).then((_) {
                        callApiShowAddress();
                      });
                    },
                    icon: Icon(
                      Icons.add_box_outlined,
                      size: 18.sp,
                      color: Palette.primary,
                    ),
                  ),
                ],
              ),
              showAddress.length != 0
                  ? Column(
                      children: [
                        ...List.generate(showAddress.length, (index) {
                          addressId = showAddress[index].id;
                          return InkWell(
                            onTap: () {},
                            child: Card(
                              child: Column(
                                children: [
                                  SizedBox(height: 1.h),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.topLeft,
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            size: 5.w,
                                            color: Palette.primary,
                                          ),
                                        ),
                                        Container(
                                          width: 70.w,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              showAddress[index].label != null
                                                  ? Text(
                                                      showAddress[index].label!,
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Palette.primary,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Label",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Palette.primary,
                                                      ),
                                                    ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                showAddress[index].address!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Palette.dark_grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: IconButton(
                                            onPressed: () {
                                              FormHelper.showMessage(
                                                context,
                                                "Remove Address",
                                                "Are your sure to remove this address?",
                                                "No",
                                                () {
                                                  Navigator.of(context).pop();
                                                },
                                                buttonText2: "Yes",
                                                isConfirmationDialog: true,
                                                onPressed2: () {
                                                  callApiForDeleteAddress(
                                                      showAddress[index].id);
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            },
                                            icon: Icon(
                                              Icons.dangerous,
                                              size: 2.h,
                                              color: Palette.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    )
                  : NoDataWidget(),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<AddressListResponse>> callApiShowAddress() async {
    AddressListResponse response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(await RetroApi().dioData(context))
          .showAddressRequest();
      showAddress.clear();

      if (response.success == true) {
        setState(() {
          loading = false;
          showAddress.addAll(response.data!);
        });
        if (showAddress.length == 0) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('Address', "");
        }
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<CommonResponse>> callApiForDeleteAddress(addressId) async {
    CommonResponse response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(await RetroApi().dioData(context))
          .deleteAddressRequest(addressId);
      if (response.success == true) {
        setState(() {
          loading = false;
          Fluttertoast.showToast(
            msg: response.msg!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.primary,
            textColor: Palette.white,
          );
          callApiShowAddress();
        });
      }
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

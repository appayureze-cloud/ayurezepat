import 'dart:async';

import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/model/v2/common_response.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../const/prefConstatnt.dart';
import '../../utils/logger.dart';

class CartController {
  Timer? _debounceTimer;

  Future<bool> addToCart(
      {required int productId,
      required int quantity,
      required double price,
      required BuildContext context,
      required int variantId,
      required bool isRemove}) async {
    try {
      CommonResponse response =
          await RestClient(await RetroApi().dioData(context)).addtocart({
        "product_id": productId,
        "variant_id": variantId,
        "quantity": quantity,
        "price": price,
        'remove': isRemove,
      });
      Fluttertoast.showToast(
        msg: "${response.msg}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return response.success == true;
    } catch (error, stacktrace) {
      logger.e("Exception occur: $error stackTrace: $stacktrace");
    }
    return false;
  }

  Future<bool> updateCartDebounced({
    required int productId,
    required int quantity,
    required double price,
    required BuildContext context,
    required int variantId,
    required bool isRemove,
  }) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Create a completer to return a Future<bool>
    final completer = Completer<bool>();

    // Start the debounce timer
    _debounceTimer = Timer(Duration(milliseconds: 800), () async {
      try {
        Preferences.onLoading(context);

        // Await the API call
        bool result = await addToCart(
          productId: productId,
          variantId: variantId,
          quantity: quantity,
          price: price,
          context: context,
          isRemove: isRemove,
        );

        Preferences.hideDialog(context);
        completer.complete(result);
      } catch (e) {
        Preferences.hideDialog(context);
        completer.complete(false); // Fallback false on error
      }
    });

    return completer.future;
  }
}

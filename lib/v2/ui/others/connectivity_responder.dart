import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart'; // import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class ConnectivityResponder extends StatefulHookWidget {
  final Widget child;
  final BuildContext childContext;

  ConnectivityResponder(
      {required this.child, required this.childContext, Key? key})
      : super(key: key);

  @override
  State<ConnectivityResponder> createState() => _ConnectivityResponderState();
}

class _ConnectivityResponderState extends State<ConnectivityResponder>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _ocontroller;

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = AnimationController(
        vsync: this,
        lowerBound: 0.5,
        duration: Duration(seconds: 2),
      )..repeat();
      _ocontroller = AnimationController(
        vsync: this,
        lowerBound: 0.5,
        duration: Duration(seconds: 2),
      )..repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ocontroller.dispose();
    super.dispose();
  }

  bool _hasInternet(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        return false;
      case ConnectivityResult.mobile:
        return true;
      case ConnectivityResult.wifi:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      body: _hasInternet(Provider.of<ConnectivityResult>(widget.childContext))
          ? widget.child
          : AnimatedBuilder(
              animation: CurvedAnimation(
                  parent: _controller, curve: Curves.fastOutSlowIn),
              builder: (context, child) {
                return Column(
                  children: [
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: 100.w,
                      height: 45.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          _buildContainer(150 * _controller.value),
                          _buildContainer(200 * _controller.value),
                          _buildContainer(250 * _controller.value),
                          _buildContainer(300 * _controller.value),
                          _buildContainer(350 * _controller.value),
                          CircleAvatar(
                            radius: 50.sp,
                            backgroundColor: Palette.primary.withOpacity(0.7),
                            child: Icon(
                              Icons.wifi_off,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'No Internet Connection',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  color: Palette.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
                                ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Please check your Internet Connection & Try Again !',
                            style: TextStyle(
                              color: Palette.primary,
                              fontWeight: FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Palette.primary.withOpacity(1 - _controller.value),
      ),
    );
  }
}

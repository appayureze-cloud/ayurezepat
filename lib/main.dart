import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:doctro_patient/FirebaseProviders/auth_provider.dart'
    as authProvider;
import 'package:doctro_patient/FirebaseProviders/chat_provider.dart';
import 'package:doctro_patient/FirebaseProviders/home_provider.dart';
import 'package:doctro_patient/FirebaseProviders/setting_provider.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/v2/ui/address/add_address.dart';
import 'package:doctro_patient/v2/ui/address/address_list.dart';
import 'package:doctro_patient/v2/ui/authentication/change_password.dart'
    show ChangePassword;
import 'package:doctro_patient/v2/ui/authentication/forgot_password.dart';
import 'package:doctro_patient/v2/ui/authentication/login.dart';
import 'package:doctro_patient/v2/ui/authentication/otp_verification.dart';
import 'package:doctro_patient/v2/ui/authentication/register.dart';
import 'package:doctro_patient/v2/ui/authentication/splash_screen.dart';
import 'package:doctro_patient/v2/ui/home/landing_screen.dart';
import 'package:doctro_patient/v2/ui/medicine/cart.dart';
import 'package:doctro_patient/v2/ui/medicine/checkout.dart';
import 'package:doctro_patient/v2/ui/medicine/landing_screen.dart';
import 'package:doctro_patient/v2/ui/others/blog_list.dart' show BlogsList;
import 'package:doctro_patient/v2/ui/others/notifications.dart';
import 'package:doctro_patient/v2/ui/therapy/landing_screen.dart';
import 'package:doctro_patient/v2/utils/helper.dart' show NotificationHandler;
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'Chat/chatPage.dart';
import 'VideoCall/overlay_handler.dart';
import 'VideoCall/videoCall.dart';
import 'const/Palette.dart';
import 'const/prefConstatnt.dart';
import 'firebase_options.dart';
import 'api/retrofit_Api.dart';
import 'features/astra/data/astra_service.dart';
import 'features/astra/presentation/daily_checkin_screen.dart';
import 'features/case/presentation/case_summary_screen.dart';
import 'features/health_records/presentation/health_record_timeline_screen.dart';
import 'features/medicine_reminders/presentation/medicine_reminder_service.dart';
import 'features/prescriptions/presentation/dose_reminder_scheduler.dart';
import 'features/smart_orders/presentation/smart_order_draft_screen.dart';
import 'features/whatsapp_consent/presentation/whatsapp_opt_in_screen.dart';
import 'v2/ui/authentication/edit_profile.dart';
import 'v2/ui/medicine/order_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Off in debug so local development noise never reaches the crash
  // dashboard; on everywhere else so real crashes are visible before
  // launch, not discovered from user reports.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await SharedPreferenceHelper.init();
  // Needed for zonedSchedule (used by the smart order draft 24h re-prompt
  // and Phase 3's dose reminders).
  tz.initializeTimeZones();
  await FirebaseMessaging.instance.subscribeToTopic("all");
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  showBadge: true,
  playSound: true,
  enableVibration: true,
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

// static void setLocale(BuildContext context, Locale newLocale) {
//   final _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
//   state.setLocale(newLocale);
// }
}

class _MyAppState extends State<MyApp> {
  // Locale? _locale;
  String? deviceToken = "";
  late SharedPreferences _prefs;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // void setLocale(Locale locale) {
  //   setState(() {
  //     _locale = locale;
  //   });
  // }

  String msgId = "";
  String msgName = "";
  String msgImage = "";
  String doctorToken = "";
  String token = "";
  bool? router;

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await init();
    Future.delayed(const Duration(seconds: 2), () {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          final Map<String, dynamic> dataValue = message.data;
          msgImage = dataValue['doctorImage'].toString();
          msgName = dataValue['doctorName'].toString();
          msgId = dataValue['doctorId'].toString();
          doctorToken = dataValue['doctorToken'].toString();
          if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) ==
              true) {
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => ChatPage(
                peerId: msgId,
                peerAvatar: msgImage,
                peerNickname: msgName,
                doctorToken: doctorToken,
                where: "",
              ),
            ));
          } else {
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => Login(),
            ));
          }
        }
      });

      NotificationHandler.notificationResponse.addListener(() {
        final response = NotificationHandler.notificationResponse.value;
        if (response != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processNotificationResponse(response);
          });
          NotificationHandler.notificationResponse.value = null;
        }
      });
    });

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;
      final Map<String, dynamic> dataValue = message.data;
      final String screen = dataValue['screen'].toString();
      msgImage = dataValue['doctorImage'].toString();
      msgName = dataValue['doctorName'].toString();
      msgId = dataValue['doctorId'].toString();
      doctorToken = dataValue['doctorToken'].toString();

      if (notification != null && android != null) {
        logger.i(notification.toMap());
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: "@mipmap/ic_launcher",
              importance: Importance.max,
              priority: Priority.high,
              actions:
                  (notification.title?.toLowerCase().contains('incoming') ??
                          false)
                      ? <AndroidNotificationAction>[
                          AndroidNotificationAction(
                            'accept_action',
                            'Accept',
                            showsUserInterface: true,
                            cancelNotification: true,
                          ),
                          AndroidNotificationAction(
                            'decline_action',
                            'Decline',
                            showsUserInterface: true,
                            cancelNotification: true,
                          ),
                        ]
                      : null,
            ),
          ),
          payload: jsonEncode({
            ...message.data,
            'title': notification.title,
            'body': notification.body,
            'screen': screen,
          }),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logger.i('Notification opened (body tap)');
    });
    /*FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Map<String, dynamic> data = message.data;
      logger.e(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$data'),
          duration: Duration(seconds: 10),
        ),
      );
      String? actionId = data['actionId'];
      String? doctorId = data['id'];

      if (actionId == "decline_action") {
        if (doctorId != null)
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => VideoCall(
                doctorId: int.tryParse('$doctorId'),
                flag: "Cut",
              ),
            ),
          );
      }
      else if (actionId == "accept_action") {
        logger.i('accept id = $doctorId');
        if (doctorId != null)
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => VideoCall(
                doctorId: int.parse('${doctorId}'),
                flag: "InComming",
              ),
            ),
          );
      }
      // else {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => PhoneScreen(data),
      //     ),
      //   );
      // }

      // final RemoteNotification? notification = message.notification;
      // final AndroidNotification? android = message.notification?.android;
      // if (notification != null && android != null) {
      //   Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (context) => ChatPage(
      //       peerId: msgId,
      //       peerAvatar: msgImage,
      //       peerNickname: msgName,
      //       doctorToken: doctorToken,
      //       where: "",
      //     ),
      //   ));
      // }
    });*/
    if (Platform.isAndroid) {
      final permission = await Permission.notification.request();
      if (permission.isGranted) {
        // print('Notification permission granted');
      }
    }
  }

  void _processNotificationResponse(NotificationResponse response) async {
    final actionId = response.actionId;
    final payload = jsonDecode(response.payload ?? '{}');

    final doctorId = payload['id'];
    final screen = payload['screen'];

    if (actionId == 'accept_action' && doctorId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => VideoCall(
            doctorId: int.parse('$doctorId'),
            flag: "InComming",
          ),
        ),
      );
      return;
    }

    if (actionId == 'decline_action' && doctorId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => VideoCall(
            doctorId: int.tryParse('$doctorId'),
            flag: "Cut",
          ),
        ),
      );
      return;
    }

    // Notification body tap (no actionId)
    if (actionId == null && screen == 'chat') {
      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              peerId: payload['doctorId'],
              peerAvatar: payload['doctorImage'],
              peerNickname: payload['doctorName'],
              doctorToken: payload['doctorToken'],
              where: "",
            ),
          ),
        );
      }
      return;
    }

    // Astra's smart order draft prompt/re-prompt (Phase 2) - see
    // docs/backend/smart-orders.md and
    // lib/features/smart_orders/presentation/smart_order_reprompt_scheduler.dart.
    if (actionId == null && screen == 'smart_order_draft') {
      final draftId = payload['draft_id'];
      if (draftId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SmartOrderDraftScreen(draftId: '$draftId'),
          ),
        );
      }
      return;
    }

    // Shipment status change (Phase 2) - see docs/backend/shipments.md.
    if (actionId == null && screen == 'order_tracking') {
      final orderId = int.tryParse('${payload['order_id']}');
      if (orderId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => OrderDetails(id: orderId),
          ),
        );
      }
      return;
    }

    // Dose reminder actions (Phase 3) - see
    // lib/features/prescriptions/presentation/dose_reminder_scheduler.dart
    // and docs/backend/astra.md.
    if (screen == 'reminder_ack') {
      final reminderId = payload['reminder_id'];
      if (reminderId == null) return;
      final status = switch (actionId) {
        'reminder_taken' => 'taken',
        'reminder_skip' => 'skipped',
        'reminder_snooze' => 'snoozed',
        _ => null,
      };
      if (status == null) return;
      try {
        final dio = await RetroApi().dioData(context);
        await AstraService.withDio(dio)
            .repository
            .ackReminder('$reminderId', status);
      } catch (e) {
        logger.e('Failed to ack reminder: $e');
      }
      // Best-effort: also log adherence against the real server-side
      // reminder for this medicine, if one was registered when the local
      // reminders were scheduled (see dose_reminder_scheduler.dart).
      final serverReminderId = serverReminderIdFor('$reminderId');
      if (serverReminderId != null) {
        try {
          final reminderService = MedicineReminderService.create();
          if (actionId == 'reminder_snooze') {
            await reminderService.snooze(reminderId: serverReminderId);
          } else {
            await reminderService.logAdherence(
              reminderId: serverReminderId,
              taken: actionId == 'reminder_taken',
            );
          }
        } catch (e) {
          logger.e('Failed to sync reminder adherence to server: $e');
        }
      }
      if (actionId == 'reminder_snooze') {
        await snoozeReminder(
          '$reminderId',
          payload['title'] ?? 'Medicine reminder',
          payload['body'] ?? '',
        );
      }
      return;
    }

    // Daily check-in reminder (Phase 3) - see
    // lib/features/astra/presentation/daily_checkin_reminder_scheduler.dart.
    if (actionId == null && screen == 'daily_checkin') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const DailyCheckinScreen()),
      );
      return;
    }
  }

  Future<void> onSelectNotification(NotificationResponse payload) async {
    if (payload.payload == null) return;
    NotificationHandler.handle(payload);
    logger.w('Inside payload ${jsonDecode('${payload.payload}')}');
    logger.w('Inside ${payload.input}');
    logger.w('Inside ${payload.actionId}');
    logger.w('Inside ${payload.id}');
    logger.w('Inside ${payload.notificationResponseType.name}');
  }

  Future<SharedPreferences?> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  // @override
  // void didChangeDependencies() {
  // getLocale().then((local) {
  //   setState(() {
  //     _locale = local;
  //   });
  // });
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // if (_locale == null) {
    //   return Container(
    //     child: Center(child: CircularProgressIndicator()),
    //   );
    // } else {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MultiProvider(
        providers: [
          StreamProvider(
            create: (BuildContext context) =>
                Connectivity().onConnectivityChanged,
            initialData: ConnectivityResult.mobile,
          ),
          // ChangeNotifierProvider<MedicinesStripePayment>(
          //   create: (context) => MedicinesStripePayment(),
          // ),
          ChangeNotifierProvider<authProvider.AuthProvider>(
            create: (_) => authProvider.AuthProvider(
              firebaseAuth: FirebaseAuth.instance,
              googleSignIn: GoogleSignIn(),
              prefs: this._prefs,
              firebaseFirestore: this.firebaseFirestore,
            ),
          ),
          Provider<SettingProvider>(
            create: (_) => SettingProvider(
              prefs: this._prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage,
            ),
          ),
          Provider<HomeProvider>(
            create: (_) => HomeProvider(
              firebaseFirestore: this.firebaseFirestore,
            ),
          ),
          Provider<ChatProvider>(
            create: (_) => ChatProvider(
              prefs: this._prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage,
            ),
          ),
          ChangeNotifierProvider<OverlayHandlerProvider>(
            create: (_) => OverlayHandlerProvider(),
          ),
        ],
        child: Sizer(
          builder: (context, _, __) => MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Patient',
            // locale: _locale,
            // supportedLocales: [Locale(ENGLISH, 'US')],
            // localizationsDelegates: [
            //   LanguageLocalization.delegate,
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            // ],
            // localeResolutionCallback: (deviceLocale, supportedLocales) {
            //   for (var local in supportedLocales) {
            //     if (local.languageCode == deviceLocale?.languageCode &&
            //         local.countryCode == deviceLocale?.countryCode) {
            //       return deviceLocale;
            //     }
            //   }
            //   return supportedLocales.first;
            // },
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            theme: ThemeData(
              useMaterial3: false,
              primaryColor: Palette.primary,
              splashColor: Palette.transparent,
              highlightColor: Palette.transparent,
              colorScheme: ColorScheme.light(
                primary: Palette.primary,
                // 👈 Affects date picker header, selected date, etc.
                onPrimary: Palette.white,
                // 👈 Text color on selected header
                onSurface: Palette.dark_blue, // 👈 Normal text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor:
                      Palette.primary, // 👈 Affects "Cancel" and "OK" buttons
                ),
              ),
              tabBarTheme: TabBarThemeData(
                labelColor: Palette.primary,
                unselectedLabelColor: Palette.grey,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Palette.primary, width: 2),
                ),
              ),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Palette.primary,
                selectionColor: Palette.primary.withOpacity(0.4),
                selectionHandleColor: Palette.primary,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.primary,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                prefixIconColor: Palette.primary,
                filled: false,
                suffixIconColor: Palette.primary,
                iconColor: Palette.primary,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(color: Palette.primary, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(color: Palette.grey, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(color: Palette.grey, width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(color: Palette.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(color: Palette.red, width: 1),
                ),
                labelStyle: TextStyle(color: Palette.primary),
                floatingLabelStyle: TextStyle(color: Palette.primary),
              ),
              dialogTheme: DialogThemeData(backgroundColor: Palette.white),
            ),
            routes: {
              '/': (context) => SplashScreen(),
              'SignUp': (context) => Register(),
              'ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
              'ChangePassword': (context) => ChangePassword(),
              'SignIn': (context) => Login(),
              'PhoneVerification': (context) => OTPVerification(),
              'EditProfile': (context) => EditProfile(),
              'MedicineHome': (context) => MedicineLandingPage(),
              'Blogs': (context) => BlogsList(),
              'AddressList': (context) => AddressList(),
              'Notifications': (context) => Notifications(),
              'WhatsAppOptIn': (context) => const WhatsappOptInScreen(),
              'CaseSummary': (context) => const CaseSummaryScreen(),
              'HealthRecord': (context) => const HealthRecordTimelineScreen(),

              'Home': (context) => MainLandingPage(),
              // 'Home22': (context) => MedicineLandingPage(),
              // 'AppointmentDetail': (context) =>
              //     AppointmentDetails(showPayment: false),
              // 'MakeAppointment': (context) => MakeAppointment(),
              // 'ConfirmAppointmentDetails': (context) => AppointmentDetails(),
              // 'SelectPaymentMethods': (context) => SelectPaymentMethods(),
              'Cart': (context) => Cart(),
              'Checkout': (context) => Checkout(),
              'TherapyHome': (context) => TherapyLandingPage(),
              // 'MedicineDetails': (context) => MedicineDetailsScreen(),
              // 'OrderDetails': (context) => OrderDetails(),
              'Profile': (context) => EditProfile(),
              'AddLocation': (context) => AddLocation(),
            },
          ),
        ),
      ),
    );
    // }
  }
}

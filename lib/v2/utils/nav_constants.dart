/// Bottom-nav tab index for Doctors on MainLandingPage
/// (lib/v2/ui/home/landing_screen.dart), shared with call sites elsewhere
/// that deep link into it (e.g. tapping a category card from Home) via
/// `Navigator.pushNamed(context, 'Home', arguments: [doctorsTabIndex, ...])`.
const int doctorsTabIndex = 2;

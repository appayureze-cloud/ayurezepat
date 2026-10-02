# Auth: Firebase custom token migration

## Why

The client used to receive raw Firebase `id_token`/`refresh_token` pairs
from `login` and `check_otp` and refresh them itself by calling
`securetoken.googleapis.com` directly with a hardcoded Google API key
embedded in the app binary. That key has been removed from the client as
part of Phase 0. The client can no longer refresh those raw tokens itself -
the Firebase client SDKs have no supported way to "import" an externally
issued id/refresh token pair into a local session.

The client now only trusts tokens obtained through the FirebaseAuth SDK
(`FirebaseAuth.instance.currentUser?.getIdToken()`), which the SDK
refreshes internally. Google Sign-In already gets this for free because it
calls `firebaseAuth.signInWithCredential(...)`. Phone/OTP and email/password
login do not yet, because they never establish a client-side FirebaseAuth
session.

## Required backend change

For `POST /login` and `POST /check_otp` (and any other endpoint that
authenticates a user session), replace the response fields:

```
- token
- refresh_token
- expires_in
```

with:

```
+ firebase_custom_token   // string, from Admin SDK auth().createCustomToken(uid)
```

Server-side, after validating the password/OTP, call the Firebase Admin SDK:

```php
$customToken = $auth->createCustomToken($firebaseUid);
```

`$firebaseUid` should be a stable per-user UID you already mint/store (e.g.
same UID space used for Firestore chat documents today).

## Client behavior after the change

1. Client calls `login`/`check_otp` as before.
2. Client calls `FirebaseAuth.instance.signInWithCustomToken(firebaseCustomToken)`.
3. Client calls `currentUser.getIdToken()` for the `Authorization: Bearer` header
   on all subsequent API calls; `RetroApi` in `lib/api/retrofit_Api.dart`
   already prefers a live FirebaseAuth session over the legacy stored token.
4. No refresh token is ever stored or transmitted by the client.

## Backend validation of the resulting ID token

Endpoints should verify the incoming Firebase ID token with the Admin SDK
(`auth()->verifyIdToken($token)`) rather than trusting an opaque bearer
token from your own token store, if not already doing so.

## Rollout / compatibility

Until this ships, phone/email/password login still works via the legacy
path (`token` stored and sent as a bearer header) but will not auto-refresh;
users on that path get logged out on expiry and have to sign in again. This
is intentional - it's the safe trade-off for removing the hardcoded refresh
key immediately rather than waiting on this backend change.

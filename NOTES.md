# NOTES FOR FORKING NFT PUZZLE FUN
#### fork the repo
```
npm install firebase
npm install -g firebase-tools
firebase login
firebase init
firebase deploy
dart pub global activate flutterfire_cli
flutterfire configure
```

#### find replace package:very_good_slide_puzzle with package:[mypackagename]

https://firebase.flutter.dev/docs/overview/

Make sure and set the current android sdk in android studio project settings: https://stackoverflow.com/questions/56938436/first-flutter-app-error-cannot-resolve-symbol-properties

```
firebase deploy --only hosting
```


## copy in private configs:
```
 cp ../nftpuzzlefun_with_keys_PRIVATE/android/app/google-services.json android/app/
 cp ../nftpuzzlefun_with_keys_PRIVATE/ios/Runner/GoogleService-Info.plist ios/Runner/
 cp ../nftpuzzlefun_with_keys_PRIVATE/macos/Runner/GoogleService-Info.plist macos/Runner/
 cp ../nftpuzzlefun_with_keys_PRIVATE/lib/firebase_options.dart lib/
 cp -R ../nftpuzzlefun_with_keys_PRIVATE/.firebase .firebase
 cp ../nftpuzzlefun_with_keys_PRIVATE/nftpuzzlefun.jks .
 cp ../nftpuzzlefun_with_keys_PRIVATE/android/key.properties android/
 cp -i ../nftpuzzlefun_with_keys_PRIVATE/packages/opensea_repository/lib/src/api_key.dart packages/opensea_repository/lib/src/
```

# Install packages recursively (shorthand)
```very_good packages get -r```

## DESIGN
- only pull nft from api once. the id and the image will never change so we can just cache it in firebase
- the exception is watching collections will need to be updated all the time. we might need to run a cronjob on ec2 for that, or on blondie if it doesn't need a webhook

## recreate firebase_options:
```
flutterfire.bat configure
```

## builder command
```
flutter packages pub run build_runner build
```

## run unit tests
```
flutter test --coverage
```

# localization builder command
```
flutter gen-l10n
```

#### Flutter run web debugger on specific port to allow google auth to work:
#### NOTE: You can just use port 5000 on localhost for web since that is in oauth already by default. I just chose a different port so it doesn't conflict with other open and running projects
https://console.cloud.google.com/apis/credentials (add http://localhost:58149 and others in OAuth 2.0 Web application client)
- https://nftpuzzlefun.web.app
- http://localhost:58149
- https://nftpuzzlefun.com
```
flutter run -d chrome --web-hostname localhost --web-port 58149
```
OR:
```
flutter run -d headless-server --web-hostname localhost --web-port 58149
```
https://stackoverflow.com/questions/58248277/how-to-specify-a-port-number-while-running-flutter-web

## gsutil is required to set up CORS config for firebase storage:
https://cloud.google.com/storage/docs/gsutil_install
```gsutil cors set firebase_storage_cors_config/cors.json gs://nftpuzzlefun.appspot.com```

## add specific web port to android studio run config:
Edit the run config "default" and any others
```--web-port 58149```
under "additional run args"
then make sure to add this to google developer console - have to write up some instructions on this one, but not needed for CORS/storage only needed for firebase auth

## keystore
```
/c/Program\ Files/Android/Android\ Studio/jre/bin/keytool.exe -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
#### Copy sha1 and sha256 to firebase android app config
#### elso copy to google developer console https://console.cloud.google.com/iam-admin/iam?authuser=1&project=nftpuzzlefun

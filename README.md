# Amity UIKit for Flutter[Beta Service]

Amity UIkit opensource developed by SLE team to enable social feature in Flutter.

## Usage
Example main.dart

```dart

void main() async {
  ///Step 1: Initialize amity SDK with the following function
  WidgetsFlutterBinding.ensureInitialized();
  AmitySLEUIKit()
      .initUIKit("<API_KEY>", "REGION<sg,eu,us>");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///Step2: Wrap Material App with AmitySLEProvider and Builder
    return AmitySLEProvider(
      child: Builder(builder: (context2) {
        ///If you want to change color of uikit use the following metgod here
        AmitySLEUIKit().configAmityThemeColor(context2, (config) {
          config.primaryColor = Colors.green;
          config.messageRoomConfig.backgroundColor = Colors.green;
        });
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: InitialWidget(),
        );
      }),
    );
  }
}

class InitialWidget extends StatelessWidget {
  const InitialWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ///Step 3: login with Amity
                  AmitySLEUIKit().registerDevice(context, "<UserId>");
                },
                child: const Text("Login to Amity"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ///Step 4: Navigate To chat Room page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AmitySLEChannelScreen(),
                  ));
                },
                child: const Text("Navigate to UIKIT: Channel List page"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ///Step 4.1: Navigate To channel List page
                  AmitySLEUIKit.openChatRoomPage(context, "<Channel_ID>");
                },
                child: const Text("Navigate to UIKIT: Chat room page"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

```

## Note

For Android
Please enable multiDexEnabled in android/app/build.gradle

```
    defaultConfig {
        multiDexEnabled true

    }

```




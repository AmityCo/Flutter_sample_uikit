// import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
// import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
// import 'package:amity_uikit_beta_service/view/chat/chat_friend_tab.dart';
// import 'package:amity_uikit_beta_service/view/chat/single_chat_room.dart';
// import 'package:amity_uikit_beta_service/view/social/global_feed.dart';

// import 'package:flutter/material.dart';

// void main() async {
//   ///Step 1: Initialize amity SDK with the following function
//   WidgetsFlutterBinding.ensureInitialized();
//   AmitySLEUIKit()
//       .initUIKit("b3babb0b3a89f4341d31dc1a01091edcd70f8de7b23d697f", "sg");

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AmitySLEProvider(
//       child: Builder(builder: (context2) {
//         AmitySLEUIKit().configAmityThemeColor(context2, (config) {
//           config.primaryColor = Colors.blue;
//         });
//         return MaterialApp(
//           navigatorKey: navigatorKey, // Use the same navigatorKey
//           title: 'Flutter Demo',
//           theme: ThemeData(
//             primarySwatch: Colors.blue,
//           ),
//           home: const InitialWidget(),
//         );
//       }),
//     );
//   }
// }

// class InitialWidget extends StatelessWidget {
//   const InitialWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   ///Step 3: login with Amity
//                   AmitySLEUIKit()
//                       .registerDevice(context: context, userId: "johnwick6");
//                 },
//                 child: const Text("Login to Amity"),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   ///Step 4: Navigate To channel List page
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => const AmitySLEChannelScreen(),
//                   ));
//                 },
//                 child: const Text("Navigate to UIKIT: Channel List page"),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () async {
//                   ///4.1: Navigate To channel chat screen page with ChannelId

//                   await Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => const SingleChatRoom(
//                       channelId: "Flutter_Flutter",
//                     ),
//                   ));
//                 },
//                 child: const Text("Navigate to UIKIT: Chat room page"),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   ///4.e: Navigate To Global Feed Screen
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) =>
//                         const Scaffold(body: GlobalFeedScreen()),
//                   ));
//                 },
//                 child: const Text("Navigate to UIKIT: Global Feed"),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ///Step 1: Initialize amity SDK with the following function
  WidgetsFlutterBinding.ensureInitialized();
  AmitySLEUIKit()
      .initUIKit("b3babb0b3a89f4341d31dc1a01091edcd70f8de7b23d697f", "sg");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return AmitySLEProvider(
      child: Builder(builder: (context2) {
        AmitySLEUIKit().configAmityThemeColor(context2, (config) {
          config.primaryColor = Colors.blue;
        });
        return MaterialApp(
          navigatorKey: navigatorKey, // Use the same navigatorKey
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: UserListPage(),
          routes: {
            '/second': (context) => SecondPage(),
            '/third': (context) => ThirdPage(),
          },
        );
      }),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<String> _usernames = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsernames();
  }

  _loadUsernames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernames = prefs.getStringList('usernames') ?? [];
    });
  }

  _addUsername() async {
    if (_controller.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _usernames.add(_controller.text);
      prefs.setStringList('usernames', _usernames);
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addUsername,
            child: Text('Add Username'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _usernames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_usernames[index]),
                  onTap: () {
                    ///Step 3: login with Amity
                    AmitySLEUIKit().registerDevice(
                        context: context, userId: _usernames[index]);
                    Navigator.of(context)
                        .pushNamed('/second', arguments: _usernames[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/third',
                    arguments: {'username': username, 'feature': 'Social'});
              },
              child: Text('Social'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/third',
                    arguments: {'username': username, 'feature': 'Chat'});
              },
              child: Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final username = args['username'];
    final feature = args['feature'];

    return Scaffold(
      appBar: AppBar(
        title: Text('$feature Feature'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text('Global Feed'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const Scaffold(body: GlobalFeedScreen()),
                ));
              },
            ),
            ListTile(
              title: Text('User Profile'),
              onTap: () {
                // Navigate or perform action based on 'User Profile' tap
              },
            ),
            ListTile(
              title: Text('Newsfeed'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
              },
            ),
            ListTile(
              title: Text('Create Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const Scaffold(body: GlobalFeedScreen()),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

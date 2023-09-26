import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
import 'package:amity_uikit_beta_service/view/social/create_post_screen.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';

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
          config.primaryColor = Color(0xFF1054DE);
        });
        return MaterialApp(
          navigatorKey: navigatorKey, // Use the same navigatorKey
          title: 'Flutter Demo',

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
                  builder: (context) => Scaffold(body: CreateCommunityPage()),
                ));
              },
            ),
            ListTile(
              title: Text('Create Post'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(body: CreatePostScreen2()),
                ));
              },
            ),
            ListTile(
              title: Text('My Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(body: MyCommunityPage()),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

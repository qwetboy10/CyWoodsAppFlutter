import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'profile.dart';

class ChangeProfile extends StatefulWidget {
  State createState() => ChangeProfileState();
}

class ChangeProfileState extends State<ChangeProfile> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Profile'),
      ),
      body: FutureBuilder(
        future: Profile.getAllProfiles(),
        builder: (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            case ConnectionState.done:
              return snapshot.data == null
                  ? Center(
                      child: Text('No Accounts Found'),
                    )
                  : buildProfileList(context, snapshot.data);
          }
          return null;
        },
      ),
    );
  }

  Widget buildProfileList(BuildContext context, List<Profile> profiles) {
    Future<Profile> defaultProfile = Profile.getDefaultProfile();
    return FutureBuilder(
      future: defaultProfile,
      builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          case ConnectionState.done:
            if(profiles.length != 0)
            return ListView.separated(
              itemCount: profiles.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 1,
                  ),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: profiles[index].getUsername() ==
                          snapshot.data?.getUsername()
                      ? Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.black,
                        )
                      : null,
                  title: Text(profiles[index].getName()),
                  onTap: () {
                    buildAreYouSureDialog(context, profiles, index);
                  },
                );
              },
            );
          else return Center(child: Text('Not Logged In'));
        }
        return null;
      },
    );
  }

  Future buildAreYouSureDialog(
      BuildContext context, List<Profile> profiles, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Do You Want To Change Profiles?'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Yes',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    Profile.setDefaultProfile(profiles[index]);
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }
}

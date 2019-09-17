import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'login.dart';
import 'profile.dart';

class ChangeProfile extends StatefulWidget {
  State createState() => ChangeProfileState();
}

class ChangeProfileState extends State<ChangeProfile> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Accounts'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => setState(() {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => NotLogin(),
                            fullscreenDialog: true))
                        .then((_) => Navigator.of(context).pop());
                  }))
        ],
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
            if (profiles.length != 0)
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
                          )
                        : null,
                    title: Text(profiles[index].getName()),
                    onTap: () {
                      (profiles[index].getUsername() ==
                                  snapshot.data?.getUsername()
                              ? buildAreYouSureDeleteDialog(context, profiles, index)
                              : buildAreYouSureDialog(context, profiles, index))
                          .then((bool status) {
                        if (status != null && status == true)
                          Navigator.of(context).pop();
                      });
                    },
                  );
                },
              );
            else
              return Center(child: Text('Please Add An Account'));
        }
        return null;
      },
    );
  }

  Future<bool> buildAreYouSureDialog(
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
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          );
        });
  }
Future<bool> buildAreYouSureDeleteDialog(
      BuildContext context, List<Profile> profiles, int index) {
        return showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
            title: Text('Do You Want To Delete This Profile?'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Yes',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    Profile.deleteProfile(profiles[index]);
                  });
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ));
        
  }
  Future<bool> buildLogoutDialog(
      BuildContext context, List<Profile> profiles, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Do You Want To Logout?'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Yes',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    Profile.setDefaultProfile(null);
                  });
                  Navigator.of(context).pop(true);
                },
              ),
              FlatButton(
                child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          );
        });
  }
}

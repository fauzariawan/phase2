import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';

class NavigasiBawah {
  static navigasiBawah(BuildContext context, User user) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      // currentIndex: currentIndex,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.grey,
      // showSelectedLabels: false,
      // showUnselectedLabels: false,
      onTap: (index) {
        // timer.cancel();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LandingPage(
                user: user,
                currentIndex: index,
              ),
            ));
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Profile')
      ],
    );
  }
}

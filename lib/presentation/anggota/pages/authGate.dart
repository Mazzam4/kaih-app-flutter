import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaih_7_xirpl2/presentation/main/pages/main.dart';
import 'package:kaih_7_xirpl2/presentation/org/pages/join_organization_page.dart';
import 'package:kaih_7_xirpl2/presentation/splash/pages/splash.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }


        if (authSnapshot.hasData) {
          final user = authSnapshot.data!;

        
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnapshot) {
              

              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final data = userDocSnapshot.data!.data() as Map<String, dynamic>?;
                if (data != null && data.containsKey('organizationId') && data['organizationId'] != null) {
                  return const MainPage();
                }
              }
              
              return const JoinOrganizationPage();
            },
          );
        } else {
          return const SplashPage();
        }
      },
    );
  }
}
//test/mocks.dart

import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab4_5/services/firestore_service.dart';  // Replace with actual path
import 'package:mockito/annotations.dart';
import 'package:lab4_5/services/auth_service.dart';
import 'package:lab4_5/services/firestore_service.dart';
import 'package:lab4_5/services/analytics_service.dart';
import 'package:lab4_5/services/online_status_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lab4_5/blocs/auth/auth_bloc.dart';
import 'package:lab4_5/blocs/favorite/favorite_bloc.dart';
import 'package:lab4_5/blocs/product/product_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

@GenerateMocks([ FirebaseFirestore,
  AuthService,
  FirestoreService,
  AnalyticsService,
  OnlineStatusService,
  FirebaseAuth,
  User,
  UserCredential,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  AuthBloc,
  FavoriteBloc,
  ProductBloc,
  FirebaseAnalytics,
  DocumentSnapshot,])
void main() {}
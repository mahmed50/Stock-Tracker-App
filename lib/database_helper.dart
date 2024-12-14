import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // ------------------------- Authentication Functions -------------------------

  // Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error in signUp: $e");
      return null;
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error in signIn: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error in signOut: $e");
    }
  }

  // ------------------------- Watchlist Functions -------------------------

  // Add to Watchlist
  Future<void> addToWatchlist(String userId, String stockSymbol) async {
    try {
      await _firestore
          .collection('watchlists')
          .doc(userId)
          .collection('stocks')
          .doc(stockSymbol)
          .set({'addedAt': Timestamp.now()});
    } catch (e) {
      print("Error in addToWatchlist: $e");
    }
  }

  // Remove from Watchlist
  Future<void> removeFromWatchlist(String userId, String stockSymbol) async {
    try {
      await _firestore
          .collection('watchlists')
          .doc(userId)
          .collection('stocks')
          .doc(stockSymbol)
          .delete();
    } catch (e) {
      print("Error in removeFromWatchlist: $e");
    }
  }

  // Get Watchlist
  Future<List<String>> getWatchlist(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('watchlists')
          .doc(userId)
          .collection('stocks')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error in getWatchlist: $e");
      return [];
    }
  }

  // Watchlist Stream (Realtime Updates)
  Stream<List<String>> watchlistStream(String userId) {
    return _firestore
        .collection('watchlists')
        .doc(userId)
        .collection('stocks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}

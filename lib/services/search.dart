import 'package:algolia/algolia.dart';
import 'package:flutter/foundation.dart';

class Search with ChangeNotifier {



  static final Algolia algolia = Algolia.init(
    applicationId: 'V590KOABR9',
    apiKey: '9448bc95090e40869a1e2d91ca3f68cd',
  );

  Future<AlgoliaQuerySnapshot> testAlgo(String searchText) async {
    AlgoliaQuery query = algolia.instance.index('test_firestore').search(searchText);
    AlgoliaQuerySnapshot snap = await query.getObjects();
    //print(snap.toString());
    return snap;
  }
}
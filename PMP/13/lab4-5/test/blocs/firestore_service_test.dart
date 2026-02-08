import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:lab4_5/services/firestore_service.dart';
import 'package:lab4_5/models/product.dart';
import '../mocks.mocks.dart';

void main() {
  group('FirestoreService', () {
    late MockFirebaseFirestore mockFirestore;
    late FirestoreService service;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDoc;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDoc = MockDocumentReference();
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDoc);
      service = FirestoreService(firestore: mockFirestore);
    });

    // Test 5: Deleting a product (calls delete on Firestore)
    test('deleteProduct calls delete on the correct document', () async {
      // Mock delete to succeed
      when(mockDoc.delete()).thenAnswer((_) async => {});
      await service.deleteProduct('prod_id');
      verify(mockCollection.doc('prod_id')).called(1);
      verify(mockDoc.delete()).called(1);
    });
  });
}
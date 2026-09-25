import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/lead_item.dart';

class WebLeadFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time stream of leads directly from Firebase Firestore
  static Stream<List<LeadItem>> streamLeads() {
    return _firestore
        .collection('leads')
        .snapshots()
        .map((snapshot) {
      final List<LeadItem> items = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        items.add(LeadItem.fromFirestore(data, doc.id, i));
      }
      return items;
    });
  }

  /// Create or update a lead in Firestore
  static Future<void> saveLead(LeadItem lead) async {
    try {
      final docRef = _firestore.collection('leads').doc(lead.id);
      await docRef.set({
        ...lead.toFirestoreMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving lead to Firestore: $e');
    }
  }

  /// Update lead pipeline status
  static Future<void> updateLeadStatus(String leadId, String newStatus) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating lead status in Firestore: $e');
    }
  }

  /// Trash or restore a lead
  static Future<void> setLeadTrash(String leadId, bool isTrashed) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'isTrashed': isTrashed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error setting lead trash state in Firestore: $e');
    }
  }

  /// Bulk reassign lead to a telecaller
  static Future<void> reassignLead(String leadId, String assignedTo, String assignedToPhone) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'assignedTo': assignedTo,
        'assignedToPhone': assignedToPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reassigning lead in Firestore: $e');
    }
  }

  /// Delete lead permanently
  static Future<void> deleteLead(String leadId) async {
    try {
      await _firestore.collection('leads').doc(leadId).delete();
    } catch (e) {
      debugPrint('Error deleting lead from Firestore: $e');
    }
  }
}

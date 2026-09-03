import 'package:flutter/material.dart';

enum NavSection {
  dashboard,
  manage,
  leads,
  reports,
  settings,
  help,
}

class NavItem {
  final NavSection section;
  final String title;
  final IconData icon;
  final List<NavSubItem>? subItems;

  const NavItem({
    required this.section,
    required this.title,
    required this.icon,
    this.subItems,
  });
}

class NavSubItem {
  final String id;
  final String title;
  final IconData? icon;

  const NavSubItem({
    required this.id,
    required this.title,
    this.icon,
  });
}

class NavMenuData {
  static const List<NavSubItem> manageOptions = [
    NavSubItem(id: 'employees', title: 'Employees', icon: Icons.badge_outlined),
    NavSubItem(id: 'exclude_phone_numbers', title: 'Exclude Phone Numbers', icon: Icons.phone_disabled_outlined),
    NavSubItem(id: 'users', title: 'Users', icon: Icons.group_outlined),
    NavSubItem(id: 'call_note_templates', title: 'Call Note Templates', icon: Icons.note_alt_outlined),
    NavSubItem(id: 'message_templates', title: 'Message Templates', icon: Icons.chat_bubble_outline_rounded),
    NavSubItem(id: 'call_recordings', title: 'Call Recordings', icon: Icons.mic_none_rounded),
    NavSubItem(id: 'call_transcripts', title: 'Call Transcripts', icon: Icons.subtitles_outlined),
    NavSubItem(id: 'pinned_call_logs', title: 'Pinned Call Logs', icon: Icons.push_pin_outlined),
  ];

  static const List<NavSubItem> leadsOptions = [
    NavSubItem(id: 'my_leads', title: 'My Leads', icon: Icons.person_pin_outlined),
    NavSubItem(id: 'import_leads', title: 'Import Leads', icon: Icons.file_upload_outlined),
    NavSubItem(id: 'lead_reports', title: 'Lead Reports', icon: Icons.assessment_outlined),
    NavSubItem(id: 'status_report', title: 'Status Report', icon: Icons.pie_chart_outline_rounded),
    NavSubItem(id: 'lead_not_contacted', title: 'Lead Not Contacted', icon: Icons.phone_missed_outlined),
    NavSubItem(id: 'status_change_report', title: 'Status Change Report', icon: Icons.history_rounded),
    NavSubItem(id: 'lead_overview_report', title: 'Lead Overview Report', icon: Icons.insights_rounded),
    NavSubItem(id: 'lead_tags', title: 'Lead Tags', icon: Icons.local_offer_outlined),
    NavSubItem(id: 'lead_status', title: 'Lead Status', icon: Icons.alt_route_rounded),
    NavSubItem(id: 'form_settings', title: 'Form Settings', icon: Icons.dynamic_form_outlined),
  ];

  static const List<NavSubItem> reportsOptions = [
    NavSubItem(id: 'periodic_reports', title: 'Periodic Reports', icon: Icons.calendar_month_outlined),
    NavSubItem(id: 'never_attended', title: 'Never Attended', icon: Icons.call_missed_outgoing_rounded),
    NavSubItem(id: 'not_pickup_by_client', title: 'Not Pickup by Client', icon: Icons.ring_volume_outlined),
    NavSubItem(id: 'employee_reports', title: 'Employee Reports', icon: Icons.leaderboard_outlined),
    NavSubItem(id: 'client_reports', title: 'Client Reports', icon: Icons.corporate_fare_outlined),
  ];
}


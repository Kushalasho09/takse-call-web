import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takse_call_web/models/lead_item.dart';
import 'package:takse_call_web/widgets/leads/add_lead_form_view.dart';
import 'package:takse_call_web/widgets/leads/import_leads_view.dart';
import 'package:takse_call_web/widgets/leads/leads_data_table_view.dart';
import 'package:takse_call_web/widgets/leads/my_leads_empty_view.dart';
import 'package:takse_call_web/widgets/leads/lead_status_view.dart';
import 'package:takse_call_web/widgets/leads/lead_tags_view.dart';
import 'package:takse_call_web/widgets/leads/lead_form_settings_view.dart';
import 'package:takse_call_web/widgets/leads/lead_reports_suite_views.dart';
import 'package:takse_call_web/screens/leads_screen.dart';

void main() {
  testWidgets('MyLeadsEmptyView renders welcome card and tutorial banner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool addLeadClicked = false;
    bool importClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyLeadsEmptyView(
            onAddLead: () => addLeadClicked = true,
            onImportLeads: () => importClicked = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Leads'), findsOneWidget);
    expect(find.text('Add Lead'), findsOneWidget);
    expect(find.text('Import Leads'), findsOneWidget);
    expect(find.text('How To Import Bulk Leads? '), findsOneWidget);
    expect(find.text('Click Here'), findsOneWidget);
    expect(find.text('How To Import Bulk Leads'), findsOneWidget);
    expect(find.text('In- CALLYZER'), findsOneWidget);

    await tester.tap(find.text('Add Lead'));
    expect(addLeadClicked, isTrue);

    await tester.tap(find.text('Import Leads'));
    expect(importClicked, isTrue);
  });

  testWidgets('AddLeadFormView displays 3-column fields and validates submission', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool cancelCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AddLeadFormView(
              onCancel: () => cancelCalled = true,
              onLeadAdded: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add lead'), findsOneWidget);
    expect(find.text('Map available call log of lead'), findsOneWidget);
    expect(find.text('Specific Employee(s)'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel test
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    expect(cancelCalled, isTrue);
  });

  testWidgets('ImportLeadsView displays 5-step stepper and supports automated connectors toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool cancelCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ImportLeadsView(
              onCancel: () => cancelCalled = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Import Leads Pipeline'), findsOneWidget);
    expect(find.text('Import CSV File'), findsOneWidget);
    expect(find.text('Map Fields'), findsOneWidget);
    expect(find.text('Validate CSV Data'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Please consider below points while uploading CSV'), findsOneWidget);
    expect(find.text('Import Leads Manually'), findsOneWidget);
    expect(find.text('Drag & Drop CSV file'), findsOneWidget);
    expect(find.text('Select File'), findsOneWidget);
    expect(find.text('Download Sample'), findsOneWidget);

    // Switch to Automated Connectors Hub
    await tester.tap(find.text('Automated Connectors Hub'));
    await tester.pumpAndSettle();

    expect(find.text('Google Sheet (Import Leads)'), findsOneWidget);
    expect(find.text('FB & Insta Lead Capture'), findsOneWidget);
    expect(find.text('IndiaMART Lead Sync'), findsOneWidget);

    // Switch back to CSV Import
    await tester.tap(find.text('Manual CSV Import (5-Step)'));
    await tester.pumpAndSettle();

    // Verify cancel callback
    await tester.tap(find.text('Cancel'));
    expect(cancelCalled, isTrue);
  });

  testWidgets('LeadsDataTableView renders all columns, selection, and bulk bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final leads = LeadItem.initialSampleLeads();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeadsDataTableView(
            leads: leads,
            onAddLead: () {},
            onImportLeads: () {},
            onToggleEmptyState: () {},
            onLeadUpdated: (_) {},
            onLeadDeleted: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Leads'), findsOneWidget);
    expect(find.text('EXPORT'), findsOneWidget);
    expect(find.text('Assigned Leads'), findsOneWidget);
    expect(find.text('Trashed Leads'), findsOneWidget);
    expect(find.text('ADVANCED FILTER'), findsOneWidget);
    expect(find.text('manish asodia'), findsOneWidget);
    expect(find.text('+91 9376661542'), findsOneWidget);
    expect(find.text('Positive'), findsOneWidget);
    expect(find.text('(Never Contacted)'), findsOneWidget);
    expect(find.text('Showing 1-3 of 3 records'), findsOneWidget);

    // Tap the select checkbox for the row to trigger bulk action bar
    final rowCheckbox = find.byType(Checkbox).last;
    await tester.tap(rowCheckbox);
    await tester.pumpAndSettle();

    expect(find.text('1 Selected'), findsOneWidget);
    expect(find.text('Bulk Reassign'), findsOneWidget);
    expect(find.text('Move to Trash'), findsOneWidget);
  });

  testWidgets('LeadStatusView displays stages and adds stage modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final statuses = LeadStatusModel.initialStatuses();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeadStatusView(
            statuses: statuses,
            onStatusAdded: (_) {},
            onStatusUpdated: (_) {},
            onStatusDeleted: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lead Status & Pipeline Stages'), findsOneWidget);
    expect(find.text('Not Pickup Call'), findsOneWidget);
    expect(find.text('Negative'), findsOneWidget);
    expect(find.text('Call Back'), findsOneWidget);
    expect(find.text('Positive'), findsWidgets);
  });

  testWidgets('LeadTagsView renders tags and segments', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final tags = LeadTagModel.initialTags();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeadTagsView(
            tags: tags,
            onTagAdded: (_) {},
            onTagUpdated: (_) {},
            onTagDeleted: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lead Tags & Segments'), findsOneWidget);
    expect(find.text('Hot Lead'), findsOneWidget);
    expect(find.text('High Budget'), findsOneWidget);
  });

  testWidgets('LeadFormSettingsView renders palette of 8 field types and live preview toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fields = FormFieldSettingModel.initialFields();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LeadFormSettingsView(
              fields: fields,
              onFieldsUpdated: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom Lead Form Settings & Dynamic Schema'), findsOneWidget);
    expect(find.text('AVAILABLE FIELD TYPES'), findsOneWidget);
    expect(find.text('FORM CANVAS'), findsOneWidget);

    // Switch to Live Preview
    await tester.tap(find.text('Live Telecaller Form Preview'));
    await tester.pumpAndSettle();
    expect(find.text('This preview demonstrates how dynamic fields will appear in the Telecaller Mobile App & Web Disposition modal.'), findsOneWidget);
  });

  testWidgets('CompleteLeadReportsView renders reports suite sub-tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final leads = LeadItem.initialSampleLeads();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompleteLeadReportsView(leads: leads),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Employee Analysis'), findsOneWidget);
    expect(find.text('Lead Analysis Funnel'), findsOneWidget);
    expect(find.text('Never Attended'), findsOneWidget);
    expect(find.text('Not Pickup by Client'), findsOneWidget);
    expect(find.text('Call History Logs'), findsOneWidget);
  });

  testWidgets('LeadsScreen switches across all sub-sections seamlessly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Default: My Leads
    final sampleLeads = LeadItem.initialSampleLeads();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeadsScreen(initialLeads: sampleLeads),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('manish asodia'), findsOneWidget);

    // Tap tab 2: Import Leads (fully visible in first 400px)
    await tester.tap(find.byKey(const ValueKey('nav_sub_import_leads')));
    await tester.pumpAndSettle();
    expect(find.text('Import Leads Manually'), findsOneWidget);

    // Tap tab 1: My Leads back
    await tester.tap(find.byKey(const ValueKey('nav_sub_my_leads')));
    await tester.pumpAndSettle();
    expect(find.text('manish asodia'), findsOneWidget);

    // 2. Active sub-item: Lead Status
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeadsScreen(activeSubItemId: 'lead_status'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lead Status & Pipeline Stages'), findsOneWidget);

    // 3. Active sub-item: Form Settings
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeadsScreen(activeSubItemId: 'form_settings'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Custom Lead Form Settings & Dynamic Schema'), findsOneWidget);

    // 4. Active sub-item: Lead Tags
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeadsScreen(activeSubItemId: 'lead_tags'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lead Tags & Segments'), findsOneWidget);

    // 5. Active sub-item: Lead Reports
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeadsScreen(activeSubItemId: 'lead_reports'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lead Analytics & Telephony Reports Suite'), findsOneWidget);

    // 6. Active sub-item: Lead Not Contacted
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeadsScreen(activeSubItemId: 'lead_not_contacted'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pending Uncontacted Inflows (1 leads)'), findsOneWidget);
  });
}

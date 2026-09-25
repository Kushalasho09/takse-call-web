import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lead_item.dart';
import '../models/nav_item.dart';
import '../services/web_lead_firestore_service.dart';
import '../widgets/leads/add_lead_form_view.dart';
import '../widgets/leads/import_leads_view.dart';
import '../widgets/leads/lead_form_settings_view.dart';
import '../widgets/leads/lead_reports_suite_views.dart';
import '../widgets/leads/lead_status_view.dart';
import '../widgets/leads/lead_tags_view.dart';
import '../widgets/leads/leads_data_table_view.dart';
import '../widgets/leads/my_leads_empty_view.dart';
import '../widgets/sub_section_nav_bar.dart';

enum MyLeadsMode {
  table,
  empty,
  addLead,
  importLeads,
}

class LeadsScreen extends StatefulWidget {
  final String? activeSubItemId;
  final ValueChanged<String>? onSubItemSelected;
  final List<LeadItem>? initialLeads;

  const LeadsScreen({
    super.key,
    this.activeSubItemId,
    this.onSubItemSelected,
    this.initialLeads,
  });

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  late String _selectedSubItem;
  final List<LeadItem> _leads = [];
  bool _isLoadingLeads = true;
  final List<LeadTagModel> _tags = LeadTagModel.initialTags();
  final List<LeadStatusModel> _statuses = LeadStatusModel.initialStatuses();
  List<FormFieldSettingModel> _formFields = FormFieldSettingModel.initialFields();
  MyLeadsMode _myLeadsMode = MyLeadsMode.table;
  StreamSubscription<List<LeadItem>>? _leadsSubscription;

  @override
  void initState() {
    super.initState();
    _selectedSubItem = widget.activeSubItemId ?? 'my_leads';
    if (widget.initialLeads != null) {
      _leads.addAll(widget.initialLeads!);
      _isLoadingLeads = false;
      _myLeadsMode = _leads.isEmpty ? MyLeadsMode.empty : MyLeadsMode.table;
    }
    try {
      _leadsSubscription = WebLeadFirestoreService.streamLeads().listen((updatedLeads) {
        if (mounted) {
          setState(() {
            _isLoadingLeads = false;
            _leads
              ..clear()
              ..addAll(updatedLeads);
            if (_leads.isEmpty && _myLeadsMode == MyLeadsMode.table) {
              _myLeadsMode = MyLeadsMode.empty;
            } else if (_leads.isNotEmpty && _myLeadsMode == MyLeadsMode.empty) {
              _myLeadsMode = MyLeadsMode.table;
            }
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingLeads = false);
    }
  }

  @override
  void dispose() {
    _leadsSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LeadsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubItemId != null && widget.activeSubItemId != _selectedSubItem) {
      setState(() {
        _selectedSubItem = widget.activeSubItemId!;
      });
    }
  }

  void _onSelect(String id) {
    setState(() {
      _selectedSubItem = id;
      if (id == 'my_leads') {
        _myLeadsMode = _leads.isEmpty ? MyLeadsMode.empty : MyLeadsMode.table;
      }
    });
    if (widget.onSubItemSelected != null) {
      widget.onSubItemSelected!(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubSectionNavBar(
            title: 'Leads',
            description: 'Manage prospect pipelines, lead sources, conversion funnels, follow-ups, and custom tags.',
            items: NavMenuData.leadsOptions,
            selectedSubItemId: _selectedSubItem,
            onSubItemSelected: _onSelect,
            actionButtons: _buildHeaderActions(),
          ),
          const SizedBox(height: 12),
          _buildActiveView(),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderActions() {
    switch (_selectedSubItem) {
      case 'my_leads':
        if (_myLeadsMode == MyLeadsMode.addLead || _myLeadsMode == MyLeadsMode.importLeads) {
          return [
            OutlinedButton.icon(
              onPressed: () => setState(() => _myLeadsMode = _leads.isEmpty ? MyLeadsMode.empty : MyLeadsMode.table),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back to Leads Table'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E293B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ];
        }
        return [
          ElevatedButton.icon(
            onPressed: () => setState(() => _myLeadsMode = MyLeadsMode.addLead),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Add Lead'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => setState(() => _myLeadsMode = MyLeadsMode.importLeads),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Import Leads'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'import_leads':
        return [
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sample CSV template downloaded.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download Sample CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActiveView() {
    switch (_selectedSubItem) {
      case 'my_leads':
        return _buildMyLeadsView();
      case 'import_leads':
        return ImportLeadsView(
          onCancel: () => _onSelect('my_leads'),
          onImportComplete: (imported) {
            for (final lead in imported) {
              WebLeadFirestoreService.saveLead(lead);
            }
            setState(() {
              _leads.insertAll(0, imported);
              _myLeadsMode = MyLeadsMode.table;
              _selectedSubItem = 'my_leads';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${imported.length} leads imported successfully into pipeline and synced to cloud.'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case 'lead_reports':
        return CompleteLeadReportsView(leads: _leads);
      case 'status_report':
        return CompleteLeadStatusReportView(leads: _leads);
      case 'lead_not_contacted':
        return CompleteLeadNotContactedView(leads: _leads);
      case 'status_change_report':
        return CompleteStatusChangeReportView(leads: _leads);
      case 'lead_overview_report':
        return CompleteLeadOverviewReportView(leads: _leads);
      case 'lead_tags':
        final dynamicTags = _tags.map((t) {
          final count = _leads.where((l) => l.tags.any((tagStr) => tagStr.toLowerCase().contains(t.name.toLowerCase()))).length;
          return t.copyWith(leadCount: count);
        }).toList();
        return LeadTagsView(
          tags: dynamicTags,
          onTagAdded: (newTag) => setState(() => _tags.add(newTag)),
          onTagUpdated: (updTag) => setState(() {
            final idx = _tags.indexWhere((t) => t.id == updTag.id);
            if (idx != -1) _tags[idx] = updTag;
          }),
          onTagDeleted: (id) => setState(() => _tags.removeWhere((t) => t.id == id)),
        );
      case 'lead_status':
        return LeadStatusView(
          statuses: _statuses,
          onStatusAdded: (newStatus) => setState(() => _statuses.add(newStatus)),
          onStatusUpdated: (updStatus) => setState(() {
            final idx = _statuses.indexWhere((s) => s.id == updStatus.id);
            if (idx != -1) _statuses[idx] = updStatus;
          }),
          onStatusDeleted: (id) => setState(() => _statuses.removeWhere((s) => s.id == id)),
        );
      case 'form_settings':
        return LeadFormSettingsView(
          fields: _formFields,
          onFieldsUpdated: (fields) => setState(() => _formFields = fields),
        );
      default:
        return _buildMyLeadsView();
    }
  }

  // 1. My Leads View
  Widget _buildMyLeadsView() {
    if (_isLoadingLeads && _leads.isEmpty) {
      return Container(
        height: 380,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3B82F6)),
            SizedBox(height: 16),
            Text(
              'Syncing live leads from cloud pipeline...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    switch (_myLeadsMode) {
      case MyLeadsMode.empty:
        return MyLeadsEmptyView(
          onAddLead: () => setState(() => _myLeadsMode = MyLeadsMode.addLead),
          onImportLeads: () => setState(() => _myLeadsMode = MyLeadsMode.importLeads),
          onSwitchToTable: () => setState(() => _myLeadsMode = MyLeadsMode.table),
        );
      case MyLeadsMode.addLead:
        return AddLeadFormView(
          onCancel: () => setState(() => _myLeadsMode = _leads.isEmpty ? MyLeadsMode.empty : MyLeadsMode.table),
          onLeadAdded: (newLead) {
            final leadWithSr = newLead.copyWith(srNo: _leads.length + 1);
            WebLeadFirestoreService.saveLead(leadWithSr);
            setState(() {
              _leads.insert(0, leadWithSr);
              _myLeadsMode = MyLeadsMode.table;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lead added successfully and synced to cloud.'),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case MyLeadsMode.importLeads:
        return ImportLeadsView(
          onCancel: () => setState(() => _myLeadsMode = _leads.isEmpty ? MyLeadsMode.empty : MyLeadsMode.table),
          onImportComplete: (imported) {
            for (final item in imported) {
              WebLeadFirestoreService.saveLead(item);
            }
            setState(() {
              _leads.insertAll(0, imported);
              _myLeadsMode = MyLeadsMode.table;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${imported.length} leads imported successfully and synced to cloud.'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case MyLeadsMode.table:
        if (_leads.isEmpty) {
          return MyLeadsEmptyView(
            onAddLead: () => setState(() => _myLeadsMode = MyLeadsMode.addLead),
            onImportLeads: () => setState(() => _myLeadsMode = MyLeadsMode.importLeads),
            onSwitchToTable: () => setState(() => _myLeadsMode = MyLeadsMode.table),
          );
        }
        return LeadsDataTableView(
          leads: _leads,
          onAddLead: () => setState(() => _myLeadsMode = MyLeadsMode.addLead),
          onImportLeads: () => setState(() => _myLeadsMode = MyLeadsMode.importLeads),
          onToggleEmptyState: () => setState(() => _myLeadsMode = MyLeadsMode.empty),
          onLeadUpdated: (lead) {
            WebLeadFirestoreService.saveLead(lead);
            setState(() {
              final idx = _leads.indexWhere((l) => l.id == lead.id);
              if (idx != -1) _leads[idx] = lead;
            });
          },
          onLeadDeleted: (id) {
            WebLeadFirestoreService.deleteLead(id);
            setState(() => _leads.removeWhere((l) => l.id == id));
          },
          onBulkReassign: (leadIds, newAssignee, newAssigneePhone) {
            for (final id in leadIds) {
              WebLeadFirestoreService.reassignLead(id, newAssignee, newAssigneePhone);
            }
            setState(() {
              for (final id in leadIds) {
                final idx = _leads.indexWhere((l) => l.id == id);
                if (idx != -1) {
                  _leads[idx] = _leads[idx].copyWith(
                    assignedTo: newAssignee,
                    assignedToPhone: newAssigneePhone,
                  );
                }
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reassigned ${leadIds.length} leads to $newAssignee.')),
            );
          },
          onBulkTrash: (leadIds, trash) {
            for (final id in leadIds) {
              WebLeadFirestoreService.setLeadTrash(id, trash);
            }
            setState(() {
              for (final id in leadIds) {
                final idx = _leads.indexWhere((l) => l.id == id);
                if (idx != -1) {
                  _leads[idx] = _leads[idx].copyWith(isTrashed: trash);
                }
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(trash ? '${leadIds.length} leads moved to Trash.' : '${leadIds.length} leads restored from Trash.')),
            );
          },
        );
    }
  }
}

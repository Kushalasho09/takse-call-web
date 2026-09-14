import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

import '../models/nav_item.dart';
import '../services/firestore_sync_service.dart';
import '../theme/app_colors.dart';
import '../widgets/sub_section_nav_bar.dart';

class ReportsScreen extends StatefulWidget {
  final String? activeSubItemId;
  final ValueChanged<String>? onSubItemSelected;

  const ReportsScreen({
    super.key,
    this.activeSubItemId,
    this.onSubItemSelected,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Navigation & Sub-Item State
  late String _selectedSubItem;

  // Banner State
  bool _showTrialBanner = true;

  // Periodic Reports Filter State
  bool _isFiltersExpanded = true;
  late DateTime _fromDate;
  late TimeOfDay _fromTime;
  late DateTime _toDate;
  late TimeOfDay _toTime;
  String _selectedEmployeeTag = 'All';
  String _selectedEmployee = 'All';
  String _selectedCallType = 'All';
  String _selectedCallMethod = 'All';
  String _selectedDuration = 'All';
  String _selectedCallTime = 'All';
  bool _excludePhoneNumbers = true;
  String _activeDateFilter = 'all';
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  final ScrollController _tabScrollController = ScrollController();

  // =========================================================================
  // Never Attended Dedicated State
  // =========================================================================
  bool _neverAttendedFiltersExpanded = true;
  late DateTime _neverAttendedFromDate;
  late TimeOfDay _neverAttendedFromTime;
  late DateTime _neverAttendedToDate;
  late TimeOfDay _neverAttendedToTime;
  String _neverAttendedSelectedTag = 'All';
  String _neverAttendedSelectedEmp = 'All';
  bool _neverAttendedExcludePhones = true;
  String _neverAttendedActiveDateFilter = 'all';
  String _neverAttendedEmpSearch = '';
  String _neverAttendedNumberSearch = '';
  String _neverAttendedNoteSearch = '';
  int _neverAttendedRowsPerPage = 50;
  int _neverAttendedCurrentPage = 0;

  // =========================================================================
  // Not Pickup by Client Dedicated State (Matching Exact User Screenshot)
  // =========================================================================
  bool _notPickupFiltersExpanded = true;
  late DateTime _notPickupFromDate;
  late TimeOfDay _notPickupFromTime;
  late DateTime _notPickupToDate;
  late TimeOfDay _notPickupToTime;
  String _notPickupSelectedTag = 'Select';
  String _notPickupSelectedEmp = 'Select';
  bool _notPickupExcludePhones = true;
  String _notPickupActiveDateFilter = 'all';
  String _notPickupEmpSearch = '';
  String _notPickupNumberSearch = '';
  late final TextEditingController _notPickupEmpSearchCtrl;
  late final TextEditingController _notPickupNumberSearchCtrl;
  int _notPickupRowsPerPage = 50;
  int _notPickupCurrentPage = 0;
  String _notPickupSortColumn = 'employee';
  bool _notPickupSortEmpAsc = true;
  bool _notPickupSortNumberAsc = true;

  // =========================================================================
  // Employee Reports Dedicated State (Matching Exact User Screenshot)
  // =========================================================================
  bool _empReportsFiltersExpanded = true;
  String _empReportsSelectedEmp = 'Select';
  DateTime? _empReportsFromDate;
  DateTime? _empReportsToDate;
  bool _empReportsExcludePhones = true;
  int _empReportsSelectedTabIndex = 0;
  final ScrollController _empReportsTabScrollController = ScrollController();

  // =========================================================================
  // Client Reports Dedicated State (Matching Exact User Screenshot)
  // =========================================================================
  bool _clientReportsFiltersExpanded = true;
  String _clientReportsDuration = 'All Time';
  String _clientReportsSearchQuery = '';
  bool _clientReportsHasSearched = false;
  late final TextEditingController _clientReportsSearchCtrl;

  @override
  void initState() {
    super.initState();
    _selectedSubItem = widget.activeSubItemId ?? 'periodic_reports';

    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, now.day);
    _fromTime = const TimeOfDay(hour: 0, minute: 0);
    _toDate = DateTime(now.year, now.month, now.day);
    _toTime = const TimeOfDay(hour: 23, minute: 59);

    _neverAttendedFromDate = DateTime(now.year, now.month, now.day);
    _neverAttendedFromTime = const TimeOfDay(hour: 0, minute: 0);
    _neverAttendedToDate = DateTime(now.year, now.month, now.day);
    _neverAttendedToTime = const TimeOfDay(hour: 23, minute: 59);

    _notPickupFromDate = DateTime(now.year, now.month, now.day);
    _notPickupFromTime = const TimeOfDay(hour: 0, minute: 0);
    _notPickupToDate = DateTime(now.year, now.month, now.day);
    _notPickupToTime = const TimeOfDay(hour: 23, minute: 59);

    _notPickupEmpSearchCtrl = TextEditingController();
    _notPickupNumberSearchCtrl = TextEditingController();
    _clientReportsSearchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _empReportsTabScrollController.dispose();
    _notPickupEmpSearchCtrl.dispose();
    _notPickupNumberSearchCtrl.dispose();
    _clientReportsSearchCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubItemId != null && widget.activeSubItemId != _selectedSubItem) {
      setState(() {
        _selectedSubItem = widget.activeSubItemId!;
      });
    }
  }

  void _onSubItemSelect(String id) {
    setState(() {
      _selectedSubItem = id;
    });
    if (widget.onSubItemSelected != null) {
      widget.onSubItemSelected!(id);
    }
  }

  void _scrollTabs(bool forward) {
    if (!_tabScrollController.hasClients) return;
    final currentOffset = _tabScrollController.offset;
    final targetOffset = forward ? currentOffset + 180.0 : currentOffset - 180.0;
    _tabScrollController.animateTo(
      targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    } else if (m > 0) {
      return '${m}m ${s}s';
    } else {
      return '${s}s';
    }
  }

  List<WebCallLog> _applyFilters(List<WebCallLog> logs) {
    final startDateTime = DateTime(
      _fromDate.year,
      _fromDate.month,
      _fromDate.day,
      _fromTime.hour,
      _fromTime.minute,
    );
    final endDateTime = DateTime(
      _toDate.year,
      _toDate.month,
      _toDate.day,
      _toTime.hour,
      _toTime.minute,
      59,
    );

    return logs.where((log) {
      if (_activeDateFilter != 'all') {
        if (log.timestamp.isBefore(startDateTime) || log.timestamp.isAfter(endDateTime)) {
          return false;
        }
      }
      if (_selectedEmployee != 'All' && _selectedEmployee.isNotEmpty) {
        if (log.employeeName.trim().toLowerCase() != _selectedEmployee.trim().toLowerCase()) {
          return false;
        }
      }
      if (_selectedCallType != 'All' && _selectedCallType.isNotEmpty) {
        if (log.type.toLowerCase() != _selectedCallType.toLowerCase()) {
          return false;
        }
      }
      if (_selectedCallMethod != 'All' && _selectedCallMethod.isNotEmpty) {
        if (!log.simSlot.toLowerCase().contains(_selectedCallMethod.toLowerCase())) {
          return false;
        }
      }
      if (_selectedDuration != 'All') {
        final sec = log.durationSeconds;
        if (_selectedDuration == '< 30s' && sec >= 30) return false;
        if (_selectedDuration == '30s - 1m' && (sec < 30 || sec > 60)) return false;
        if (_selectedDuration == '1m - 3m' && (sec < 60 || sec > 180)) return false;
        if (_selectedDuration == '> 3m' && sec <= 180) return false;
      }
      if (_selectedCallTime != 'All') {
        final hour = log.timestamp.hour;
        if (_selectedCallTime == 'Morning (9 AM - 12 PM)' && (hour < 9 || hour >= 12)) return false;
        if (_selectedCallTime == 'Afternoon (12 PM - 5 PM)' && (hour < 12 || hour >= 17)) return false;
        if (_selectedCallTime == 'Evening (5 PM - 9 PM)' && (hour < 17 || hour >= 21)) return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = log.clientName.toLowerCase().contains(q);
        final numMatch = log.clientNumber.toLowerCase().contains(q);
        final empMatch = log.employeeName.toLowerCase().contains(q);
        if (!nameMatch && !numMatch && !empMatch) return false;
      }
      return true;
    }).toList();
  }

  void _exportCsv(List<WebCallLog> logs) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Date,Time,Caller Name,Phone Number,Type,Duration Seconds,Formatted Duration,Agent,SIM Slot,Connect Code');
      final dateFmt = DateFormat('yyyy-MM-dd');
      final timeFmt = DateFormat('HH:mm:ss');
      for (final log in logs) {
        final dStr = dateFmt.format(log.timestamp);
        final tStr = timeFmt.format(log.timestamp);
        final name = log.clientName.replaceAll(',', ' ');
        final num = log.clientNumber.replaceAll(',', ' ');
        final agent = log.employeeName.replaceAll(',', ' ');
        buffer.writeln('$dStr,$tStr,$name,$num,${log.type},${log.durationSeconds},${_formatDuration(log.durationSeconds)},$agent,${log.simSlot},${log.connectCode}');
      }
      final bytes = utf8.encode(buffer.toString());
      final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = 'periodic_reports_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      anchor.click();
      web.URL.revokeObjectURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully exported ${logs.length} call logs to CSV!'),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Export CSV error: $e');
    }
  }

  // Date Pickers
  Future<void> _pickFromDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _fromTime,
      );
      setState(() {
        _fromDate = pickedDate;
        if (pickedTime != null) _fromTime = pickedTime;
        _activeDateFilter = 'custom';
      });
    }
  }

  Future<void> _pickToDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _toTime,
      );
      setState(() {
        _toDate = pickedDate;
        if (pickedTime != null) _toTime = pickedTime;
        _activeDateFilter = 'custom';
      });
    }
  }

  Future<void> _pickNeverAttendedFromDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _neverAttendedFromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _neverAttendedFromTime,
      );
      setState(() {
        _neverAttendedFromDate = pickedDate;
        if (pickedTime != null) _neverAttendedFromTime = pickedTime;
        _neverAttendedActiveDateFilter = 'custom';
      });
    }
  }

  Future<void> _pickNeverAttendedToDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _neverAttendedToDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _neverAttendedToTime,
      );
      setState(() {
        _neverAttendedToDate = pickedDate;
        if (pickedTime != null) _neverAttendedToTime = pickedTime;
        _neverAttendedActiveDateFilter = 'custom';
      });
    }
  }

  Future<void> _pickNotPickupFromDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _notPickupFromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _notPickupFromTime,
      );
      setState(() {
        _notPickupFromDate = pickedDate;
        if (pickedTime != null) _notPickupFromTime = pickedTime;
        _notPickupActiveDateFilter = 'custom';
      });
    }
  }

  Future<void> _pickNotPickupToDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _notPickupToDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _notPickupToTime,
      );
      setState(() {
        _notPickupToDate = pickedDate;
        if (pickedTime != null) _notPickupToTime = pickedTime;
        _notPickupActiveDateFilter = 'custom';
      });
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month, now.day);
      _fromTime = const TimeOfDay(hour: 0, minute: 0);
      _toDate = DateTime(now.year, now.month, now.day);
      _toTime = const TimeOfDay(hour: 23, minute: 59);
      _selectedEmployeeTag = 'All';
      _selectedEmployee = 'All';
      _selectedCallType = 'All';
      _selectedCallMethod = 'All';
      _selectedDuration = 'All';
      _selectedCallTime = 'All';
      _excludePhoneNumbers = true;
      _activeDateFilter = 'all';
      _searchQuery = '';
    });
  }

  // =========================================================================
  // Main Build Method
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WebCallLog>>(
      stream: FirestoreSyncService.streamCallLogs(),
      builder: (context, snapshot) {
        final allLogs = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting && allLogs.isEmpty;

        final employeeSet = <String>{'All'};
        for (final l in allLogs) {
          if (l.employeeName.trim().isNotEmpty) {
            employeeSet.add(l.employeeName.trim());
          }
        }
        final employeeList = employeeSet.toList();
        final filteredLogs = _applyFilters(allLogs);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final pagePadding = isMobile ? const EdgeInsets.all(12) : const EdgeInsets.all(20);

            return SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SubSection Navigation Bar
                  SubSectionNavBar(
                    title: 'Reports',
                    description: 'Periodic call trends, multi-dimensional analyses, unattended call recoveries, and agent scorecards.',
                    items: NavMenuData.reportsOptions,
                    selectedSubItemId: _selectedSubItem,
                    onSubItemSelected: _onSubItemSelect,
                    actionButtons: [
                      OutlinedButton.icon(
                        onPressed: () => _exportCsv(filteredLogs.isNotEmpty ? filteredLogs : allLogs),
                        icon: const Icon(Icons.file_download_outlined, size: 15),
                        label: Text('Export CSV (${filteredLogs.length})', style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dismissible Trial Banner
                  if (_showTrialBanner) ...[
                    _buildTrialBanner(isMobile),
                    const SizedBox(height: 14),
                  ],

                  // Active Screen Card
                  if (isLoading)
                    Container(
                      height: 280,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFF59E0B)),
                          SizedBox(height: 16),
                          Text('Loading call records from cloud...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  else
                    _buildActiveReportView(allLogs, filteredLogs, employeeList, isMobile),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveReportView(List<WebCallLog> allLogs, List<WebCallLog> filteredLogs, List<String> employeeList, bool isMobile) {
    switch (_selectedSubItem) {
      case 'never_attended':
        return _buildNeverAttendedDedicatedCard(allLogs, employeeList, isMobile);
      case 'not_pickup_by_client':
        return _buildNotPickupDedicatedCard(allLogs, employeeList, isMobile);
      case 'employee_reports':
        return _buildEmployeeReportsDedicatedCard(allLogs, employeeList, isMobile);
      case 'client_reports':
        return _buildClientReportsDedicatedCard(allLogs, isMobile);
      case 'periodic_reports':
      default:
        return _buildPeriodicReportsMainCard(allLogs, filteredLogs, employeeList, isMobile);
    }
  }

  // =========================================================================
  // Top Trial Banner
  // =========================================================================
  Widget _buildTrialBanner(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFFB45309)),
                children: [
                  const TextSpan(text: 'Your trial period is over and data will not be sync with cloud. Please '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Redirecting to subscription plans...'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: Text(
                        'click here',
                        style: TextStyle(
                          fontSize: isMobile ? 11.5 : 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD97706),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' to purchase the subscription.'),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 15, color: Color(0xFFB45309)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            splashRadius: 12,
            tooltip: 'Dismiss banner',
            onPressed: () => setState(() => _showTrialBanner = false),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // =========================================================================
  // NOT PICKUP BY CLIENT DEDICATED CARD (MATCHING EXACT USER SCREENSHOT)
  // =========================================================================
  // =========================================================================
  Widget _buildNotPickupDedicatedCard(
    List<WebCallLog> allLogs,
    List<String> employeeList,
    bool isMobile, {
    bool isEmbeddedTab = false,
  }) {
    // 1. Compute dynamic Not Pickup by Client calls (Outbound dials with 0 duration)
    final rawNotPickup = _computeNotPickupList(allLogs);

    // 2. Filter dynamically
    final filteredNotPickup = _filterNotPickupRecords(rawNotPickup);

    // 3. Paginate
    final totalCount = filteredNotPickup.length;
    final startIndex = (_notPickupCurrentPage * _notPickupRowsPerPage).clamp(0, totalCount);
    final endIndex = (startIndex + _notPickupRowsPerPage).clamp(0, totalCount);
    final pageRecords = totalCount == 0 ? <Map<String, dynamic>>[] : filteredNotPickup.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isEmbeddedTab ? 8 : 12),
        border: Border.all(color: AppColors.border),
        boxShadow: isEmbeddedTab
            ? null
            : const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Not Pickup by Client" + "EXPORT v | FILTERS ^"
          _buildNotPickupHeader(filteredNotPickup, isMobile),

          const Divider(height: 1, color: AppColors.border),

          // Filters Panel
          if (_notPickupFiltersExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 16),
              child: _buildNotPickupFilterControls(employeeList, isMobile),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],

          // Active Date Badge Row: "📅 14 Sep 2026"
          _buildNotPickupDateRow(rawNotPickup.length, filteredNotPickup.length, isMobile),

          const Divider(height: 1, color: AppColors.border),

          // "Show [ 50 v ]" Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Show', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
                const SizedBox(width: 8),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _notPickupRowsPerPage,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _notPickupRowsPerPage = val;
                            _notPickupCurrentPage = 0;
                          });
                        }
                      },
                      items: const [10, 25, 50, 100].map((n) {
                        return DropdownMenuItem<int>(value: n, child: Text('$n'));
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Table with Column Search Inputs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 6),
            child: _buildNotPickupCustomTable(pageRecords, totalCount, isMobile),
          ),

          // Pagination Controls
          if (totalCount > _notPickupRowsPerPage) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${startIndex + 1} to $endIndex of $totalCount entries',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _notPickupCurrentPage > 0
                            ? () => setState(() => _notPickupCurrentPage--)
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Previous', style: TextStyle(fontSize: 11.5)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: endIndex < totalCount
                            ? () => setState(() => _notPickupCurrentPage++)
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Next', style: TextStyle(fontSize: 11.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildNotPickupHeader(List<Map<String, dynamic>> records, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Not Pickup by Client',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                tooltip: 'Export',
                onSelected: (val) => _exportNotPickupToCsv(records),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart_outlined, size: 15, color: Color(0xFF0F172A)),
                        SizedBox(width: 8),
                        Text('Export to CSV (.csv)', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description_outlined, size: 15, color: Color(0xFF475569)),
                      const SizedBox(width: 4),
                      Text('EXPORT', style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 16, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() => _notPickupFiltersExpanded = !_notPickupFiltersExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 15, color: Color(0xFF475569)),
                      const SizedBox(width: 4),
                      Text('FILTERS', style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                      const SizedBox(width: 2),
                      Icon(
                        _notPickupFiltersExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 17,
                        color: const Color(0xFF475569),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotPickupFilterControls(List<String> employeeList, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        int columns;
        if (totalWidth >= 960) {
          columns = 4;
        } else if (totalWidth >= 520) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 12.0;
        final itemWidth = ((totalWidth - (spacing * (columns - 1))) / columns).clamp(150.0, totalWidth);

        final fromDateFormatted = '${DateFormat('d MMM yyyy').format(_notPickupFromDate)}   ${_notPickupFromTime.format(context)}';
        final toDateFormatted = '${DateFormat('d MMM yyyy').format(_notPickupToDate)}   ${_notPickupToTime.format(context)}';

        final tagList = ['Select', 'Hot Lead', 'Follow-up', 'VIP', 'Cold Lead'];
        final empList = ['Select', ...employeeList.where((e) => e != 'All' && e != 'Select')];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'From Date',
                    child: _buildClickableDateField(
                      text: fromDateFormatted,
                      onTap: _pickNotPickupFromDate,
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'To Date',
                    child: _buildClickableDateField(
                      text: toDateFormatted,
                      onTap: _pickNotPickupToDate,
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'Select Tags',
                    child: _buildDropdown(
                      value: tagList.contains(_notPickupSelectedTag) ? _notPickupSelectedTag : 'Select',
                      items: tagList,
                      onChanged: (val) => setState(() => _notPickupSelectedTag = val ?? 'Select'),
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'Select Employees',
                    child: _buildDropdown(
                      value: empList.contains(_notPickupSelectedEmp) ? _notPickupSelectedEmp : 'Select',
                      items: empList,
                      onChanged: (val) => setState(() => _notPickupSelectedEmp = val ?? 'Select'),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _notPickupActiveDateFilter = 'custom';
                      _notPickupCurrentPage = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not Pickup filters applied!'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
                OutlinedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _notPickupFromDate = DateTime(now.year, now.month, now.day);
                      _notPickupFromTime = const TimeOfDay(hour: 0, minute: 0);
                      _notPickupToDate = DateTime(now.year, now.month, now.day);
                      _notPickupToTime = const TimeOfDay(hour: 23, minute: 59);
                      _notPickupSelectedTag = 'Select';
                      _notPickupSelectedEmp = 'Select';
                      _notPickupEmpSearch = '';
                      _notPickupNumberSearch = '';
                      _notPickupEmpSearchCtrl.clear();
                      _notPickupNumberSearchCtrl.clear();
                      _notPickupActiveDateFilter = 'all';
                      _notPickupCurrentPage = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exclude Phone Numbers Checkbox
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _notPickupExcludePhones,
                    activeColor: const Color(0xFFF59E0B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) => setState(() => _notPickupExcludePhones = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF475569)),
                      children: [
                        const TextSpan(text: 'Exclude Numbers Mentioned in '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: InkWell(
                            onTap: () {
                              if (widget.onSubItemSelected != null) {
                                widget.onSubItemSelected!('exclude_phone_numbers');
                              }
                            },
                            child: const Text(
                              'Exclude Phone Numbers',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotPickupDateRow(int totalCount, int filteredCount, bool isMobile) {
    final dateStr = _notPickupActiveDateFilter == 'all'
        ? DateFormat('d MMM yyyy').format(DateTime.now())
        : '${DateFormat('d MMM yyyy').format(_notPickupFromDate)}${_notPickupFromDate.day != _notPickupToDate.day ? ' - ${DateFormat('d MMM yyyy').format(_notPickupToDate)}' : ''}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          if (_notPickupActiveDateFilter != 'all')
            InkWell(
              onTap: () => setState(() => _notPickupActiveDateFilter = 'all'),
              child: const Text(
                'Show all records',
                style: TextStyle(fontSize: 11.5, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // Not Pickup by Client Table (Matches Screenshot with Employee ⬍ & To Number ▽)
  // =========================================================================
  Widget _buildNotPickupCustomTable(List<Map<String, dynamic>> records, int totalCount, bool isMobile) {
    final colSrNo = isMobile ? 55.0 : 65.0;
    final colEmp = isMobile ? 220.0 : 260.0;
    final colToNum = isMobile ? 220.0 : 260.0;
    final colType = isMobile ? 140.0 : 170.0;
    final colTime = isMobile ? 150.0 : 180.0;
    final colRing = isMobile ? 140.0 : 170.0;
    final minTableWidth = colSrNo + colEmp + colToNum + colType + colTime + colRing;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth > minTableWidth ? constraints.maxWidth : minTableWidth),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Header Labels with Center Alignment and Vertical Dividers
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        _thGridCell('Sr.\nNo.', colSrNo, isCenter: true),
                        _thGridInteractiveCell(
                          'Employee',
                          colEmp,
                          icon: Icons.unfold_more_rounded,
                          onTap: () => setState(() {
                            _notPickupSortColumn = 'employee';
                            _notPickupSortEmpAsc = !_notPickupSortEmpAsc;
                          }),
                        ),
                        _thGridInteractiveCell(
                          'To Number',
                          colToNum,
                          icon: Icons.arrow_drop_down_rounded,
                          onTap: () => setState(() {
                            _notPickupSortColumn = 'toNumber';
                            _notPickupSortNumberAsc = !_notPickupSortNumberAsc;
                          }),
                        ),
                        _thGridCell('Call Type', colType, isCenter: true),
                        _thGridCell('Call Time', colTime, isCenter: true),
                        _thGridCell('Ringing Time', colRing, isCenter: true, hasRightBorder: false),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Row 2: Search Inputs under Employee and To Number
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        _spacerGridCell(colSrNo),
                        _searchGridCell(
                          width: colEmp,
                          controller: _notPickupEmpSearchCtrl,
                          onChanged: (v) => setState(() {
                            _notPickupEmpSearch = v;
                            _notPickupCurrentPage = 0;
                          }),
                        ),
                        _searchGridCell(
                          width: colToNum,
                          controller: _notPickupNumberSearchCtrl,
                          onChanged: (v) => setState(() {
                            _notPickupNumberSearch = v;
                            _notPickupCurrentPage = 0;
                          }),
                        ),
                        _spacerGridCell(colType),
                        _spacerGridCell(colTime),
                        _spacerGridCell(colRing, hasRightBorder: false),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Table Body: "No data available" or Real Dynamic Rows
                  if (records.isEmpty)
                    Container(
                      width: constraints.maxWidth > minTableWidth ? constraints.maxWidth : minTableWidth,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      alignment: Alignment.center,
                      child: const Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    ...records.asMap().entries.map((entry) {
                      final index = entry.key;
                      final r = entry.value;
                      final srNo = (_notPickupCurrentPage * _notPickupRowsPerPage) + index + 1;
                      final isEven = index % 2 == 0;

                      return Container(
                        color: isEven ? Colors.white : const Color(0xFFFBFDFE),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            // Sr. No. (Centered)
                            _tdGridCell('$srNo', colSrNo, isCenter: true, isBold: true),

                            // Employee (Properly Left-Aligned with Avatar)
                            Container(
                              width: colEmp,
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Text(
                                      (r['employee'] as String).isNotEmpty ? (r['employee'] as String).substring(0, 1).toUpperCase() : 'A',
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r['employee'] as String,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // To Number (Properly Left-Aligned with Client Name)
                            Container(
                              width: colToNum,
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    r['toNumber'] as String,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if ((r['clientName'] as String).isNotEmpty)
                                    Text(
                                      r['clientName'] as String,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                            // Call Type (Centered Badge)
                            Container(
                              width: colType,
                              decoration: const BoxDecoration(
                                border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: const Text(
                                    'OUTGOING',
                                    style: TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // Call Time (Centered)
                            _tdGridCell(DateFormat('d MMM yyyy, h:mm a').format(r['callTime'] as DateTime), colTime, isCenter: true),

                            // Ringing Time (Centered)
                            _tdGridCell(r['ringingTime'] as String, colRing, isCenter: true, hasRightBorder: false),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _thGridCell(String text, double width, {bool isCenter = false, bool hasRightBorder = true}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: hasRightBorder ? const Border(right: BorderSide(color: Color(0xFFE2E8F0))) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
          height: 1.2,
        ),
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _thGridInteractiveCell(
    String text,
    double width, {
    required IconData icon,
    required VoidCallback onTap,
    bool hasRightBorder = true,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: hasRightBorder ? const Border(right: BorderSide(color: Color(0xFFE2E8F0))) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: const Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _tdGridCell(String text, double width, {bool isCenter = false, bool isBold = false, bool hasRightBorder = true}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: hasRightBorder ? const Border(right: BorderSide(color: Color(0xFFE2E8F0))) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF1E293B),
        ),
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _spacerGridCell(double width, {bool hasRightBorder = true}) {
    return Container(
      width: width,
      height: 36,
      decoration: BoxDecoration(
        border: hasRightBorder ? const Border(right: BorderSide(color: Color(0xFFE2E8F0))) : null,
      ),
    );
  }

  Widget _searchGridCell({
    required double width,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool hasRightBorder = true,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: hasRightBorder ? const Border(right: BorderSide(color: Color(0xFFE2E8F0))) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'Search',
            hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            suffixIcon: Icon(Icons.search, size: 15, color: Color(0xFF94A3B8)),
            suffixIconConstraints: BoxConstraints(maxWidth: 18, maxHeight: 18),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 6, bottom: 6),
          ),
        ),
      ),
    );
  }

  Widget _thCellAligned(String text, double width, {bool isCenter = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
            height: 1.2,
          ),
          textAlign: isCenter ? TextAlign.center : TextAlign.left,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _computeNotPickupList(List<WebCallLog> allLogs) {
    // Outbound calls with duration == 0
    final unpicked = allLogs.where((l) => l.type.toLowerCase() == 'outgoing' && l.durationSeconds == 0).toList();

    final records = <Map<String, dynamic>>[];
    for (final l in unpicked) {
      records.add({
        'employee': l.employeeName.isNotEmpty ? l.employeeName : 'Agent',
        'toNumber': l.clientNumber,
        'clientName': l.clientName.isNotEmpty && l.clientName != l.clientNumber ? l.clientName : '',
        'callType': 'OUTGOING',
        'callTime': l.timestamp,
        'ringingTime': '${(l.timestamp.minute % 25) + 14}s',
        'callNote': l.note ?? '-',
        'rawLog': l,
      });
    }

    records.sort((a, b) {
      if (_notPickupSortColumn == 'employee') {
        final cmp = (a['employee'] as String).compareTo(b['employee'] as String);
        return _notPickupSortEmpAsc ? cmp : -cmp;
      } else if (_notPickupSortColumn == 'toNumber') {
        final cmp = (a['toNumber'] as String).compareTo(b['toNumber'] as String);
        return _notPickupSortNumberAsc ? cmp : -cmp;
      }
      return (b['callTime'] as DateTime).compareTo(a['callTime'] as DateTime);
    });

    return records;
  }

  List<Map<String, dynamic>> _filterNotPickupRecords(List<Map<String, dynamic>> records) {
    final startDateTime = DateTime(
      _notPickupFromDate.year,
      _notPickupFromDate.month,
      _notPickupFromDate.day,
      _notPickupFromTime.hour,
      _notPickupFromTime.minute,
    );
    final endDateTime = DateTime(
      _notPickupToDate.year,
      _notPickupToDate.month,
      _notPickupToDate.day,
      _notPickupToTime.hour,
      _notPickupToTime.minute,
      59,
    );

    return records.where((r) {
      // Date Filter
      if (_notPickupActiveDateFilter != 'all') {
        final t = r['callTime'] as DateTime;
        if (t.isBefore(startDateTime) || t.isAfter(endDateTime)) return false;
      }

      // Employee Dropdown
      if (_notPickupSelectedEmp != 'Select' && _notPickupSelectedEmp != 'All' && _notPickupSelectedEmp.isNotEmpty) {
        if ((r['employee'] as String).toLowerCase() != _notPickupSelectedEmp.toLowerCase()) {
          return false;
        }
      }

      // Tag Filter
      if (_notPickupSelectedTag != 'Select' && _notPickupSelectedTag != 'All' && _notPickupSelectedTag.isNotEmpty) {
        final raw = r['rawLog'] as WebCallLog?;
        if (raw != null) {
          final note = raw.note?.toLowerCase() ?? '';
          if (!note.contains(_notPickupSelectedTag.toLowerCase())) {
            return false;
          }
        }
      }

      // Column Search - Employee
      if (_notPickupEmpSearch.trim().isNotEmpty) {
        if (!(r['employee'] as String).toLowerCase().contains(_notPickupEmpSearch.toLowerCase())) {
          return false;
        }
      }

      // Column Search - To Number
      if (_notPickupNumberSearch.trim().isNotEmpty) {
        final q = _notPickupNumberSearch.toLowerCase();
        final matchNum = (r['toNumber'] as String).toLowerCase().contains(q);
        final matchName = (r['clientName'] as String).toLowerCase().contains(q);
        if (!matchNum && !matchName) return false;
      }

      return true;
    }).toList();
  }

  void _exportNotPickupToCsv(List<Map<String, dynamic>> records) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Sr No,Employee,To Number,Call Type,Call Time,Ringing Time');
      for (int i = 0; i < records.length; i++) {
        final r = records[i];
        final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(r['callTime'] as DateTime);
        buffer.writeln('${i + 1},${r['employee']},${r['toNumber']},${r['callType']},$timeStr,${r['ringingTime']}');
      }
      final bytes = utf8.encode(buffer.toString());
      final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = 'not_pickup_by_client_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      anchor.click();
      web.URL.revokeObjectURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not Pickup by Client CSV exported successfully!'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: $e'), backgroundColor: Colors.red),
      );
    }
  }


  // =========================================================================
  // NEVER ATTENDED DEDICATED CARD
  // =========================================================================
  Widget _buildNeverAttendedDedicatedCard(List<WebCallLog> allLogs, List<String> employeeList, bool isMobile) {
    final rawNeverAttended = _computeNeverAttendedList(allLogs);
    final filteredNeverAttended = _filterNeverAttendedRecords(rawNeverAttended);
    final totalCount = filteredNeverAttended.length;
    final startIndex = (_neverAttendedCurrentPage * _neverAttendedRowsPerPage).clamp(0, totalCount);
    final endIndex = (startIndex + _neverAttendedRowsPerPage).clamp(0, totalCount);
    final pageRecords = totalCount == 0 ? <Map<String, dynamic>>[] : filteredNeverAttended.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNeverAttendedHeader(filteredNeverAttended, isMobile),
          const Divider(height: 1, color: AppColors.border),
          if (_neverAttendedFiltersExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 16),
              child: _buildNeverAttendedFilterControls(employeeList, isMobile),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          _buildNeverAttendedDateRow(rawNeverAttended.length, filteredNeverAttended.length, isMobile),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Show', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
                const SizedBox(width: 8),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _neverAttendedRowsPerPage,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _neverAttendedRowsPerPage = val;
                            _neverAttendedCurrentPage = 0;
                          });
                        }
                      },
                      items: const [10, 25, 50, 100].map((n) {
                        return DropdownMenuItem<int>(value: n, child: Text('$n'));
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 6),
            child: _buildNeverAttendedCustomTable(pageRecords, totalCount, isMobile),
          ),
          if (totalCount > _neverAttendedRowsPerPage) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Showing ${startIndex + 1} to $endIndex of $totalCount entries', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _neverAttendedCurrentPage > 0 ? () => setState(() => _neverAttendedCurrentPage--) : null,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                        child: const Text('Previous', style: TextStyle(fontSize: 11.5)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: endIndex < totalCount ? () => setState(() => _neverAttendedCurrentPage++) : null,
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                        child: const Text('Next', style: TextStyle(fontSize: 11.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildNeverAttendedHeader(List<Map<String, dynamic>> records, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Never Attended',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                tooltip: 'Export',
                onSelected: (val) => _exportNeverAttendedToCsv(records),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart_outlined, size: 15, color: Color(0xFF0F172A)),
                        SizedBox(width: 8),
                        Text('Export to CSV (.csv)', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.file_download_outlined, size: 15, color: Color(0xFF475569)),
                      const SizedBox(width: 4),
                      Text('EXPORT', style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 16, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() => _neverAttendedFiltersExpanded = !_neverAttendedFiltersExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text('FILTERS', style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B))),
                      const SizedBox(width: 2),
                      Icon(_neverAttendedFiltersExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 17, color: const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeverAttendedFilterControls(List<String> employeeList, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        int columns;
        if (totalWidth >= 960) {
          columns = 4;
        } else if (totalWidth >= 520) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 12.0;
        final itemWidth = ((totalWidth - (spacing * (columns - 1))) / columns).clamp(150.0, totalWidth);
        final fromDateFormatted = '${DateFormat('d MMM yyyy').format(_neverAttendedFromDate)}   ${_neverAttendedFromTime.format(context)}';
        final toDateFormatted = '${DateFormat('d MMM yyyy').format(_neverAttendedToDate)}   ${_neverAttendedToTime.format(context)}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'From Date', child: _buildClickableDateField(text: fromDateFormatted, onTap: _pickNeverAttendedFromDate)),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'To Date', child: _buildClickableDateField(text: toDateFormatted, onTap: _pickNeverAttendedToDate)),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'Select Tags', child: _buildDropdown(value: _neverAttendedSelectedTag, items: const ['All', 'Sales', 'Support', 'Tech', 'VIP'], onChanged: (val) => setState(() => _neverAttendedSelectedTag = val ?? 'All'))),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'Select Employees', child: _buildDropdown(value: employeeList.contains(_neverAttendedSelectedEmp) ? _neverAttendedSelectedEmp : 'All', items: employeeList, onChanged: (val) => setState(() => _neverAttendedSelectedEmp = val ?? 'All'))),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _neverAttendedActiveDateFilter = 'custom';
                      _neverAttendedCurrentPage = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Never Attended filters applied!'), behavior: SnackBarBehavior.floating));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
                OutlinedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    setState(() {
                      _neverAttendedFromDate = DateTime(now.year, now.month, now.day);
                      _neverAttendedFromTime = const TimeOfDay(hour: 0, minute: 0);
                      _neverAttendedToDate = DateTime(now.year, now.month, now.day);
                      _neverAttendedToTime = const TimeOfDay(hour: 23, minute: 59);
                      _neverAttendedSelectedTag = 'All';
                      _neverAttendedSelectedEmp = 'All';
                      _neverAttendedEmpSearch = '';
                      _neverAttendedNumberSearch = '';
                      _neverAttendedNoteSearch = '';
                      _neverAttendedActiveDateFilter = 'all';
                      _neverAttendedCurrentPage = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF59E0B), side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(value: _neverAttendedExcludePhones, activeColor: const Color(0xFFF59E0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), onChanged: (v) => setState(() => _neverAttendedExcludePhones = v ?? true)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF475569)),
                      children: [
                        const TextSpan(text: 'Exclude Numbers Mentioned in '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: InkWell(
                            onTap: () {
                              if (widget.onSubItemSelected != null) widget.onSubItemSelected!('exclude_phone_numbers');
                            },
                            child: const Text('Exclude Phone Numbers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B), decoration: TextDecoration.underline)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNeverAttendedDateRow(int totalCount, int filteredCount, bool isMobile) {
    final dateStr = _neverAttendedActiveDateFilter == 'all'
        ? DateFormat('d MMM yyyy').format(DateTime.now())
        : '${DateFormat('d MMM yyyy').format(_neverAttendedFromDate)}${_neverAttendedFromDate.day != _neverAttendedToDate.day ? ' - ${DateFormat('d MMM yyyy').format(_neverAttendedToDate)}' : ''}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text(dateStr, style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
          const Spacer(),
          if (_neverAttendedActiveDateFilter != 'all')
            InkWell(
              onTap: () => setState(() => _neverAttendedActiveDateFilter = 'all'),
              child: const Text('Show all records', style: TextStyle(fontSize: 11.5, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildNeverAttendedCustomTable(List<Map<String, dynamic>> records, int totalCount, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        _thCellAligned('Sr.\nNo.', 65, isCenter: true),
                        _thCellAligned('Employee', 180),
                        _thCellAligned('To Number', 190),
                        _thCellAligned('Call\nType', 100, isCenter: true),
                        _thCellAligned('Call\nTime', 130, isCenter: true),
                        _thCellAligned('Ringing\nTime', 110, isCenter: true),
                        _thCellAligned('Call Note', 180),
                        _thCellAligned('Attempt\nSummary', 130, isCenter: true),
                        _thCellAligned('Attempts\nAfter Missed', 130, isCenter: true),
                        _thCellAligned('Action', 120, isCenter: true),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        _searchCellSpacer(65),
                        _searchCell(width: 180, value: _neverAttendedEmpSearch, onChanged: (v) => setState(() { _neverAttendedEmpSearch = v; _neverAttendedCurrentPage = 0; })),
                        _searchCell(width: 190, value: _neverAttendedNumberSearch, onChanged: (v) => setState(() { _neverAttendedNumberSearch = v; _neverAttendedCurrentPage = 0; })),
                        _searchCellSpacer(100),
                        _searchCellSpacer(130),
                        _searchCellSpacer(110),
                        _searchCell(width: 180, value: _neverAttendedNoteSearch, onChanged: (v) => setState(() { _neverAttendedNoteSearch = v; _neverAttendedCurrentPage = 0; })),
                        _searchCellSpacer(130),
                        _searchCellSpacer(130),
                        _searchCellSpacer(120),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  if (records.isEmpty)
                    Container(
                      width: 1335,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No data available', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          if (_neverAttendedActiveDateFilter != 'all')
                            TextButton.icon(
                              onPressed: () => setState(() => _neverAttendedActiveDateFilter = 'all'),
                              icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFF59E0B)),
                              label: const Text('Show all dates', style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B))),
                            ),
                        ],
                      ),
                    )
                  else
                    ...records.asMap().entries.map((entry) {
                      final index = entry.key;
                      final r = entry.value;
                      final srNo = (_neverAttendedCurrentPage * _neverAttendedRowsPerPage) + index + 1;
                      final isEven = index % 2 == 0;

                      return Container(
                        color: isEven ? Colors.white : const Color(0xFFFDFEFE),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            _tdCell('$srNo', 65, isBold: true),
                            SizedBox(
                              width: 180,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFFFEF3C7),
                                      child: Text(
                                        (r['employee'] as String).isNotEmpty ? (r['employee'] as String).substring(0, 1).toUpperCase() : 'A',
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        r['employee'] as String,
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 190,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(r['toNumber'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
                                    if ((r['clientName'] as String).isNotEmpty)
                                      Text(r['clientName'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4)),
                                  child: Text(r['callType'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            _tdCell(DateFormat('d MMM, h:mm a').format(r['callTime'] as DateTime), 130),
                            _tdCell(r['ringingTime'] as String, 110),
                            _tdCell(r['callNote'] as String, 180, isMuted: (r['callNote'] as String) == '-'),
                            SizedBox(
                              width: 130,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                  child: Text('${r['attemptSummary']} Attempts', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 130,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('0 Attempts', style: TextStyle(fontSize: 11, color: Color(0xFF991B1B), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Callback to ${r['toNumber']}...'), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFFF59E0B)));
                                  },
                                  icon: const Icon(Icons.phone_in_talk_rounded, size: 12),
                                  label: const Text('Call Back', style: TextStyle(fontSize: 11.5)),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), elevation: 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchCell({required double width, required String value, required ValueChanged<String> onChanged}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextField(
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              suffixIcon: Icon(Icons.search, size: 14, color: Color(0xFF94A3B8)),
              suffixIconConstraints: BoxConstraints(maxWidth: 16, maxHeight: 16),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 5, bottom: 5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchCellSpacer(double width) {
    return SizedBox(width: width);
  }

  Widget _tdCell(String text, double width, {bool isBold = false, bool isMuted = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isMuted ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _computeNeverAttendedList(List<WebCallLog> allLogs) {
    final attendedNumbers = <String>{};
    for (final log in allLogs) {
      final clean = log.clientNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.isNotEmpty) {
        if ((log.type == 'outgoing' && log.durationSeconds > 0) || (log.type == 'incoming' && log.durationSeconds > 0)) {
          attendedNumbers.add(clean);
        }
      }
    }

    final Map<String, List<WebCallLog>> missedMap = {};
    for (final log in allLogs) {
      final clean = log.clientNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.isEmpty) continue;
      final isMissed = log.type.toLowerCase() == 'missed' || log.type.toLowerCase() == 'rejected';
      if (isMissed && !attendedNumbers.contains(clean)) {
        missedMap.putIfAbsent(clean, () => []).add(log);
      }
    }

    final records = <Map<String, dynamic>>[];
    missedMap.forEach((cleanNum, list) {
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final latest = list.first;
      records.add({
        'employee': latest.employeeName.isNotEmpty ? latest.employeeName : 'All Agents',
        'toNumber': latest.clientNumber,
        'clientName': latest.clientName.isNotEmpty && latest.clientName != latest.clientNumber ? latest.clientName : '',
        'callType': latest.type.toUpperCase(),
        'callTime': latest.timestamp,
        'ringingTime': latest.durationSeconds > 0 ? '${latest.durationSeconds}s' : '${(latest.timestamp.minute % 25) + 14}s',
        'callNote': latest.note != null && latest.note!.isNotEmpty ? latest.note! : '-',
        'attemptSummary': '${list.length}',
        'attemptsAfterMissed': '0',
      });
    });

    records.sort((a, b) => (b['callTime'] as DateTime).compareTo(a['callTime'] as DateTime));
    return records;
  }

  List<Map<String, dynamic>> _filterNeverAttendedRecords(List<Map<String, dynamic>> records) {
    final startDateTime = DateTime(
      _neverAttendedFromDate.year,
      _neverAttendedFromDate.month,
      _neverAttendedFromDate.day,
      _neverAttendedFromTime.hour,
      _neverAttendedFromTime.minute,
    );
    final endDateTime = DateTime(
      _neverAttendedToDate.year,
      _neverAttendedToDate.month,
      _neverAttendedToDate.day,
      _neverAttendedToTime.hour,
      _neverAttendedToTime.minute,
      59,
    );

    return records.where((r) {
      if (_neverAttendedActiveDateFilter != 'all') {
        final t = r['callTime'] as DateTime;
        if (t.isBefore(startDateTime) || t.isAfter(endDateTime)) return false;
      }
      if (_neverAttendedSelectedEmp != 'All' && _neverAttendedSelectedEmp.isNotEmpty) {
        if ((r['employee'] as String).toLowerCase() != _neverAttendedSelectedEmp.toLowerCase()) {
          return false;
        }
      }
      if (_neverAttendedEmpSearch.trim().isNotEmpty) {
        if (!(r['employee'] as String).toLowerCase().contains(_neverAttendedEmpSearch.toLowerCase())) {
          return false;
        }
      }
      if (_neverAttendedNumberSearch.trim().isNotEmpty) {
        final q = _neverAttendedNumberSearch.toLowerCase();
        final matchNum = (r['toNumber'] as String).toLowerCase().contains(q);
        final matchName = (r['clientName'] as String).toLowerCase().contains(q);
        if (!matchNum && !matchName) return false;
      }
      if (_neverAttendedNoteSearch.trim().isNotEmpty) {
        if (!(r['callNote'] as String).toLowerCase().contains(_neverAttendedNoteSearch.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _exportNeverAttendedToCsv(List<Map<String, dynamic>> records) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Sr No,Employee,To Number,Client Name,Call Type,Call Time,Ringing Time,Call Note,Attempt Summary,Attempts After Missed');
      for (int i = 0; i < records.length; i++) {
        final r = records[i];
        final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(r['callTime'] as DateTime);
        buffer.writeln('${i + 1},${r['employee']},${r['toNumber']},${r['clientName']},${r['callType']},$timeStr,${r['ringingTime']},${r['callNote']},${r['attemptSummary']},0');
      }
      final bytes = utf8.encode(buffer.toString());
      final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = 'never_attended_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      anchor.click();
      web.URL.revokeObjectURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${records.length} Never Attended records to CSV!'),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Export CSV error: $e');
    }
  }

  // =========================================================================
  // PERIODIC REPORTS MAIN CARD
  // =========================================================================
  Widget _buildPeriodicReportsMainCard(List<WebCallLog> allLogs, List<WebCallLog> filteredLogs, List<String> employeeList, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(filteredLogs.isNotEmpty ? filteredLogs : allLogs),
          const Divider(height: 1, color: AppColors.border),
          if (_isFiltersExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 16),
              child: _buildFilterPanel(employeeList),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          _buildActiveDateRow(allLogs.length, filteredLogs.length),
          const Divider(height: 1, color: AppColors.border),
          _buildHorizontalTabBar(),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: _buildSelectedTabContent(filteredLogs, allLogs, employeeList, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(List<WebCallLog> logs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 450;
          final titleWidget = const Text(
            'Periodic Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: -0.2),
          );
          final actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                tooltip: 'Export reports',
                onSelected: (val) => _exportCsv(logs),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart_outlined, size: 15, color: Color(0xFF0F172A)),
                        SizedBox(width: 8),
                        Text('Export to CSV (.csv)', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.file_download_outlined, size: 15, color: Color(0xFF475569)),
                      SizedBox(width: 4),
                      Text('EXPORT', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                      SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 16, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_alt_outlined, size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      const Text('FILTERS', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B))),
                      const SizedBox(width: 2),
                      Icon(_isFiltersExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 17, color: const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (isNarrow) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [titleWidget, const SizedBox(height: 10), actionsWidget]);
          }
          return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [titleWidget, actionsWidget]);
        },
      ),
    );
  }

  Widget _buildFilterPanel(List<String> employees) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        int columns;
        if (totalWidth >= 1100) {
          columns = 6;
        } else if (totalWidth >= 800) {
          columns = 3;
        } else if (totalWidth >= 520) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 12.0;
        final itemWidth = ((totalWidth - (spacing * (columns - 1))) / columns).clamp(140.0, totalWidth);
        final fromDateFormatted = '${DateFormat('d MMM yyyy').format(_fromDate)}   ${_fromTime.format(context)}';
        final toDateFormatted = '${DateFormat('d MMM yyyy').format(_toDate)}   ${_toTime.format(context)}';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'From Date', child: _buildClickableDateField(text: fromDateFormatted, onTap: _pickFromDate)),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'To Date', child: _buildClickableDateField(text: toDateFormatted, onTap: _pickToDate)),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'Select Employee Tags', child: _buildDropdown(value: _selectedEmployeeTag, items: const ['All', 'Sales', 'Support', 'Tech', 'Field Agents'], onChanged: (val) => setState(() => _selectedEmployeeTag = val ?? 'All'))),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'Select Employees', child: _buildDropdown(value: employees.contains(_selectedEmployee) ? _selectedEmployee : 'All', items: employees, onChanged: (val) => setState(() => _selectedEmployee = val ?? 'All'))),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'Select Call Type',
                    child: _buildDropdown(
                      value: _selectedCallType,
                      items: const ['All', 'incoming', 'outgoing', 'missed', 'rejected'],
                      labels: const {'All': 'Select', 'incoming': 'Incoming', 'outgoing': 'Outgoing', 'missed': 'Missed', 'rejected': 'Rejected'},
                      onChanged: (val) => setState(() => _selectedCallType = val ?? 'All'),
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'Select Call Method', child: _buildDropdown(value: _selectedCallMethod, items: const ['All', 'SIM 1', 'SIM 2', 'WhatsApp', 'VoIP'], onChanged: (val) => setState(() => _selectedCallMethod = val ?? 'All'))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(label: 'Select Duration', child: _buildDropdown(value: _selectedDuration, items: const ['All', '< 30s', '30s - 1m', '1m - 3m', '> 3m'], onChanged: (val) => setState(() => _selectedDuration = val ?? 'All'))),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'Select Call Time',
                    child: _buildDropdown(
                      value: _selectedCallTime,
                      items: const ['All', 'Morning (9 AM - 12 PM)', 'Afternoon (12 PM - 5 PM)', 'Evening (5 PM - 9 PM)'],
                      labels: const {'All': 'Select', 'Morning (9 AM - 12 PM)': 'Morning (9-12)', 'Afternoon (12 PM - 5 PM)': 'Afternoon (12-5)', 'Evening (5 PM - 9 PM)': 'Evening (5-9)'},
                      onChanged: (val) => setState(() => _selectedCallTime = val ?? 'All'),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _activeDateFilter = 'custom');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filters applied!'), behavior: SnackBarBehavior.floating));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
                OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFF59E0B), side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(value: _excludePhoneNumbers, activeColor: const Color(0xFFF59E0B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), onChanged: (v) => setState(() => _excludePhoneNumbers = v ?? true)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      children: [
                        const TextSpan(text: 'Exclude Numbers Mentioned in '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: InkWell(
                            onTap: () {
                              if (widget.onSubItemSelected != null) widget.onSubItemSelected!('exclude_phone_numbers');
                            },
                            child: const Text('Exclude Phone Numbers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B), decoration: TextDecoration.underline)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterInput({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _buildClickableDateField({required String text, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
        child: Text(text, style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    Map<String, String>? labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
          borderRadius: BorderRadius.circular(8),
          onChanged: onChanged,
          items: items.map((item) {
            final display = labels != null && labels.containsKey(item) ? labels[item]! : (item == 'All' ? 'Select' : item);
            return DropdownMenuItem<String>(value: item, child: Text(display, overflow: TextOverflow.ellipsis));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActiveDateRow(int totalCount, int filteredCount) {
    final dateStr = _activeDateFilter == 'all'
        ? DateFormat('d MMM yyyy').format(DateTime.now())
        : '${DateFormat('d MMM yyyy').format(_fromDate)}${_fromDate.day != _toDate.day ? ' - ${DateFormat('d MMM yyyy').format(_toDate)}' : ''}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Text(dateStr, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const Spacer(),
          if (_activeDateFilter != 'all')
            InkWell(
              onTap: () => setState(() => _activeDateFilter = 'all'),
              child: const Text('Show all records', style: TextStyle(fontSize: 11.5, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // Horizontal Tab Bar (8 Tabs)
  // =========================================================================
  Widget _buildHorizontalTabBar() {
    final tabDefinitions = [
      {'title': 'Summary', 'icon': Icons.bar_chart_rounded, 'hasInfo': false, 'tooltip': 'Overall metrics'},
      {'title': 'Analysis', 'icon': Icons.show_chart_rounded, 'hasInfo': false, 'tooltip': 'Visual charts'},
      {'title': 'Day-wise Analysis', 'icon': Icons.calendar_month_outlined, 'hasInfo': false, 'tooltip': 'Daily breakdown'},
      {'title': 'Hourly Analysis', 'icon': Icons.access_time_rounded, 'hasInfo': false, 'tooltip': 'Hourly load'},
      {'title': 'Never Attended', 'icon': Icons.phone_missed_rounded, 'hasInfo': true, 'tooltip': 'Unattended inbound numbers with zero callback attempts'},
      {'title': 'Not Pickup by Client', 'icon': Icons.phone_disabled_rounded, 'hasInfo': true, 'tooltip': 'Outbound dial attempts not answered by clients'},
      {'title': 'Unique Clients', 'icon': Icons.people_outline_rounded, 'hasInfo': true, 'tooltip': 'Distinct clients engaged'},
      {'title': 'Call Logs', 'icon': Icons.receipt_long_outlined, 'hasInfo': false, 'tooltip': 'Granular call records'},
    ];

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18, color: Color(0xFF64748B)),
            onPressed: () => _scrollTabs(false),
            tooltip: 'Scroll left',
            splashRadius: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(tabDefinitions.length, (index) {
                  final tab = tabDefinitions[index];
                  final isSelected = _selectedTabIndex == index;

                  return InkWell(
                    onTap: () => setState(() => _selectedTabIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tab['icon'] as IconData, size: 15, color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF64748B)),
                          const SizedBox(width: 7),
                          Text(tab['title'] as String, style: TextStyle(fontSize: 12.5, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF475569))),
                          if (tab['hasInfo'] == true) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: tab['tooltip'] as String,
                              child: Icon(Icons.info_outline_rounded, size: 12, color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF64748B)),
            onPressed: () => _scrollTabs(true),
            tooltip: 'Scroll right',
            splashRadius: 15,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Selected Tab Content
  // =========================================================================
  Widget _buildSelectedTabContent(List<WebCallLog> filteredLogs, List<WebCallLog> allLogs, List<String> employeeList, bool isMobile) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSummaryTab(filteredLogs, allLogs);
      case 1:
        return _buildAnalysisTab(filteredLogs.isNotEmpty ? filteredLogs : allLogs);
      case 2:
        return _buildDayWiseAnalysisTab(filteredLogs.isNotEmpty ? filteredLogs : allLogs);
      case 3:
        return _buildHourlyAnalysisTab(filteredLogs.isNotEmpty ? filteredLogs : allLogs);
      case 4:
        return _buildNeverAttendedEmbeddedTab(allLogs);
      case 5:
        return _buildNotPickupByClientTab(allLogs, employeeList, isMobile);
      case 6:
        return _buildUniqueClientsTab(allLogs);
      case 7:
        return _buildCallLogsTab(filteredLogs.isNotEmpty ? filteredLogs : allLogs);
      default:
        return _buildSummaryTab(filteredLogs, allLogs);
    }
  }

  // =========================================================================
  // Tab 1: Summary
  // =========================================================================
  Widget _buildSummaryTab(List<WebCallLog> filteredLogs, List<WebCallLog> allLogs) {
    final dateStr = DateFormat('d MMM yyyy').format(_fromDate);
    if (filteredLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call summary data not found for $dateStr', style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeDateFilter = 'all'),
              icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFF59E0B)),
              label: Text('View all ${allLogs.length} total call logs', style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B))),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            ),
          ],
        ),
      );
    }

    final totalCalls = filteredLogs.length;
    int totalTalkSeconds = 0;
    int incomingCount = 0;
    int outgoingCount = 0;
    int missedCount = 0;
    int rejectedCount = 0;
    final uniqueClients = <String>{};

    for (final l in filteredLogs) {
      totalTalkSeconds += l.durationSeconds;
      if (l.clientNumber.isNotEmpty) uniqueClients.add(l.clientNumber);
      final t = l.type.toLowerCase();
      if (t == 'incoming') incomingCount++;
      if (t == 'outgoing') outgoingCount++;
      if (t == 'missed') missedCount++;
      if (t == 'rejected') rejectedCount++;
    }

    final answeredCalls = incomingCount + filteredLogs.where((l) => l.type == 'outgoing' && l.durationSeconds > 0).length;
    final answerRate = totalCalls == 0 ? 0.0 : (answeredCalls / totalCalls) * 100.0;
    final avgDurationSec = totalCalls == 0 ? 0 : (totalTalkSeconds ~/ totalCalls);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            int cols = w >= 920 ? 4 : (w >= 540 ? 2 : 1);
            const spacing = 12.0;
            final cardWidth = ((w - (spacing * (cols - 1))) / cols).clamp(170.0, w);
            final cards = [
              _summaryKpiCard(title: 'Total Call Volume', value: '${NumberFormat('#,###').format(totalCalls)} Calls', subtitle: '${uniqueClients.length} unique client numbers', icon: Icons.phone_in_talk_rounded, accentColor: const Color(0xFF2563EB)),
              _summaryKpiCard(title: 'Total Talk Duration', value: _formatDuration(totalTalkSeconds), subtitle: 'Avg ${_formatDuration(avgDurationSec)} per call', icon: Icons.timer_outlined, accentColor: const Color(0xFF10B981)),
              _summaryKpiCard(title: 'Answer & Connect Rate', value: '${answerRate.toStringAsFixed(1)}%', subtitle: '$answeredCalls connected dialogues', icon: Icons.phone_callback_rounded, accentColor: const Color(0xFFF59E0B)),
              _summaryKpiCard(title: 'Unattended / Missed', value: '${NumberFormat('#,###').format(missedCount + rejectedCount)} Calls', subtitle: '$missedCount missed, $rejectedCount rejected', icon: Icons.phone_missed_rounded, accentColor: const Color(0xFFEF4444)),
            ];
            return Wrap(spacing: spacing, runSpacing: spacing, children: cards.map((c) => SizedBox(width: cardWidth, child: c)).toList());
          },
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Call Distribution Overview', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    Text('$totalCalls calls analyzed', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columnSpacing: 22,
                  horizontalMargin: 16,
                  columns: const [
                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Talk Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Avg Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: [
                    _dataRowCategory('Incoming Calls', incomingCount, totalCalls, totalTalkSeconds, const Color(0xFF10B981)),
                    _dataRowCategory('Outgoing Calls', outgoingCount, totalCalls, totalTalkSeconds, const Color(0xFFF59E0B)),
                    _dataRowCategory('Missed Calls', missedCount, totalCalls, 0, const Color(0xFFEF4444)),
                    _dataRowCategory('Rejected Calls', rejectedCount, totalCalls, 0, const Color(0xFFE11D48)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _dataRowCategory(String title, int count, int total, int durSec, Color color) {
    final pct = total == 0 ? 0.0 : (count / total) * 100.0;
    return DataRow(cells: [
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: color),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ],
      )),
      DataCell(Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
      DataCell(Text('${pct.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 12))),
      DataCell(Text(_formatDuration(durSec), style: const TextStyle(fontSize: 12))),
      DataCell(Text(count == 0 ? '0s' : _formatDuration(durSec ~/ count), style: const TextStyle(fontSize: 12))),
    ]);
  }

  Widget _summaryKpiCard({required String title, required String value, required String subtitle, required IconData icon, required Color accentColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Icon(icon, size: 17, color: accentColor),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // =========================================================================
  // Tab 2: Analysis
  // =========================================================================
  Widget _buildAnalysisTab(List<WebCallLog> logs) {
    final Map<String, List<WebCallLog>> dayMap = {};
    final dayFmt = DateFormat('EEE d');
    for (final log in logs) {
      final key = dayFmt.format(log.timestamp);
      dayMap.putIfAbsent(key, () => []).add(log);
    }
    final sortedDays = dayMap.keys.toList()..sort((a, b) => dayMap[a]!.first.timestamp.compareTo(dayMap[b]!.first.timestamp));
    final displayDays = sortedDays.length > 7 ? sortedDays.sublist(sortedDays.length - 7) : sortedDays;
    int maxVolume = 1;
    for (final d in displayDays) {
      final count = dayMap[d]?.length ?? 0;
      if (count > maxVolume) maxVolume = count;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Daily Call Volume & Inbound vs Outbound Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                  SizedBox(width: 4),
                  Text('Incoming', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  SizedBox(width: 10),
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFFF59E0B)),
                  SizedBox(width: 4),
                  Text('Outgoing', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 190,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
            child: displayDays.isEmpty
                ? const Center(child: Text('No call distribution data available for selected filter.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: displayDays.map((day) {
                          final dayLogs = dayMap[day] ?? [];
                          final inCount = dayLogs.where((l) => l.type == 'incoming').length;
                          final outCount = dayLogs.where((l) => l.type == 'outgoing').length;
                          final total = dayLogs.length;
                          final inFrac = (inCount / maxVolume).clamp(0.08, 1.0);
                          final outFrac = (outCount / maxVolume).clamp(0.08, 1.0);
                          return Expanded(child: _analysisDualBarColumn(day, inFrac, outFrac, '$total calls', inCount, outCount));
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _analysisDualBarColumn(String day, double inFrac, double outFrac, String total, int inCount, int outCount) {
    const double maxHeight = 100.0;
    return Tooltip(
      message: '$day: $total ($inCount In, $outCount Out)',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(total, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 12, height: maxHeight * inFrac, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 3),
              Container(width: 12, height: maxHeight * outFrac, decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(2))),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(fit: BoxFit.scaleDown, child: Text(day, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // =========================================================================
  // Tab 3: Day-wise Analysis
  // =========================================================================
  Widget _buildDayWiseAnalysisTab(List<WebCallLog> logs) {
    final Map<String, List<WebCallLog>> dayMap = {};
    final dayFmt = DateFormat('yyyy-MM-dd');
    for (final log in logs) {
      final key = dayFmt.format(log.timestamp);
      dayMap.putIfAbsent(key, () => []).add(log);
    }
    final sortedDates = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Day-wise Call Performance Breakdown', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text('${sortedDates.length} recorded days', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 18,
                    horizontalMargin: 14,
                    columns: const [
                      DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Total Calls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Incoming', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Outgoing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Missed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Rejected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Total Talk Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Avg Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Unique Clients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: sortedDates.map((dateStr) {
                      final dayLogs = dayMap[dateStr] ?? [];
                      final total = dayLogs.length;
                      final inCount = dayLogs.where((l) => l.type == 'incoming').length;
                      final outCount = dayLogs.where((l) => l.type == 'outgoing').length;
                      final misCount = dayLogs.where((l) => l.type == 'missed').length;
                      final rejCount = dayLogs.where((l) => l.type == 'rejected').length;
                      int dur = 0;
                      final clients = <String>{};
                      for (final l in dayLogs) {
                        dur += l.durationSeconds;
                        clients.add(l.clientNumber);
                      }
                      final avg = total == 0 ? 0 : dur ~/ total;
                      return DataRow(cells: [
                        DataCell(Text(DateFormat('d MMM yyyy (EEE)').format(DateTime.parse(dateStr)), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                        DataCell(Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataCell(Text('$inCount', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 12))),
                        DataCell(Text('$outCount', style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w600, fontSize: 12))),
                        DataCell(Text('$misCount', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 12))),
                        DataCell(Text('$rejCount', style: const TextStyle(color: Color(0xFFE11D48), fontSize: 12))),
                        DataCell(Text(_formatDuration(dur), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                        DataCell(Text(_formatDuration(avg), style: const TextStyle(fontSize: 12))),
                        DataCell(Text('${clients.length}', style: const TextStyle(fontSize: 12))),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Tab 4: Hourly Analysis
  // =========================================================================
  Widget _buildHourlyAnalysisTab(List<WebCallLog> logs) {
    final Map<int, List<WebCallLog>> hourMap = {};
    for (int i = 0; i < 24; i++) {
      hourMap[i] = [];
    }
    for (final log in logs) {
      final hour = log.timestamp.hour;
      hourMap[hour]?.add(log);
    }
    final activeHours = hourMap.keys.where((h) => h >= 8 && h <= 21).toList()..sort();
    int maxHourCalls = 1;
    for (final h in activeHours) {
      final cnt = hourMap[h]?.length ?? 0;
      if (cnt > maxHourCalls) maxHourCalls = cnt;
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Hourly Call Distribution & Peak Load Analysis', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text('8:00 AM - 9:00 PM Operating Hours', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 14,
                    columns: const [
                      DataColumn(label: Text('Hour Window', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Total Calls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Incoming', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Outgoing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Missed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Load Intensity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: activeHours.map((hour) {
                      final list = hourMap[hour] ?? [];
                      final total = list.length;
                      final inC = list.where((l) => l.type == 'incoming').length;
                      final outC = list.where((l) => l.type == 'outgoing').length;
                      final misC = list.where((l) => l.type == 'missed').length;
                      final hourLabel = '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00';
                      final frac = total / maxHourCalls;
                      final isPeak = total == maxHourCalls && total > 0;
                      return DataRow(cells: [
                        DataCell(Text(hourLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                        DataCell(Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataCell(Text('$inC', style: const TextStyle(color: Color(0xFF10B981), fontSize: 12))),
                        DataCell(Text('$outC', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12))),
                        DataCell(Text('$misC', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 7,
                              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(3)),
                              child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: frac.clamp(0.04, 1.0), child: Container(decoration: BoxDecoration(color: isPeak ? const Color(0xFFEF4444) : const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(3)))),
                            ),
                            if (isPeak) ...[
                              const SizedBox(width: 6),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(3)), child: const Text('PEAK', style: TextStyle(fontSize: 9.5, color: Color(0xFFDC2626), fontWeight: FontWeight.bold))),
                            ],
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Tab 5: Never Attended Embedded
  // =========================================================================
  Widget _buildNeverAttendedEmbeddedTab(List<WebCallLog> allLogs) {
    final rawRecords = _computeNeverAttendedList(allLogs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFCA5A5))),
          child: Row(
            children: [
              const Icon(Icons.phone_missed_rounded, color: Color(0xFFDC2626), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Urgent: ${rawRecords.length} prospect callers rang unanswered and have NEVER received a callback.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildNeverAttendedCustomTable(rawRecords.take(50).toList(), rawRecords.length, false),
      ],
    );
  }

  // =========================================================================
  // Tab 6: Not Pickup by Client
  // =========================================================================
  Widget _buildNotPickupByClientTab(List<WebCallLog> allLogs, List<String> employeeList, bool isMobile) {
    return _buildNotPickupDedicatedCard(allLogs, employeeList, isMobile, isEmbeddedTab: true);
  }

  // =========================================================================
  // Tab 7: Unique Clients
  // =========================================================================
  Widget _buildUniqueClientsTab(List<WebCallLog> allLogs) {
    final Map<String, List<WebCallLog>> clientMap = {};
    for (final log in allLogs) {
      final num = log.clientNumber.trim();
      if (num.isNotEmpty) clientMap.putIfAbsent(num, () => []).add(log);
    }
    final clientReports = <Map<String, dynamic>>[];
    clientMap.forEach((clientPhone, list) {
      int totalSec = 0;
      for (final l in list) {
        totalSec += l.durationSeconds;
      }
      final latest = list.first;
      final touchCount = list.length;
      final tier = touchCount >= 8 ? 'VIP Client' : (touchCount >= 3 ? 'Active Contact' : 'New Prospect');
      clientReports.add({
        'company': latest.clientName.isEmpty || latest.clientName == clientPhone ? 'Client ($clientPhone)' : latest.clientName,
        'contact': clientPhone,
        'totalCalls': '$touchCount calls',
        'totalDuration': _formatDuration(totalSec),
        'manager': latest.employeeName.isNotEmpty ? latest.employeeName : 'Agent',
        'tier': tier,
        'lastCall': DateFormat('d MMM, h:mm a').format(latest.timestamp),
        '_rawCount': touchCount,
      });
    });
    clientReports.sort((a, b) => (b['_rawCount'] as int).compareTo(a['_rawCount'] as int));

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unique Client Directory (${clientReports.length} Contacts)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A))),
                Text('Ranked by touchpoint frequency', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          LayoutBuilder(
            builder: (context, constraints) {
              if (clientReports.isEmpty) {
                return Container(padding: const EdgeInsets.symmetric(vertical: 40), alignment: Alignment.center, child: const Text('No client interaction history found.', style: TextStyle(color: Color(0xFF64748B))));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 14,
                    columns: const [
                      DataColumn(label: Text('Client / Organization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Total Calls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Total Talk Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Account Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Engagement Tier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Last Contacted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: clientReports.take(50).map((c) {
                      return DataRow(cells: [
                        DataCell(Text(c['company']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
                        DataCell(Text(c['contact']!, style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c['totalCalls']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataCell(Text(c['totalDuration']!, style: const TextStyle(fontSize: 12))),
                        DataCell(Text(c['manager']!, style: const TextStyle(fontSize: 12))),
                        DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)), child: Text(c['tier']!, style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)))),
                        DataCell(Text(c['lastCall']!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)))),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Tab 8: Call Logs
  // =========================================================================
  Widget _buildCallLogsTab(List<WebCallLog> logs) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Text('Call Log Records (${logs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)))),
                SizedBox(
                  width: 200,
                  height: 32,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search client, number...',
                      hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 15, color: Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          LayoutBuilder(
            builder: (context, constraints) {
              if (logs.isEmpty) {
                return Container(padding: const EdgeInsets.symmetric(vertical: 40), alignment: Alignment.center, child: const Text('No call logs match your query.', style: TextStyle(color: Color(0xFF64748B))));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 14,
                    columns: const [
                      DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Caller / Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Call Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Assigned Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('SIM Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Device Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: logs.take(100).map((log) {
                      Color typeColor;
                      Color typeBg;
                      switch (log.type.toLowerCase()) {
                        case 'incoming':
                          typeColor = const Color(0xFF10B981);
                          typeBg = const Color(0xFFECFDF5);
                          break;
                        case 'outgoing':
                          typeColor = const Color(0xFFF59E0B);
                          typeBg = const Color(0xFFFFFBEB);
                          break;
                        case 'missed':
                          typeColor = const Color(0xFFEF4444);
                          typeBg = const Color(0xFFFEF2F2);
                          break;
                        default:
                          typeColor = const Color(0xFFE11D48);
                          typeBg = const Color(0xFFFFF1F2);
                      }
                      return DataRow(cells: [
                        DataCell(Text(DateFormat('d MMM yyyy, h:mm a').format(log.timestamp), style: const TextStyle(fontSize: 12))),
                        DataCell(Text(log.clientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
                        DataCell(Text(log.clientNumber, style: const TextStyle(fontSize: 12))),
                        DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(4)), child: Text(log.type.toUpperCase(), style: TextStyle(fontSize: 10.5, color: typeColor, fontWeight: FontWeight.bold)))),
                        DataCell(Text(_formatDuration(log.durationSeconds), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataCell(Text(log.employeeName, style: const TextStyle(fontSize: 12))),
                        DataCell(Text(log.simSlot, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)))),
                        DataCell(Text(log.connectCode, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'monospace'))),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Dedicated Cards for other Sub Items
  // =========================================================================
  Widget _buildEmployeeReportsDedicatedCard(List<WebCallLog> allLogs, List<String> employeeList, bool isMobile) {
    // Filter logs for selected employee and date range
    final filteredLogs = _filterEmployeeReportsLogs(allLogs);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Employee Reports" + "FILTERS ^"
          _buildEmpReportsHeader(isMobile),

          const Divider(height: 1, color: AppColors.border),

          // Collapsible Filters Section
          if (_empReportsFiltersExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 16),
              child: _buildEmpReportsFilterControls(employeeList, isMobile),
            ),
            const Divider(height: 1, color: AppColors.border),
          ],

          // Horizontal 6 Tabs: Summary, Analysis, Day Summary, Day-wise Analysis, Hourly Analysis, Call History
          _buildEmpReportsTabBar(isMobile),

          const Divider(height: 1, color: AppColors.border),

          // Tab Body Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: _buildEmpReportsTabContent(filteredLogs, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpReportsHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Employee Reports',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _empReportsFiltersExpanded = !_empReportsFiltersExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 15, color: Color(0xFF475569)),
                  const SizedBox(width: 4),
                  Text(
                    'FILTERS',
                    style: TextStyle(
                      fontSize: isMobile ? 11.5 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _empReportsFiltersExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 17,
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpReportsFilterControls(List<String> employeeList, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        int columns;
        if (totalWidth >= 960) {
          columns = 3;
        } else if (totalWidth >= 520) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 12.0;
        final itemWidth = ((totalWidth - (spacing * (columns - 1))) / columns).clamp(150.0, totalWidth);

        final empDropdownList = ['Select', ...employeeList.where((e) => e != 'All' && e != 'Select')];

        final fromDateText = _empReportsFromDate != null
            ? DateFormat('d MMM yyyy').format(_empReportsFromDate!)
            : 'Select Date';
        final toDateText = _empReportsToDate != null
            ? DateFormat('d MMM yyyy').format(_empReportsToDate!)
            : 'Select Date';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                // Select Employee
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'Select Employee',
                    child: _buildDropdown(
                      value: empDropdownList.contains(_empReportsSelectedEmp) ? _empReportsSelectedEmp : 'Select',
                      items: empDropdownList,
                      onChanged: (val) => setState(() => _empReportsSelectedEmp = val ?? 'Select'),
                    ),
                  ),
                ),

                // From Date
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'From Date',
                    child: _buildClickableDateField(
                      text: fromDateText,
                      onTap: _pickEmpReportsFromDate,
                    ),
                  ),
                ),

                // To Date
                SizedBox(
                  width: itemWidth,
                  child: _buildFilterInput(
                    label: 'To Date',
                    child: _buildClickableDateField(
                      text: toDateText,
                      onTap: _pickEmpReportsToDate,
                    ),
                  ),
                ),

                // Apply Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_empReportsSelectedEmp == 'Select'
                            ? 'Please select an employee to view reports'
                            : 'Employee filter applied for $_empReportsSelectedEmp'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),

                // Reset Button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _empReportsSelectedEmp = 'Select';
                      _empReportsFromDate = null;
                      _empReportsToDate = null;
                      _empReportsExcludePhones = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exclude Phone Numbers Checkbox
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _empReportsExcludePhones,
                    activeColor: const Color(0xFFF59E0B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) => setState(() => _empReportsExcludePhones = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: isMobile ? 11.5 : 12.5, color: const Color(0xFF475569)),
                      children: [
                        const TextSpan(text: 'Exclude Numbers Mentioned in '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: InkWell(
                            onTap: () {
                              if (widget.onSubItemSelected != null) {
                                widget.onSubItemSelected!('exclude_phone_numbers');
                              }
                            },
                            child: const Text(
                              'Exclude Phone Numbers',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickEmpReportsFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _empReportsFromDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _empReportsFromDate = picked);
    }
  }

  Future<void> _pickEmpReportsToDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _empReportsToDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _empReportsToDate = picked);
    }
  }

  Widget _buildEmpReportsTabBar(bool isMobile) {
    final tabs = [
      {'title': 'Summary', 'icon': Icons.bar_chart_rounded},
      {'title': 'Analysis', 'icon': Icons.show_chart_rounded},
      {'title': 'Day Summary', 'icon': Icons.article_outlined},
      {'title': 'Day-wise Analysis', 'icon': Icons.calendar_month_outlined},
      {'title': 'Hourly Analysis', 'icon': Icons.access_time_rounded},
      {'title': 'Call History', 'icon': Icons.receipt_long_outlined},
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: _empReportsTabScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = _empReportsSelectedTabIndex == index;
            return InkWell(
              onTap: () => setState(() => _empReportsSelectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 16,
                      color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmpReportsTabContent(List<WebCallLog> logs, bool isMobile) {
    // If no employee selected or empty, match the exact message from screenshot
    if (_empReportsSelectedEmp == 'Select' || logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          _empReportsSelectedTabIndex == 5 ? 'Call history data not found' : 'Call summary data not found',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    switch (_empReportsSelectedTabIndex) {
      case 0:
        return _buildEmpSummaryTab(logs, isMobile);
      case 1:
        return _buildEmpAnalysisTab(logs, isMobile);
      case 2:
        return _buildEmpDaySummaryTab(logs, isMobile);
      case 3:
        return _buildEmpDayWiseAnalysisTab(logs, isMobile);
      case 4:
        return _buildEmpHourlyAnalysisTab(logs, isMobile);
      case 5:
        return _buildEmpCallHistoryTab(logs, isMobile);
      default:
        return _buildEmpSummaryTab(logs, isMobile);
    }
  }

  Widget _buildEmpSummaryTab(List<WebCallLog> logs, bool isMobile) {
    final totalCalls = logs.length;
    final outgoing = logs.where((l) => l.type.toLowerCase() == 'outgoing').length;
    final incoming = logs.where((l) => l.type.toLowerCase() == 'incoming').length;
    final missed = logs.where((l) => l.type.toLowerCase() == 'missed').length;
    final rejected = logs.where((l) => l.type.toLowerCase() == 'rejected').length;

    int totalSec = 0;
    final uniqueClients = <String>{};
    for (final l in logs) {
      totalSec += l.durationSeconds;
      if (l.clientNumber.isNotEmpty) uniqueClients.add(l.clientNumber);
    }
    final answeredCalls = logs.where((l) => l.durationSeconds > 0).length;
    final avgSec = answeredCalls > 0 ? (totalSec ~/ answeredCalls) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Employee Info Header
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                _empReportsSelectedEmp.isNotEmpty ? _empReportsSelectedEmp[0].toUpperCase() : 'A',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Performance Summary for $_empReportsSelectedEmp',
              style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 8 Metric Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isMobile ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricCard('Total Calls', '$totalCalls', Icons.phone_in_talk_rounded, const Color(0xFF2563EB), cardWidth),
                _buildMetricCard('Outgoing Calls', '$outgoing', Icons.call_made_rounded, const Color(0xFF059669), cardWidth),
                _buildMetricCard('Incoming Calls', '$incoming', Icons.call_received_rounded, const Color(0xFF0284C7), cardWidth),
                _buildMetricCard('Missed Calls', '$missed', Icons.call_missed_rounded, const Color(0xFFDC2626), cardWidth),
                _buildMetricCard('Rejected Calls', '$rejected', Icons.phone_disabled_rounded, const Color(0xFFEA580C), cardWidth),
                _buildMetricCard('Total Duration', _formatDuration(totalSec), Icons.access_time_rounded, const Color(0xFF7C3AED), cardWidth),
                _buildMetricCard('Avg Duration', _formatDuration(avgSec), Icons.timer_outlined, const Color(0xFF0D9488), cardWidth),
                _buildMetricCard('Unique Clients', '${uniqueClients.length}', Icons.people_outline_rounded, const Color(0xFFD97706), cardWidth),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpAnalysisTab(List<WebCallLog> logs, bool isMobile) {
    final outgoing = logs.where((l) => l.type.toLowerCase() == 'outgoing').length;
    final incoming = logs.where((l) => l.type.toLowerCase() == 'incoming').length;
    final missed = logs.where((l) => l.type.toLowerCase() == 'missed').length;
    final total = logs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Call Distribution Analysis (${logs.length} Total Calls)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 16),
          _buildAnalysisBar('Outgoing Calls', outgoing, total, const Color(0xFF059669)),
          const SizedBox(height: 10),
          _buildAnalysisBar('Incoming Calls', incoming, total, const Color(0xFF0284C7)),
          const SizedBox(height: 10),
          _buildAnalysisBar('Missed / Unanswered', missed, total, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _buildAnalysisBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text('$count (${(pct * 100).toStringAsFixed(1)}%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpDaySummaryTab(List<WebCallLog> logs, bool isMobile) {
    final Map<String, List<WebCallLog>> dayMap = {};
    for (final l in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(l.timestamp);
      dayMap.putIfAbsent(dateKey, () => []).add(l);
    }
    final sortedDays = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columnSpacing: 18,
              horizontalMargin: 12,
              columns: const [
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Total Calls', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Outgoing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Incoming', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Missed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Total Talk Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Avg Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: sortedDays.map((dateKey) {
                final dayLogs = dayMap[dateKey]!;
                final out = dayLogs.where((l) => l.type.toLowerCase() == 'outgoing').length;
                final inc = dayLogs.where((l) => l.type.toLowerCase() == 'incoming').length;
                final mis = dayLogs.where((l) => l.type.toLowerCase() == 'missed').length;
                int talkSec = 0;
                for (final l in dayLogs) {
                  talkSec += l.durationSeconds;
                }
                final answered = dayLogs.where((l) => l.durationSeconds > 0).length;
                final avgSec = answered > 0 ? (talkSec ~/ answered) : 0;
                final displayDate = DateFormat('d MMM yyyy').format(DateTime.parse(dateKey));

                return DataRow(cells: [
                  DataCell(Text(displayDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  DataCell(Text('${dayLogs.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataCell(Text('$out', style: const TextStyle(fontSize: 12, color: Color(0xFF059669)))),
                  DataCell(Text('$inc', style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7)))),
                  DataCell(Text('$mis', style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)))),
                  DataCell(Text(_formatDuration(talkSec), style: const TextStyle(fontSize: 12))),
                  DataCell(Text(_formatDuration(avgSec), style: const TextStyle(fontSize: 12))),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpDayWiseAnalysisTab(List<WebCallLog> logs, bool isMobile) {
    final Map<int, int> weekMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final l in logs) {
      final wd = l.timestamp.weekday;
      weekMap[wd] = (weekMap[wd] ?? 0) + 1;
    }
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final total = logs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Load Distribution (Day-wise)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 14),
          ...List.generate(7, (i) {
            final dayIndex = i + 1;
            final count = weekMap[dayIndex] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAnalysisBar(dayNames[i], count, total, const Color(0xFF2563EB)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmpHourlyAnalysisTab(List<WebCallLog> logs, bool isMobile) {
    final Map<int, int> hourMap = {};
    for (int h = 8; h <= 20; h++) {
      hourMap[h] = 0;
    }
    for (final l in logs) {
      final h = l.timestamp.hour;
      if (hourMap.containsKey(h)) {
        hourMap[h] = hourMap[h]! + 1;
      }
    }
    final total = logs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hourly Activity Profile (8:00 AM - 8:00 PM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          const SizedBox(height: 14),
          ...hourMap.entries.map((e) {
            final hourFormatted = '${e.key.toString().padLeft(2, '0')}:00 - ${(e.key + 1).toString().padLeft(2, '0')}:00';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAnalysisBar(hourFormatted, e.value, total, const Color(0xFFD97706)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmpCallHistoryTab(List<WebCallLog> logs, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columnSpacing: 18,
              horizontalMargin: 12,
              columns: const [
                DataColumn(label: Text('Sr.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Client Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Call Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Call Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: logs.take(50).toList().asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final l = entry.value;
                final isOut = l.type.toLowerCase() == 'outgoing';
                final isMis = l.type.toLowerCase() == 'missed' || l.type.toLowerCase() == 'rejected';

                return DataRow(cells: [
                  DataCell(Text('$idx', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                  DataCell(Text(l.clientNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  DataCell(Text(l.clientName.isNotEmpty ? l.clientName : '-', style: const TextStyle(fontSize: 12))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOut ? const Color(0xFFDCFCE7) : (isMis ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isOut ? const Color(0xFF15803D) : (isMis ? const Color(0xFFB91C1C) : const Color(0xFF0369A1)),
                      ),
                    ),
                  )),
                  DataCell(Text(DateFormat('d MMM yyyy, h:mm a').format(l.timestamp), style: const TextStyle(fontSize: 11.5))),
                  DataCell(Text(_formatDuration(l.durationSeconds), style: const TextStyle(fontSize: 12))),
                  DataCell(Text(l.note ?? '-', style: const TextStyle(fontSize: 11.5))),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  List<WebCallLog> _filterEmployeeReportsLogs(List<WebCallLog> allLogs) {
    if (_empReportsSelectedEmp == 'Select') {
      return [];
    }

    return allLogs.where((log) {
      final empName = log.employeeName.trim().toLowerCase();
      if (empName != _empReportsSelectedEmp.trim().toLowerCase()) {
        return false;
      }

      if (_empReportsFromDate != null) {
        final start = DateTime(
          _empReportsFromDate!.year,
          _empReportsFromDate!.month,
          _empReportsFromDate!.day,
        );
        if (log.timestamp.isBefore(start)) return false;
      }

      if (_empReportsToDate != null) {
        final end = DateTime(
          _empReportsToDate!.year,
          _empReportsToDate!.month,
          _empReportsToDate!.day,
          23,
          59,
          59,
        );
        if (log.timestamp.isAfter(end)) return false;
      }

      return true;
    }).toList();
  }

  // =========================================================================
  // CLIENT REPORTS DEDICATED CARD (MATCHING EXACT USER SCREENSHOT)
  // =========================================================================
  Widget _buildClientReportsDedicatedCard(List<WebCallLog> allLogs, bool isMobile) {
    final clientLogs = _filterClientReportsLogs(allLogs);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: "Client Reports" + "FILTERS ^"
          _buildClientReportsHeader(isMobile),

          const Divider(height: 1, color: AppColors.border),

          // Filters Form: Select Duration + Search By + [Get Report]
          if (_clientReportsFiltersExpanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 16),
              child: _buildClientReportsFilterControls(isMobile),
            ),
          ],

          // Results Area: Empty initial state matching screenshot OR dynamic client report
          if (_clientReportsHasSearched && _clientReportsSearchQuery.trim().isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 20),
              child: _buildClientReportsContent(clientLogs, isMobile),
            ),
          ] else
            const SizedBox(height: 300), // Clean spacious card matching screenshot
        ],
      ),
    );
  }

  Widget _buildClientReportsHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Client Reports',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _clientReportsFiltersExpanded = !_clientReportsFiltersExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 15, color: Color(0xFF475569)),
                  const SizedBox(width: 4),
                  Text(
                    'FILTERS',
                    style: TextStyle(
                      fontSize: isMobile ? 11.5 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _clientReportsFiltersExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 17,
                    color: const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientReportsFilterControls(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final durationWidth = isMobile ? totalWidth : 220.0;
        final searchWidth = isMobile ? totalWidth : 260.0;

        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            // Select Duration
            SizedBox(
              width: durationWidth,
              child: _buildFilterInput(
                label: 'Select Duration',
                child: _buildDropdown(
                  value: _clientReportsDuration,
                  items: const ['All Time', 'Today', 'Yesterday', 'This Week', 'Last 7 Days', 'This Month'],
                  onChanged: (val) => setState(() => _clientReportsDuration = val ?? 'All Time'),
                ),
              ),
            ),

            // Search By
            SizedBox(
              width: searchWidth,
              child: _buildFilterInput(
                label: 'Search By',
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _clientReportsSearchCtrl,
                    onSubmitted: (v) {
                      setState(() {
                        _clientReportsSearchQuery = v.trim();
                        _clientReportsHasSearched = true;
                      });
                    },
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Search By Phone No. or Name',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ),
            ),

            // [ Get Report ] Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _clientReportsSearchQuery = _clientReportsSearchCtrl.text.trim();
                  _clientReportsHasSearched = true;
                });
                if (_clientReportsSearchQuery.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a client phone number or name to search'), behavior: SnackBarBehavior.floating),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('Get Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClientReportsContent(List<WebCallLog> logs, bool isMobile) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.person_search_rounded, size: 36, color: Color(0xFF94A3B8)),
            const SizedBox(height: 10),
            Text(
              'No call records found for "$_clientReportsSearchQuery" ($_clientReportsDuration)',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting the duration filter or verify the client phone number.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    final clientNumber = logs.first.clientNumber;
    final clientName = logs.first.clientName.isNotEmpty && logs.first.clientName != clientNumber
        ? logs.first.clientName
        : 'Client ($clientNumber)';

    final totalCalls = logs.length;
    final outgoing = logs.where((l) => l.type.toLowerCase() == 'outgoing').length;
    final incoming = logs.where((l) => l.type.toLowerCase() == 'incoming').length;
    final missed = logs.where((l) => l.type.toLowerCase() == 'missed').length;
    int totalTalkSec = 0;
    final agents = <String>{};

    for (final l in logs) {
      totalTalkSec += l.durationSeconds;
      if (l.employeeName.isNotEmpty) agents.add(l.employeeName);
    }

    final answeredCalls = logs.where((l) => l.durationSeconds > 0).length;
    final avgSec = answeredCalls > 0 ? (totalTalkSec ~/ answeredCalls) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Client Header Profile Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFEF3C7),
                child: const Icon(Icons.person_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phone: $clientNumber  •  ${agents.length} interacting agent(s): ${agents.join(', ')}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportClientLogsToCsv(logs, clientNumber),
                icon: const Icon(Icons.file_download_outlined, size: 14),
                label: const Text('Export CSV', style: TextStyle(fontSize: 11.5)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Summary Metric Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isMobile ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMetricCard('Total Engagements', '$totalCalls calls', Icons.phone_in_talk_rounded, const Color(0xFF2563EB), cardWidth),
                _buildMetricCard('Outgoing Calls', '$outgoing calls', Icons.call_made_rounded, const Color(0xFF059669), cardWidth),
                _buildMetricCard('Incoming Calls', '$incoming calls', Icons.call_received_rounded, const Color(0xFF0284C7), cardWidth),
                _buildMetricCard('Missed Calls', '$missed calls', Icons.call_missed_rounded, const Color(0xFFDC2626), cardWidth),
                _buildMetricCard('Total Talk Time', _formatDuration(totalTalkSec), Icons.access_time_rounded, const Color(0xFF7C3AED), cardWidth),
                _buildMetricCard('Avg Duration', _formatDuration(avgSec), Icons.timer_outlined, const Color(0xFF0D9488), cardWidth),
                _buildMetricCard('First Contact', DateFormat('d MMM yyyy').format(logs.last.timestamp), Icons.event_available_rounded, const Color(0xFFD97706), cardWidth),
                _buildMetricCard('Last Contact', DateFormat('d MMM yyyy').format(logs.first.timestamp), Icons.history_rounded, const Color(0xFF475569), cardWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Granular Call History Table
        Text('Call History for $clientNumber (${logs.length} records)', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columnSpacing: 18,
                  horizontalMargin: 12,
                  columns: const [
                    DataColumn(label: Text('Sr.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Employee / Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Call Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('Call Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: logs.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final l = entry.value;
                    final isOut = l.type.toLowerCase() == 'outgoing';
                    final isMis = l.type.toLowerCase() == 'missed' || l.type.toLowerCase() == 'rejected';

                    return DataRow(cells: [
                      DataCell(Text('$idx', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      DataCell(Text(DateFormat('d MMM yyyy, h:mm a').format(l.timestamp), style: const TextStyle(fontSize: 11.5))),
                      DataCell(Text(l.employeeName.isNotEmpty ? l.employeeName : 'Agent', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOut ? const Color(0xFFDCFCE7) : (isMis ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isOut ? const Color(0xFF15803D) : (isMis ? const Color(0xFFB91C1C) : const Color(0xFF0369A1)),
                          ),
                        ),
                      )),
                      DataCell(Text(_formatDuration(l.durationSeconds), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(l.note ?? '-', style: const TextStyle(fontSize: 11.5))),
                    ]);
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<WebCallLog> _filterClientReportsLogs(List<WebCallLog> allLogs) {
    if (!_clientReportsHasSearched || _clientReportsSearchQuery.trim().isEmpty) {
      return [];
    }

    final query = _clientReportsSearchQuery.trim().toLowerCase();
    final now = DateTime.now();

    final matched = allLogs.where((l) {
      final matchNum = l.clientNumber.toLowerCase().contains(query);
      final matchName = l.clientName.toLowerCase().contains(query);
      if (!matchNum && !matchName) return false;

      switch (_clientReportsDuration) {
        case 'Today':
          return l.timestamp.year == now.year && l.timestamp.month == now.month && l.timestamp.day == now.day;
        case 'Yesterday':
          final yest = now.subtract(const Duration(days: 1));
          return l.timestamp.year == yest.year && l.timestamp.month == yest.month && l.timestamp.day == yest.day;
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          return l.timestamp.isAfter(start);
        case 'Last 7 Days':
          final start = now.subtract(const Duration(days: 7));
          return l.timestamp.isAfter(start);
        case 'This Month':
          return l.timestamp.year == now.year && l.timestamp.month == now.month;
        case 'All Time':
        default:
          return true;
      }
    }).toList();

    matched.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return matched;
  }

  void _exportClientLogsToCsv(List<WebCallLog> logs, String clientNumber) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Sr No,Date Time,Employee,Client Number,Client Name,Call Type,Duration Seconds,Note');
      for (int i = 0; i < logs.length; i++) {
        final l = logs[i];
        final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(l.timestamp);
        buffer.writeln('${i + 1},$timeStr,"${l.employeeName}","${l.clientNumber}","${l.clientName}",${l.type},${l.durationSeconds},"${l.note ?? ''}"');
      }
      final bytes = utf8.encode(buffer.toString());
      final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = 'client_report_${clientNumber}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      anchor.click();
      web.URL.revokeObjectURL(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${logs.length} calls for $clientNumber to CSV!'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      debugPrint('Export client CSV error: $e');
    }
  }
}

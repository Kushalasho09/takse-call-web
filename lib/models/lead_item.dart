class CallActivityItem {
  final String id;
  final String callType; // "outgoing", "incoming", "missed", "rejected"
  final String callerName;
  final int durationSeconds;
  final int ringingSeconds;
  final String? previousStatus;
  final String newStatus;
  final String notes;
  final String timestamp;
  final String? reminderDate;

  CallActivityItem({
    required this.id,
    required this.callType,
    required this.callerName,
    required this.durationSeconds,
    this.ringingSeconds = 15,
    this.previousStatus,
    required this.newStatus,
    required this.notes,
    required this.timestamp,
    this.reminderDate,
  });
}

class LeadItem {
  final String id;
  final int srNo;
  final int leadNumber;
  final String name;
  final String phone;
  final String? altPhone;
  final String createdDate;
  final String? modifiedDate;
  final int attempts;
  final List<String> tags;
  final String tagAssignedDate;
  String assignedTo;
  String assignedToPhone;
  final String assignedDate;
  final String status;
  final String? reminderDate;
  final String? lastCallEmployee;
  final String lastCallType;
  final String lastCallTime;
  final String? lastCallDuration;
  final String? lastCallSummary;
  final String? company;
  final String? email;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? zipcode;
  final String? country;
  final String? description;
  final String? source;
  final String? price;
  final bool mapCallLogs;
  final Map<String, dynamic> customFormData;
  final List<CallActivityItem> activityHistory;
  bool isTrashed;
  bool isSelected;

  LeadItem({
    required this.id,
    required this.srNo,
    int? leadNumber,
    required this.name,
    required this.phone,
    this.altPhone,
    required this.createdDate,
    this.modifiedDate,
    this.attempts = 0,
    required this.tags,
    required this.tagAssignedDate,
    required this.assignedTo,
    required this.assignedToPhone,
    required this.assignedDate,
    required this.status,
    this.reminderDate,
    this.lastCallEmployee,
    this.lastCallType = '-',
    this.lastCallTime = '(Never Contacted)',
    this.lastCallDuration = '-',
    this.lastCallSummary,
    this.company,
    this.email,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zipcode,
    this.country = 'India',
    this.description,
    this.source,
    this.price,
    this.mapCallLogs = true,
    Map<String, dynamic>? customFormData,
    List<CallActivityItem>? activityHistory,
    this.isTrashed = false,
    this.isSelected = false,
  })  : leadNumber = leadNumber ?? srNo,
        customFormData = customFormData ?? {},
        activityHistory = activityHistory ?? [];

  LeadItem copyWith({
    String? id,
    int? srNo,
    int? leadNumber,
    String? name,
    String? phone,
    String? altPhone,
    String? createdDate,
    String? modifiedDate,
    int? attempts,
    List<String>? tags,
    String? tagAssignedDate,
    String? assignedTo,
    String? assignedToPhone,
    String? assignedDate,
    String? status,
    String? reminderDate,
    String? lastCallEmployee,
    String? lastCallType,
    String? lastCallTime,
    String? lastCallDuration,
    String? lastCallSummary,
    String? company,
    String? email,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zipcode,
    String? country,
    String? description,
    String? source,
    String? price,
    bool? mapCallLogs,
    Map<String, dynamic>? customFormData,
    List<CallActivityItem>? activityHistory,
    bool? isTrashed,
    bool? isSelected,
  }) {
    return LeadItem(
      id: id ?? this.id,
      srNo: srNo ?? this.srNo,
      leadNumber: leadNumber ?? this.leadNumber,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      attempts: attempts ?? this.attempts,
      tags: tags ?? this.tags,
      tagAssignedDate: tagAssignedDate ?? this.tagAssignedDate,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToPhone: assignedToPhone ?? this.assignedToPhone,
      assignedDate: assignedDate ?? this.assignedDate,
      status: status ?? this.status,
      reminderDate: reminderDate ?? this.reminderDate,
      lastCallEmployee: lastCallEmployee ?? this.lastCallEmployee,
      lastCallType: lastCallType ?? this.lastCallType,
      lastCallTime: lastCallTime ?? this.lastCallTime,
      lastCallDuration: lastCallDuration ?? this.lastCallDuration,
      lastCallSummary: lastCallSummary ?? this.lastCallSummary,
      company: company ?? this.company,
      email: email ?? this.email,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipcode: zipcode ?? this.zipcode,
      country: country ?? this.country,
      description: description ?? this.description,
      source: source ?? this.source,
      price: price ?? this.price,
      mapCallLogs: mapCallLogs ?? this.mapCallLogs,
      customFormData: customFormData ?? this.customFormData,
      activityHistory: activityHistory ?? this.activityHistory,
      isTrashed: isTrashed ?? this.isTrashed,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory LeadItem.fromFirestore(Map<String, dynamic> data, String docId, int index) {
    final tagsList = (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    String formatTime(dynamic ts) {
      if (ts == null) return '(Never Contacted)';
      if (ts is String) return ts;
      return ts.toString();
    }

    return LeadItem(
      id: docId,
      srNo: index + 1,
      leadNumber: index + 1,
      name: data['name'] ?? data['firstName'] ?? 'Lead',
      phone: data['phoneNumber'] ?? data['phone'] ?? '',
      altPhone: data['altPhone'] ?? data['alternatePhone'],
      createdDate: data['createdDate'] ?? '23 Sep 2026',
      modifiedDate: data['updatedAt'] != null ? 'Live Sync' : null,
      attempts: data['attempts'] is int ? data['attempts'] : 1,
      tags: tagsList.isNotEmpty ? tagsList : ['Inbound'],
      tagAssignedDate: data['tagAssignedDate'] ?? '23 Sep 2026',
      assignedTo: data['assignedTo'] ?? 'Kushal Asodia',
      assignedToPhone: data['assignedToPhone'] ?? '+91 9081444096',
      assignedDate: data['assignedDate'] ?? '23 Sep 2026, 10:00 AM',
      status: data['status'] ?? 'New Inflow',
      reminderDate: data['reminderDate']?.toString(),
      lastCallEmployee: data['assignedTo'],
      lastCallType: data['lastCallType'] ?? 'outgoing',
      lastCallTime: formatTime(data['lastCallTime']),
      lastCallDuration: data['lastCallDuration'] != null ? '${data['lastCallDuration']}s' : '-',
      lastCallSummary: data['notes'] ?? data['description'],
      company: data['companyName'] ?? data['company'],
      email: data['email'],
      description: data['notes'] ?? data['description'],
      isTrashed: data['isTrashed'] == true,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phone,
      'altPhone': altPhone,
      'status': status,
      'tags': tags,
      'notes': description,
      'description': description,
      'reminderDate': reminderDate,
      'assignedTo': assignedTo,
      'assignedToPhone': assignedToPhone,
      'companyName': company,
      'lastCallType': lastCallType,
      'lastCallDuration': lastCallDuration,
      'lastCallTime': lastCallTime,
      'attempts': attempts,
      'isTrashed': isTrashed,
    };
  }

  static List<LeadItem> initialSampleLeads() {
    return [
      LeadItem(
        id: 'lead_1',
        srNo: 1,
        leadNumber: 1,
        name: 'manish asodia',
        phone: '+91 9376661542',
        createdDate: '22 Sep 2026, 11:17 PM',
        modifiedDate: null,
        attempts: 2,
        tags: ['New', 'Hot Lead'],
        tagAssignedDate: '22 Sep 2026',
        assignedTo: 'kushal asodia',
        assignedToPhone: '+91-9664579043',
        assignedDate: '22 Sep 2026 | 11:17 PM',
        status: 'Positive',
        reminderDate: '24 Sep 2026, 03:00 PM',
        lastCallEmployee: 'kushal asodia',
        lastCallType: 'Outgoing',
        lastCallTime: '23 Sep 2026, 10:45 AM',
        lastCallDuration: '02m 34s',
        lastCallSummary: 'Client requested demo session for 5 agents',
        company: 'Asodia Enterprises',
        email: 'manish@asodia.com',
        source: 'Website Form',
        price: '₹ 45,000',
        customFormData: {
          'budget_range': '₹25,000 - ₹50,000',
          'team_size': '10-25',
          'priority': 'High',
        },
        activityHistory: [
          CallActivityItem(
            id: 'act_1',
            callType: 'outgoing',
            callerName: 'kushal asodia',
            durationSeconds: 154,
            previousStatus: 'New Inflow',
            newStatus: 'Positive',
            notes: 'Explained CRM features and automated call logging. Scheduled follow-up demo.',
            timestamp: '23 Sep 2026, 10:45 AM',
            reminderDate: '24 Sep 2026, 03:00 PM',
          ),
          CallActivityItem(
            id: 'act_0',
            callType: 'missed',
            callerName: 'kushal asodia',
            durationSeconds: 0,
            previousStatus: 'New Inflow',
            newStatus: 'New Inflow',
            notes: 'First dial went unanswered after 4 rings.',
            timestamp: '22 Sep 2026, 11:40 PM',
          ),
        ],
      ),
      LeadItem(
        id: 'lead_2',
        srNo: 2,
        leadNumber: 2,
        name: 'priya verma',
        phone: '+91 97123 45678',
        createdDate: '21 Sep 2026, 04:30 PM',
        attempts: 1,
        tags: ['Instagram', 'Urgent'],
        tagAssignedDate: '21 Sep 2026',
        assignedTo: 'Rohan Sharma',
        assignedToPhone: '+91-9876543210',
        assignedDate: '21 Sep 2026 | 04:30 PM',
        status: 'Follow Up',
        reminderDate: '25 Sep 2026, 11:00 AM',
        lastCallEmployee: 'Rohan Sharma',
        lastCallType: 'Outgoing',
        lastCallTime: '22 Sep 2026, 02:15 PM',
        lastCallDuration: '01m 12s',
        lastCallSummary: 'Call back requested after internal discussion',
        company: 'Verma Design Studio',
        email: 'priya@verma.design',
        source: 'FB & Insta Ads',
        price: '₹ 80,000',
        activityHistory: [
          CallActivityItem(
            id: 'act_2',
            callType: 'outgoing',
            callerName: 'Rohan Sharma',
            durationSeconds: 72,
            previousStatus: 'New Inflow',
            newStatus: 'Follow Up',
            notes: 'Requested brochure and pricing tiers via WhatsApp.',
            timestamp: '22 Sep 2026, 02:15 PM',
            reminderDate: '25 Sep 2026, 11:00 AM',
          ),
        ],
      ),
      LeadItem(
        id: 'lead_3',
        srNo: 3,
        leadNumber: 3,
        name: 'vikramaditya roy',
        phone: '+91 98223 99881',
        createdDate: '20 Sep 2026, 09:15 AM',
        attempts: 0,
        tags: ['Google Sheet', 'High Budget'],
        tagAssignedDate: '20 Sep 2026',
        assignedTo: 'Amit Patel',
        assignedToPhone: '+91-9822334455',
        assignedDate: '20 Sep 2026 | 09:15 AM',
        status: 'New Inflow',
        lastCallType: '-',
        lastCallTime: '(Never Contacted)',
        lastCallSummary: 'Pending telecaller initial dial',
        company: 'Roy Global Logistics',
        source: 'Google Sheets Auto-Sync',
        price: '₹ 1,50,000',
      ),
    ];
  }
}

class LeadTagModel {
  final String id;
  final String name;
  final String colorHex;
  final int leadCount;
  final String createdAt;

  LeadTagModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.leadCount,
    required this.createdAt,
  });

  LeadTagModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? leadCount,
    String? createdAt,
  }) {
    return LeadTagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      leadCount: leadCount ?? this.leadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<LeadTagModel> initialTags() {
    return [
      LeadTagModel(id: 'tag_1', name: 'Hot Lead', colorHex: '#EF4444', leadCount: 18, createdAt: '01 Sep 2026'),
      LeadTagModel(id: 'tag_2', name: 'High Budget', colorHex: '#10B981', leadCount: 12, createdAt: '02 Sep 2026'),
      LeadTagModel(id: 'tag_3', name: 'Instagram', colorHex: '#EC4899', leadCount: 34, createdAt: '03 Sep 2026'),
      LeadTagModel(id: 'tag_4', name: 'Urgent', colorHex: '#F59E0B', leadCount: 9, createdAt: '05 Sep 2026'),
      LeadTagModel(id: 'tag_5', name: 'Google Sheet', colorHex: '#3B82F6', leadCount: 52, createdAt: '08 Sep 2026'),
      LeadTagModel(id: 'tag_6', name: 'Enterprise Bundle', colorHex: '#8B5CF6', leadCount: 14, createdAt: '10 Sep 2026'),
      LeadTagModel(id: 'tag_7', name: 'New', colorHex: '#06B6D4', leadCount: 26, createdAt: '12 Sep 2026'),
    ];
  }
}

class LeadStatusModel {
  final String id;
  final String name;
  final String description;
  final bool isReminderRequired;
  final bool isDefaultDisplay;
  final int order;
  final String colorHex;

  LeadStatusModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isReminderRequired,
    required this.isDefaultDisplay,
    required this.order,
    required this.colorHex,
  });

  LeadStatusModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isReminderRequired,
    bool? isDefaultDisplay,
    int? order,
    String? colorHex,
  }) {
    return LeadStatusModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isReminderRequired: isReminderRequired ?? this.isReminderRequired,
      isDefaultDisplay: isDefaultDisplay ?? this.isDefaultDisplay,
      order: order ?? this.order,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  static List<LeadStatusModel> initialStatuses() {
    return [
      LeadStatusModel(
        id: 'st_not_pickup',
        name: 'Not Pickup Call',
        description: '',
        isReminderRequired: false,
        isDefaultDisplay: true,
        order: 1,
        colorHex: '#F97316',
      ),
      LeadStatusModel(
        id: 'st_negative',
        name: 'Negative',
        description: '',
        isReminderRequired: false,
        isDefaultDisplay: true,
        order: 2,
        colorHex: '#EF4444',
      ),
      LeadStatusModel(
        id: 'st_call_back',
        name: 'Call Back',
        description: '',
        isReminderRequired: true,
        isDefaultDisplay: true,
        order: 3,
        colorHex: '#F59E0B',
      ),
      LeadStatusModel(
        id: 'st_positive',
        name: 'Positive',
        description: '',
        isReminderRequired: false,
        isDefaultDisplay: true,
        order: 4,
        colorHex: '#10B981',
      ),
    ];
  }
}

class FormFieldSettingModel {
  final String id;
  final String label;
  final String fieldType; // inputText, numericField, emailField, websiteField, textArea, checkBoxGroup, radioGroup, dropDown, datePicker
  final List<String> options;
  final bool isRequired;
  final int order;

  FormFieldSettingModel({
    required this.id,
    required this.label,
    required this.fieldType,
    this.options = const [],
    this.isRequired = false,
    required this.order,
  });

  FormFieldSettingModel copyWith({
    String? id,
    String? label,
    String? fieldType,
    List<String>? options,
    bool? isRequired,
    int? order,
  }) {
    return FormFieldSettingModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
    );
  }

  static List<FormFieldSettingModel> initialFields() {
    return [
      FormFieldSettingModel(
        id: 'company_name',
        label: 'Company Name',
        fieldType: 'inputText',
        isRequired: false,
        order: 1,
      ),
      FormFieldSettingModel(
        id: 'budget_amount',
        label: 'Estimated Budget (₹)',
        fieldType: 'numericField',
        isRequired: false,
        order: 2,
      ),
      FormFieldSettingModel(
        id: 'work_email',
        label: 'Corporate Work Email',
        fieldType: 'emailField',
        isRequired: false,
        order: 3,
      ),
      FormFieldSettingModel(
        id: 'company_website',
        label: 'Company Website / URL',
        fieldType: 'websiteField',
        isRequired: false,
        order: 4,
      ),
      FormFieldSettingModel(
        id: 'project_notes',
        label: 'Detailed Requirements Note',
        fieldType: 'textArea',
        isRequired: false,
        order: 5,
      ),
      FormFieldSettingModel(
        id: 'lead_priority',
        label: 'Priority Tier',
        fieldType: 'radioGroup',
        options: ['High Priority', 'Medium', 'Low'],
        isRequired: true,
        order: 6,
      ),
      FormFieldSettingModel(
        id: 'crm_interest',
        label: 'Requested Services',
        fieldType: 'checkBoxGroup',
        options: ['Call Tracking', 'Telecaller App', 'WhatsApp Automation', 'Analytics API'],
        isRequired: false,
        order: 7,
      ),
      FormFieldSettingModel(
        id: 'team_size_tier',
        label: 'Telecaller Team Size',
        fieldType: 'dropDown',
        options: ['1 - 5 Agents', '6 - 20 Agents', '21 - 50 Agents', '50+ Agents'],
        isRequired: false,
        order: 8,
      ),
      FormFieldSettingModel(
        id: 'expected_close_date',
        label: 'Target Close Date',
        fieldType: 'datePicker',
        isRequired: false,
        order: 9,
      ),
    ];
  }
}

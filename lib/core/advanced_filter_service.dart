import '../../models/counseling_case.dart';

class AdvancedFilterOptions {
  final String? caseType;
  final String? status;
  final DateRange? dateRange;

  AdvancedFilterOptions({
    this.caseType,
    this.status,
    this.dateRange,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  bool isInRange(DateTime date) {
    return date.isAtSameMomentAs(start) || date.isAtSameMomentAs(end) || (date.isAfter(start) && date.isBefore(end));
  }
}

class AdvancedFilterService {
  static List<CounselingCase> applyFilters(
    List<CounselingCase> cases,
    AdvancedFilterOptions options,
  ) {
    List<CounselingCase> filtered = List.from(cases);

    // Filter by case type
    if (options.caseType != null && options.caseType!.isNotEmpty) {
      filtered = filtered.where((c) => c.caseType == options.caseType).toList();
    }

    // Filter by status
    if (options.status != null && options.status!.isNotEmpty) {
      filtered = filtered.where((c) => c.status == options.status).toList();
    }

    // Filter by date range (follow-up date)
    if (options.dateRange != null) {
      filtered = filtered.where((c) => options.dateRange!.isInRange(c.followUpDate)).toList();
    }

    return filtered;
  }

  static List<CounselingCase> sortByFollowUpDate(List<CounselingCase> cases) {
    final sorted = List<CounselingCase>.from(cases);
    sorted.sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
    return sorted;
  }

  static List<CounselingCase> sortByCaseType(List<CounselingCase> cases) {
    final sorted = List<CounselingCase>.from(cases);
    sorted.sort((a, b) => a.caseType.compareTo(b.caseType));
    return sorted;
  }

  static Map<String, List<CounselingCase>> groupByCaseType(List<CounselingCase> cases) {
    final grouped = <String, List<CounselingCase>>{};
    for (final case_ in cases) {
      grouped.putIfAbsent(case_.caseType, () => []).add(case_);
    }
    return grouped;
  }

  static Map<String, List<CounselingCase>> groupByStatus(List<CounselingCase> cases) {
    final grouped = <String, List<CounselingCase>>{};
    for (final case_ in cases) {
      grouped.putIfAbsent(case_.status, () => []).add(case_);
    }
    return grouped;
  }

  static int countByStatus(List<CounselingCase> cases, String status) {
    return cases.where((c) => c.status == status).length;
  }

  static int countByCaseType(List<CounselingCase> cases, String caseType) {
    return cases.where((c) => c.caseType == caseType).length;
  }

  static CounselingCase? getOldestOpenCase(List<CounselingCase> cases) {
    final openCases = cases.where((c) => c.status == 'Open').toList();
    if (openCases.isEmpty) return null;
    openCases.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return openCases.first;
  }

  static List<CounselingCase> getDueForFollowUp(List<CounselingCase> cases) {
    final now = DateTime.now();
    return cases.where((c) => c.status != 'Closed' && c.followUpDate.isBefore(now)).toList();
  }
}

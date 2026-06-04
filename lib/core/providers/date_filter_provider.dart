import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../filters/date_filter.dart';

/// Shared date filter for home tabs, CAPT tab, and tenders screen.
final contentDateFilterProvider = StateProvider<DateFilter?>((ref) => null);

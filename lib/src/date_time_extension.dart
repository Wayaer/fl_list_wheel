/// DateTime 的日期区间工具
extension FlDateTimeExtension on DateTime {
  /// 获取时间区间内所有的日期
  /// 通过 [DateTime] 构造逐日累加，避免夏令时导致的跳天/重复天
  List<DateTime> getDaysForRange(DateTime endDate) {
    final List<DateTime> result = [];
    DateTime date = DateTime(year, month, day);
    final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);
    while (!date.isAfter(end)) {
      result.add(date);
      date = DateTime(date.year, date.month, date.day + 1);
    }
    return result;
  }
}

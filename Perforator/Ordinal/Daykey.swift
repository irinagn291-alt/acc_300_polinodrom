import Foundation

/// Ordinal role. Turns a calendar day into the YYYYMMDD daykey and the
/// day-of-year ordinal that indexes bundled stock. The year fold is keyed
/// by that integer, never by a list position.
enum Daykey {
    static func int(from date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    /// 1-based day of year from `Calendar.ordinality`. Zero only if the calendar cannot answer.
    static func dayOrdinalInYear(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        return calendar.ordinality(of: .day, in: .year, for: start) ?? 0
    }
}

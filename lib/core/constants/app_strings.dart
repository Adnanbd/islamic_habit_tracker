enum HabitType {
  salat,
  reciteQuran,
  giveSadaqah,
  makeDua,
  sendSalawat,
  readHadith,
  morningAdhkar,
  helpFamily,
  sleepWithWudu,
}

extension HabitTypeExtension on HabitType {
  String get displayName {
    switch (this) {
      case HabitType.salat:
        return 'Salat';
      case HabitType.reciteQuran:
        return 'Recite Quran';
      case HabitType.giveSadaqah:
        return 'Give Sadaqah';
      case HabitType.makeDua:
        return 'Make Dua';
      case HabitType.sendSalawat:
        return 'Send Salawat on the Prophet ﷺ';
      case HabitType.readHadith:
        return 'Read a Hadith';
      case HabitType.morningAdhkar:
        return 'Do Morning Adhkar';
      case HabitType.helpFamily:
        return 'Help a family member';
      case HabitType.sleepWithWudu:
        return 'Sleep with Wudu';
    }
  }
}

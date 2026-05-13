class InsightsText {
  static const nicotineTitle = "Nicotine Impact";

  static const nicotineInfo =
      "Nicotine is a stimulant that can interfere with sleep architecture and may worsen breathing interruptions during sleep. "
      "These insights are not a medical diagnosis and should be validated with a healthcare professional.";

  static const alcoholTitle = "Alcohol & Sleep";

  static const alcoholInfo =
      "Alcohol can relax airway muscles and disrupt sleep quality, which may contribute to higher AHI values. "
      "These insights are not a medical diagnosis and should be validated with a healthcare professional.";

  static const noDataTitle = "No sleep data this week";

  static const noDataContent =
      "No analyzed sleep sessions were found for this week. Analyze more nights to see weekly apnea patterns. "
      "This application is not a diagnostic tool, and any concerning results should be validated by a medical specialist.";

  static String severeFrequentTitle() {
    return "Frequent severe apnea signs";
  }

  static String severeFrequentContent(int severeDays) {
    final label = _nightLabel(severeDays);

    return "Severe AHI values were detected on $severeDays $label this week. "
        "This suggests a repeated pattern of significant breathing interruptions during sleep. "
        "This result is not a medical diagnosis. Please validate these findings with a healthcare professional, especially if you experience symptoms such as daytime sleepiness, loud snoring, or morning headaches.";
  }

  static const severeSingleTitle = "One severe apnea night detected";

  static const severeSingleContent =
      "One night this week was classified as severe. A single night can be influenced by sleep position, alcohol, fatigue, or measurement quality. "
      "This result is not a medical diagnosis. Please monitor future nights and validate concerning results with a healthcare professional.";

  static String moderateRepeatedTitle() {
    return "Repeated moderate apnea pattern";
  }

  static String moderateRepeatedContent(int moderateDays) {
    final label = _nightLabel(moderateDays);

    return "Moderate AHI values were detected on $moderateDays $label this week. "
        "This may indicate a persistent breathing disturbance during sleep. "
        "This application is not a diagnostic tool. The results should be interpreted carefully and validated by a medical specialist.";
  }

  static String moderateDetectedContent(int moderateDays) {
    final label = _nightLabel(moderateDays);

    return "Moderate AHI values appeared on $moderateDays $label this week. "
        "Continue monitoring future nights to see whether this is an isolated result or part of a repeated pattern. "
        "This result is not a medical diagnosis and should be validated with a healthcare professional.";
  }

  static const moderateDetectedTitle = "Moderate apnea detected";

  static String mildPatternContent(int mildDays) {
    final label = _nightLabel(mildDays);

    return "Mild AHI values were detected on $mildDays $label this week. "
        "While these values are not severe, repeated mild results may still be useful to monitor over time. "
        "This application is not a diagnostic tool, and the results should be validated medically if symptoms are present.";
  }

  static const mildPatternTitle = "Mild apnea pattern";

  static const mildDetectedTitle = "Mild apnea signs detected";

  static const mildDetectedContent =
      "One or more nights this week showed mild apnea signs. This does not necessarily indicate a persistent problem, but tracking future sessions can help identify whether the pattern continues. "
      "This result is not a medical diagnosis and should be validated with a healthcare professional if you have concerns.";

  static String normalWeekContent(int recordedDays) {
    final label = _nightLabel(recordedDays);

    return "All $recordedDays recorded $label this week were classified as normal. "
        "Continue monitoring regularly to observe possible changes over time. "
        "This application is not a diagnostic tool and does not replace a medical sleep evaluation.";
  }

  static const normalWeekTitle = "Low apnea burden this week";

  static String _nightLabel(int n) {
    return n == 1 ? "night" : "nights";
  }
}
class TripResponse {
  final String destination;
  final String overview;
  final String? estimatedTotalCost;
  final List<DailyItinerary> dailyItinerary;

  TripResponse({
    required this.destination,
    required this.overview,
    this.estimatedTotalCost,
    required this.dailyItinerary,
  });

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    var list = json['dailyItinerary'] as List? ?? [];
    List<DailyItinerary> itineraryList =
        list.map((i) => DailyItinerary.fromJson(i)).toList();

    return TripResponse(
      destination: json['destination'] ?? 'Unknown Destination',
      overview: json['overview'] ?? '',
      estimatedTotalCost: json['estimatedTotalCost'],
      dailyItinerary: itineraryList,
    );
  }
}

class DailyItinerary {
  final int day;
  final String theme;
  final List<Activity> activities;

  DailyItinerary({
    required this.day,
    required this.theme,
    required this.activities,
  });

  factory DailyItinerary.fromJson(Map<String, dynamic> json) {
    var list = json['activities'] as List? ?? [];
    List<Activity> activityList =
        list.map((i) => Activity.fromJson(i)).toList();

    return DailyItinerary(
      day: json['day'] ?? 1,
      theme: json['theme'] ?? 'Exploring',
      activities: activityList,
    );
  }
}

class Activity {
  final String time;
  final String title;
  final String description;
  final String? estimatedCost;

  Activity({
    required this.time,
    required this.title,
    required this.description,
    this.estimatedCost,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedCost: json['estimatedCost'],
    );
  }
}
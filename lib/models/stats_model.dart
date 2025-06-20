class StatsModel {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final double userGrowthPercentage;

  final int totalTrainers;
  final int activeTrainers;
  final int inactiveTrainers;
  final double trainerGrowthPercentage;

  final int totalTrainees;
  final int activeTrainees;
  final int inactiveTrainees;
  final double traineeGrowthPercentage;

  final int totalOrganizations;
  final int activeOrganizations;
  final int inactiveOrganizations;
  final double organizationGrowthPercentage;

  final int completedSessions;
  final double sessionGrowthPercentage;

  StatsModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.userGrowthPercentage,
    required this.totalTrainers,
    required this.activeTrainers,
    required this.inactiveTrainers,
    required this.trainerGrowthPercentage,
    required this.totalTrainees,
    required this.activeTrainees,
    required this.inactiveTrainees,
    required this.traineeGrowthPercentage,
    required this.totalOrganizations,
    required this.activeOrganizations,
    required this.inactiveOrganizations,
    required this.organizationGrowthPercentage,
    required this.completedSessions,
    required this.sessionGrowthPercentage,
  });

  double get userActivePercentage => totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;
  double get trainerActivePercentage => totalTrainers > 0 ? (activeTrainers / totalTrainers) * 100 : 0;
  double get traineeActivePercentage => totalTrainees > 0 ? (activeTrainees / totalTrainees) * 100 : 0;
  double get organizationActivePercentage => totalOrganizations > 0 ? (activeOrganizations / totalOrganizations) * 100 : 0;
}

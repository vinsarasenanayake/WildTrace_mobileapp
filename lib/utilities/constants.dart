import '../models/milestone.dart';

class AppConstants {
  static final List<Milestone> fallbackMilestones = [
    Milestone(
      id: '1',
      year: '2022',
      title: 'The First Click',
      description: 'WildTrace was founded with a passion for wildlife photography in Sri Lanka.',
    ),
    Milestone(
      id: '2',
      year: '2023',
      title: 'Conservation Focus',
      description: 'Started collaborating with local wildlife departments to protect endangered species.',
    ),
    Milestone(
      id: '3',
      year: '2024',
      title: 'Going Global',
      description: 'Expanded our reach to international photographers and galleries.',
    ),
  ];
}

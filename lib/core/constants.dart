enum Role { student, staff }

enum Category {
  facilities('Facilities'),
  water('Water shortage'),
  electricity('Electricity outage'),
  furniture('Damaged furniture'),
  sanitation('Sanitation'),
  safety('Safety');

  const Category(this.label);
  final String label;
}

enum Building {
  learningCommons('Learning Commons'),
  enterpriseCommons('Enterprise Commons'),
  socialCommons('Social Commons'),
  parking('Parking'),
  garden('Garden'),
  hostels('Hostels');

  const Building(this.label);
  final String label;
}

enum ReportStatus {
  submitted('Submitted'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const ReportStatus(this.label);
  final String label;
}

enum Priority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const Priority(this.label);
  final String label;
}

const studentEmailDomain = '@alustudent.com';
const staffEmailDomain = '@alueducation.com';
const maxPhotos = 5;
const maxPhotoBytes = 5 * 1024 * 1024;

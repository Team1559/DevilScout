import 'auth.dart';
import 'events.dart';
import 'questions.dart';
import 'session.dart';
import 'users.dart';

void main() async {
  await login(team: 1559, username: 'xander');
  await authenticate(password: 'password');
  print(Session.current);
  print(User.current);

  print(await downloadCurrentEvent('2023nyrr'));

  print((await downloadEventList()).value?.length);

  print(await downloadMatchQuestions());
  print(await downloadPitQuestions());
  print(await downloadDriveTeamQuestions());

  print(await downloadMatchSchedule('2023nyrr'));
  print(await downloadTeamList('2023nyrr'));
}

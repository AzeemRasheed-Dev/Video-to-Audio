import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart'; // Agar aapke project ka naam kuch aur hai toh package:aapka_project_naam/main.dart karein

void main() {
  testWidgets('Video to Audio app test', (WidgetTester tester) async {
    // Riverpod use karne ke liye test mein bhi ProviderScope wrap karte hain
    await tester.pumpWidget(const ProviderScope(child: VideoToAudioApp()));

    // Check karein ke screen par title render ho raha hai ya nahi
    expect(find.text('Video To Audio Converter'), findsOneWidget);
  });
}

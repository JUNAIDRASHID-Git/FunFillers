import 'package:flutter_test/flutter_test.dart';
import 'package:funfillers/data/datasources/app_data_source.dart';
import 'package:funfillers/data/repositories/app_repository_impl.dart';
import 'package:funfillers/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final dataSource = AppDataSource();
    final repository = AppRepositoryImpl(dataSource: dataSource);

    await tester.pumpWidget(FunFillersApp(repository: repository));
    expect(find.byType(FunFillersApp), findsOneWidget);
  });
}

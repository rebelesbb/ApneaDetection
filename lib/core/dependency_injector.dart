import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:apnea_detector/services/api_services.dart';
import 'package:apnea_detector/services/health_service.dart';
import 'package:apnea_detector/services/local_storage.dart';

class DI {
  static final DI I = DI._();
  DI._();

  final baseUrl = "http://10.0.2.2:8000";

  late final ApiService apiService;
  late final HealthService healthService;
  late final LocalStorageService localStorageService;

  late final SleepRepository sleepRepository;

  Future<void> init() async {
    localStorageService = LocalStorageService();
    await localStorageService.init();

    healthService = HealthService();

    apiService = ApiService(baseUrl: baseUrl);

    sleepRepository = SleepRepository(
      localStorageService: localStorageService,
      apiService: apiService,
      healthService: healthService,
     );
  }
}
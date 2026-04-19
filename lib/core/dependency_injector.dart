import 'package:apnea_detector/controllers/auth_controller.dart';
import 'package:apnea_detector/controllers/history_controller.dart';
import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/controllers/insights_controller.dart';
import 'package:apnea_detector/repositories/auth_repository.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:apnea_detector/services/sleep_api_service.dart';
import 'package:apnea_detector/services/auth_api_service.dart';
import 'package:apnea_detector/services/health_service.dart';
import 'package:apnea_detector/services/local/auth_storage.dart';
import 'package:apnea_detector/services/local/local_storage.dart';

class DI {
  static final DI I = DI._();
  DI._();

  final baseUrl = "http://10.0.2.2:8000";

  late final SleepApiService sleepApiService;
  late final AuthApiService authApiService;
  late final HealthService healthService;
  late final LocalStorageService localStorageService;
  late final AuthStorageService authStorageService;

  late final SleepRepository sleepRepository;
  late final AuthRepository authRepository;

  late final HomeController sleepController;
  late final AuthController authController;
  late final HistoryController historyController;
  late final InsightsController insightsController;

  Future<void> init() async {
    localStorageService = LocalStorageService();
    await localStorageService.init();

    authStorageService = AuthStorageService();

    healthService = HealthService();

    sleepApiService = SleepApiService(baseUrl: baseUrl);
    authApiService = AuthApiService(baseUrl: baseUrl);

    sleepRepository = SleepRepository(
      sleepApiService: sleepApiService,
      healthService: healthService,
      authStorageService: authStorageService,
    );

    authRepository = AuthRepository(
      authApiService: authApiService,
      authStorageService: authStorageService,
    );

    authController = AuthController(authRepository: authRepository);
    sleepController = HomeController(sleepRepository: sleepRepository);
    insightsController = InsightsController(sleepRepository: sleepRepository);
    historyController = HistoryController(sleepRepository: sleepRepository);
  }
}
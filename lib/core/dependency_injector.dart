import 'package:apnea_detector/controllers/auth_controller.dart';
import 'package:apnea_detector/controllers/home_controller.dart';
import 'package:apnea_detector/repositories/auth_repository.dart';
import 'package:apnea_detector/repositories/sleep_repository.dart';
import 'package:apnea_detector/services/api_services.dart';
import 'package:apnea_detector/services/auth_api_service.dart';
import 'package:apnea_detector/services/health_service.dart';
import 'package:apnea_detector/services/local/auth_storage.dart';
import 'package:apnea_detector/services/local/local_storage.dart';

class DI {
  static final DI I = DI._();
  DI._();

  final baseUrl = "http://10.0.2.2:8000";

  late final ApiService apiService;
  late final AuthApiService authApiService;
  late final HealthService healthService;
  late final LocalStorageService localStorageService;
  late final AuthStorageService authStorageService;

  late final SleepRepository sleepRepository;
  late final AuthRepository authRepository;

  late final HomeController sleepController;
  late final AuthController authController;

  Future<void> init() async {
    localStorageService = LocalStorageService();
    await localStorageService.init();

    authStorageService = AuthStorageService();

    healthService = HealthService();

    apiService = ApiService(baseUrl: baseUrl);
    authApiService = AuthApiService(baseUrl: baseUrl);

    sleepRepository = SleepRepository(
      localStorageService: localStorageService,
      apiService: apiService,
      healthService: healthService,
    );

    authRepository = AuthRepository(
      authApiService: authApiService,
      authStorageService: authStorageService,
    );

    authController = AuthController(authRepository: authRepository);
    sleepController = HomeController(sleepRepository: sleepRepository);
  }
}
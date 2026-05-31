import 'models/app_user.dart';

class AppConfig {
  AppConfig._();

  static const bool useFirebase = true;

  static const String appName = 'Аптека';
  static const String appTagline = 'Онлайн-аптека вашего города';
  static const String defaultCity = 'г. Алматы';

  static const String demoUserEmail = 'user@apteka.ru';
  static const String demoCourierEmail = 'courier@apteka.ru';
  static const String demoAdminEmail = 'admin@apteka.ru';
  static const String demoPassword = '123456';
}

class AppFlavor {
  AppFlavor._();

  static UserRole role = UserRole.customer;

  static String get title {
    switch (role) {
      case UserRole.customer:
        return 'Аптека';
      case UserRole.courier:
        return 'Аптека · Курьер';
      case UserRole.admin:
        return 'Аптека · Админ';
    }
  }

  static String demoEmailForRole() {
    switch (role) {
      case UserRole.customer:
        return AppConfig.demoUserEmail;
      case UserRole.courier:
        return AppConfig.demoCourierEmail;
      case UserRole.admin:
        return AppConfig.demoAdminEmail;
    }
  }
}

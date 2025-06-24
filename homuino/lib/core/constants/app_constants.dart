import 'package:flutter/material.dart';

/// A collection of all constant values used across the application
class AppConstants {
  // Firebase-related constants
  static const firebaseConfig = FirebaseConfig(
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    databaseURL: "YOUR_DATABASE_URL",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
  );

  // API Endpoints
  static const apiEndpoints = ApiEndpoints(
    baseUrl: "https://api.homuino.com/v1",
    devices: "/devices",
    authenticate: "/auth",
    userProfile: "/users/profile",
  );

  // Application metadata
  static const appMetadata = AppMetadata(
    name: "Homuino",
    version: "1.0.0",
    buildNumber: 1,
    publisher: "77756",
    supportEmail: "ahmdraziq.gz@gmail.com",
  );

  // Default settings
  static const defaultSettings = DefaultSettings(
    themeMode: ThemeMode.system,
    locale: 'en_US',
    enableNotifications: true,
    enableAnalytics: true,
  );

  // Device configuration
  static const deviceConfig = DeviceConfig(
    defaultIp: "192.168.4.1",
    scanTimeout: Duration(seconds: 15),
    connectionTimeout: Duration(seconds: 10),
    maxRetryAttempts: 3,
  );

  // UI Constants
  static const ui = UIConstants(
    defaultPadding: EdgeInsets.all(16),
    defaultBorderRadius: 12.0,
    animationDuration: Duration(milliseconds: 300),
    maxWidth: 600,
  );

  // Local storage keys
  static const storageKeys = StorageKeys(
    authToken: 'auth_token',
    userProfile: 'user_profile',
    appSettings: 'app_settings',
    devices: 'user_devices',
  );

  // Validation patterns
  static const validation = ValidationPatterns(
    email: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    password: r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    ipAddress: r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$',
  );

  // Error messages
  static const errorMessages = ErrorMessages(
    networkError: "Network connection unavailable",
    authError: "Authentication failed",
    deviceConnectionError: "Device connection failed",
    genericError: "Something went wrong",
  );
}

// Supporting value classes for better organization
class FirebaseConfig {
  final String apiKey;
  final String authDomain;
  final String databaseURL;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;

  const FirebaseConfig({
    required this.apiKey,
    required this.authDomain,
    required this.databaseURL,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
  });
}

class ApiEndpoints {
  final String baseUrl;
  final String devices;
  final String authenticate;
  final String userProfile;

  const ApiEndpoints({
    required this.baseUrl,
    required this.devices,
    required this.authenticate,
    required this.userProfile,
  });
}

class AppMetadata {
  final String name;
  final String version;
  final int buildNumber;
  final String publisher;
  final String supportEmail;

  const AppMetadata({
    required this.name,
    required this.version,
    required this.buildNumber,
    required this.publisher,
    required this.supportEmail,
  });
}

class DefaultSettings {
  final ThemeMode themeMode;
  final String locale;
  final bool enableNotifications;
  final bool enableAnalytics;

  const DefaultSettings({
    required this.themeMode,
    required this.locale,
    required this.enableNotifications,
    required this.enableAnalytics,
  });
}

class DeviceConfig {
  final String defaultIp;
  final Duration scanTimeout;
  final Duration connectionTimeout;
  final int maxRetryAttempts;

  const DeviceConfig({
    required this.defaultIp,
    required this.scanTimeout,
    required this.connectionTimeout,
    required this.maxRetryAttempts,
  });
}

class UIConstants {
  final EdgeInsets defaultPadding;
  final double defaultBorderRadius;
  final Duration animationDuration;
  final double maxWidth;

  const UIConstants({
    required this.defaultPadding,
    required this.defaultBorderRadius,
    required this.animationDuration,
    required this.maxWidth,
  });
}

class StorageKeys {
  final String authToken;
  final String userProfile;
  final String appSettings;
  final String devices;

  const StorageKeys({
    required this.authToken,
    required this.userProfile,
    required this.appSettings,
    required this.devices,
  });
}

class ValidationPatterns {
  final String email;
  final String password;
  final String ipAddress;

  const ValidationPatterns({
    required this.email,
    required this.password,
    required this.ipAddress,
  });
}

class ErrorMessages {
  final String networkError;
  final String authError;
  final String deviceConnectionError;
  final String genericError;

  const ErrorMessages({
    required this.networkError,
    required this.authError,
    required this.deviceConnectionError,
    required this.genericError,
  });
}
#include <WiFi.h>
#include <WebServer.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
#include <time.h>
#include <EEPROM.h>

// Logging Level Definitions
typedef enum {
  LOG_LEVEL_DEBUG,
  LOG_LEVEL_INFO,
  LOG_LEVEL_WARNING,
  LOG_LEVEL_ERROR,
  LOG_LEVEL_CRITICAL
} LogLevel;

const char* logLevelToString(LogLevel level) {
  switch(level) {
    case LOG_LEVEL_DEBUG: return "DEBUG";
    case LOG_LEVEL_INFO: return "INFO";
    case LOG_LEVEL_WARNING: return "WARNING";
    case LOG_LEVEL_ERROR: return "ERROR";
    case LOG_LEVEL_CRITICAL: return "CRITICAL";
    default: return "UNKNOWN";
  }
}

// Function forward declarations
void logPrint(LogLevel level, String message);
void updateDeviceStatus(const String& status);
void streamCallback(FirebaseStream data);
void streamTimeoutCallback(bool timeout);
void setupFirebaseStream();
void disableAP();
void setupNTP();
void checkFirebaseData();
void saveConfigToEEPROM();
void loadConfigFromEEPROM();
void factoryReset();
void connectWithSavedCredentials();
void startProvisioningAP();
void setupWebServer();
void initializeFirebase();
void checkTimers();

// Firebase and Global Declarations
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

struct DeviceConfig {
  uint32_t magicNumber;
  char ssid[32];
  char password[64];
  char deviceId[32];
  char userId[32];
  char userEmail[64];
  bool wasProvisioned;
};

DeviceConfig savedConfig;

WebServer server(80);
Servo myServo;

String deviceId = "";
String currentUserId = "";
String currentUserEmail = "";
bool lastIsOnState = false;
bool isConnected = false;
bool signupOK = false;
bool provisioningMode = true;

unsigned long lastReconnectAttempt = 0;
const unsigned long reconnectInterval = 30000;
unsigned long lastHttpGetAttempt = 0;
const unsigned long httpGetInterval = 500;
unsigned long apShutdownTime = 0;
const unsigned long apShutdownDelay = 30000;
unsigned long lastTimerCheck = 0;
const unsigned long timerCheckInterval = 60000; // Check timers every minute

#define debugPrint(message) logPrint(LOG_LEVEL_DEBUG, message)
#define infoPrint(message) logPrint(LOG_LEVEL_INFO, message)
#define warnPrint(message) logPrint(LOG_LEVEL_WARNING, message)
#define errorPrint(message) logPrint(LOG_LEVEL_ERROR, message)
#define criticalPrint(message) logPrint(LOG_LEVEL_CRITICAL, message)

// Firebase Config
#define API_KEY "AIzaSyDDHjgIMoNdLZdkZ-M-UVjt_I2QEEXk8r4"
#define FIREBASE_URL "https://flutterflowmastercourse-815ba-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define DEVICE_EMAIL "device@homuino.com"
#define DEVICE_PASSWORD "SecureDevicePassword123"

// NTP Config
const char* ntpServer1 = "pool.ntp.org";
const char* ntpServer2 = "time.google.com";
const long gmtOffset_sec = 8 * 3600;
const int daylightOffset_sec = 0;

// Hardware Pins
#define LED_PIN 2
#define SERVO_PIN 13
#define SERVO_MIN 500
#define SERVO_MAX 2400
#define RESET_BUTTON_PIN 14

// EEPROM Config
#define EEPROM_SIZE 512
#define CONFIG_START_ADDR 0
#define CONFIG_MAGIC_NUMBER 0xABCD1234

void logPrint(LogLevel level, String message) {
  String timestamp = "";
  struct tm timeinfo;
  if (getLocalTime(&timeinfo)) {
    char buffer[20];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", &timeinfo);
    timestamp = String(buffer);
  } else {
    timestamp = "[" + String(millis()) + "]";
  }

  String logMessage = timestamp + " [" + logLevelToString(level) + "] " + message;
  Serial.println(logMessage);

  // Send critical errors to Firebase
  if (level >= LOG_LEVEL_ERROR && Firebase.ready() && !deviceId.isEmpty()) {
    String path = "devices/" + deviceId + "/logs/" + String(millis());
    Firebase.RTDB.setString(&fbdo, path, logMessage);
  }
}

void blinkLED(int times, int delayMs) {
  for (int i = 0; i < times; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(delayMs);
    digitalWrite(LED_PIN, LOW);
    delay(delayMs);
  }
}

void updateDeviceStatus(const String& status) {
  if (deviceId.isEmpty() || !Firebase.ready()) {
    warnPrint("Cannot update status - device ID empty or Firebase not ready");
    return;
  }

  String path = "devices/" + deviceId + "/status";
  int attempts = 0;
  bool success = false;

  while (attempts < 3 && !success) {
    if (Firebase.RTDB.setString(&fbdo, path, status)) {
      infoPrint("Status updated to: " + status);
      success = true;
    } else {
      errorPrint("Failed to update status (attempt " + String(attempts+1) + "): " + fbdo.errorReason());
      delay(500);
      attempts++;
    }
  }

  if (!success) {
    errorPrint("Giving up on status update after 3 attempts");
  }
}

void streamCallback(FirebaseStream data) {
  debugPrint("════════════════════════════════════════");
  debugPrint("STREAM CALLBACK TRIGGERED");

  String fullPath = "devices/" + deviceId;
  String streamPath = data.streamPath();
  String dataPath = data.dataPath();

  debugPrint("Stream Path: " + streamPath);
  debugPrint("Data Path: " + dataPath);
  debugPrint("Data Type: " + data.dataType());

  if (data.dataType() == "boolean") {
    bool isOn = data.boolData();
    debugPrint("Boolean Value: " + String(isOn ? "true" : "false"));

    if (isOn != lastIsOnState) {
      lastIsOnState = isOn;

      if (isOn) {
        myServo.write(180);
        digitalWrite(LED_PIN, HIGH);
        infoPrint("Turning device ON");
        infoPrint("Servo moved to 180 position");
        infoPrint("LED turned ON");

        if (!Firebase.RTDB.setString(&fbdo, fullPath + "/switchState", "ON")) {
          errorPrint("Firebase update failed: " + fbdo.errorReason());
        }
      } else {
        myServo.write(0);
        digitalWrite(LED_PIN, LOW);
        infoPrint("Turning device OFF");
        infoPrint("Servo moved to 0 position");
        infoPrint("LED turned OFF");

        if (!Firebase.RTDB.setString(&fbdo, fullPath + "/switchState", "OFF")) {
          errorPrint("Firebase update failed: " + fbdo.errorReason());
        }
      }
    }
  }
  debugPrint("════════════════════════════════════════");
}

void streamTimeoutCallback(bool timeout) {
  if (timeout) {
    warnPrint("Stream timeout, reconnecting...");
    updateDeviceStatus("OFFLINE");
    setupFirebaseStream();
  }
}

void setupFirebaseStream() {
  if (deviceId.isEmpty()) {
    warnPrint("Stream setup skipped - no device ID");
    return;
  }

  String path = "devices/" + deviceId + "/isOn";

  if (!Firebase.RTDB.beginStream(&fbdo, path)) {
    errorPrint("Stream begin error: " + fbdo.errorReason());
  } else {
    infoPrint("Stream initialized");
    Firebase.RTDB.setStreamCallback(&fbdo, streamCallback, streamTimeoutCallback);
  }
}

void disableAP() {
  if (provisioningMode && WiFi.softAPgetStationNum() == 0) {
    infoPrint("Disabling provisioning AP");
    WiFi.softAPdisconnect(true);
    provisioningMode = false;
    saveConfigToEEPROM();
  }
}

void setupNTP() {
  infoPrint("Synchronizing time...");
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer1, ntpServer2);

  int attempts = 0;
  const int maxNTPAttempts = 30;
  time_t now = time(nullptr);
  struct tm timeinfo;

  while (attempts < maxNTPAttempts) {
    now = time(nullptr);
    localtime_r(&now, &timeinfo);
    if (now != 0 && timeinfo.tm_year >= (2000 - 1900)) {
      break;
    }
    debugPrint("Waiting for NTP... Attempt " + String(attempts + 1));
    delay(1000);
    attempts++;
  }

  if (now > 0 && timeinfo.tm_year >= (2000 - 1900)) {
    infoPrint("Time synced: " + String(asctime(&timeinfo)));
  } else {
    errorPrint("NTP sync failed");
  }
}

void checkFirebaseData() {
  if (!Firebase.ready() || deviceId.isEmpty()) return;

  String path = "devices/" + deviceId + "/isOn";

  if (Firebase.RTDB.getBool(&fbdo, path)) {
    bool currentIsOn = fbdo.boolData();
    if (currentIsOn != lastIsOnState) {
      lastIsOnState = currentIsOn;
      if (currentIsOn) {
        myServo.write(180);
        digitalWrite(LED_PIN, HIGH);
        infoPrint("Device state updated to ON via HTTP");
      } else {
        myServo.write(0);
        digitalWrite(LED_PIN, LOW);
        infoPrint("Device state updated to OFF via HTTP");
      }
    }
  }
}

void saveConfigToEEPROM() {
  DeviceConfig configToSave;
  configToSave.magicNumber = CONFIG_MAGIC_NUMBER;
  strncpy(configToSave.ssid, savedConfig.ssid, sizeof(configToSave.ssid));
  strncpy(configToSave.password, savedConfig.password, sizeof(configToSave.password));
  strncpy(configToSave.deviceId, savedConfig.deviceId, sizeof(configToSave.deviceId));
  strncpy(configToSave.userId, savedConfig.userId, sizeof(configToSave.userId));
  strncpy(configToSave.userEmail, savedConfig.userEmail, sizeof(configToSave.userEmail));
  configToSave.wasProvisioned = !provisioningMode;

  EEPROM.put(CONFIG_START_ADDR, configToSave);
  if (EEPROM.commit()) {
    infoPrint("Configuration saved to EEPROM");
  } else {
    errorPrint("Failed to save configuration to EEPROM");
  }
}

void loadConfigFromEEPROM() {
  DeviceConfig loadedConfig;
  EEPROM.get(CONFIG_START_ADDR, loadedConfig);

  if (loadedConfig.magicNumber == CONFIG_MAGIC_NUMBER) {
    deviceId = String(loadedConfig.deviceId);
    currentUserId = String(loadedConfig.userId);
    currentUserEmail = String(loadedConfig.userEmail);
    strncpy(savedConfig.ssid, loadedConfig.ssid, sizeof(savedConfig.ssid));
    strncpy(savedConfig.password, loadedConfig.password, sizeof(savedConfig.password));
    strncpy(savedConfig.deviceId, loadedConfig.deviceId, sizeof(savedConfig.deviceId));
    strncpy(savedConfig.userId, loadedConfig.userId, sizeof(savedConfig.userId));
    strncpy(savedConfig.userEmail, loadedConfig.userEmail, sizeof(savedConfig.userEmail));
    provisioningMode = !loadedConfig.wasProvisioned;

    infoPrint("Loaded config from EEPROM");
    debugPrint("Device ID: " + deviceId);
    debugPrint("Provisioning mode: " + String(provisioningMode ? "true" : "false"));
  } else {
    warnPrint("No valid config found in EEPROM");
    provisioningMode = true;
  }
}

void factoryReset() {
  warnPrint("Initiating factory reset...");

  if (Firebase.ready() && !deviceId.isEmpty()) {
    updateDeviceStatus("ARCHIVED");
    delay(500);
  }

  for (int i = 0; i < EEPROM_SIZE; i++) {
    EEPROM.write(i, 0);
  }
  if (EEPROM.commit()) {
    infoPrint("EEPROM erased successfully");
  } else {
    errorPrint("Failed to erase EEPROM");
  }

  deviceId = "";
  currentUserId = "";
  currentUserEmail = "";
  provisioningMode = true;

  WiFi.disconnect(true);
  delay(1000);

  infoPrint("Restarting after factory reset...");
  ESP.restart();
}

void connectWithSavedCredentials() {
  if (strlen(savedConfig.ssid) == 0) {
    errorPrint("No saved WiFi credentials");
    startProvisioningAP();
    return;
  }

  infoPrint("Connecting to: " + String(savedConfig.ssid));
  WiFi.begin(savedConfig.ssid, savedConfig.password);
  WiFi.setAutoReconnect(true);
  WiFi.persistent(true);
  WiFi.setSleep(false);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    digitalWrite(LED_PIN, attempts % 2);
    delay(500);
    attempts++;
    debugPrint("Connection attempt " + String(attempts) + ", status: " + String(WiFi.status()));
  }

  if (WiFi.status() == WL_CONNECTED) {
    infoPrint("WiFi Connected! IP: " + WiFi.localIP().toString());
    setupNTP();
    initializeFirebase();
  } else {
    errorPrint("Failed to connect, status: " + String(WiFi.status()));
    startProvisioningAP();
  }
}

void startProvisioningAP() {
  provisioningMode = true;
  if (WiFi.softAP("Homuino-Provisioning", NULL, 1, 0, 1)) {
    infoPrint("AP Started: " + WiFi.softAPIP().toString());
    saveConfigToEEPROM();
  } else {
    errorPrint("Failed to start AP");
  }
}

void setupWebServer() {
  server.on("/", HTTP_GET, []() {
    infoPrint("Provisioning page accessed");
    server.send(200, "text/html",
      "<html><body>"
      "<h1>Homuino Setup</h1>"
      "<form action='/save' method='POST'>"
      "WiFi SSID: <input type='text' name='ssid' required><br>"
      "Password: <input type='password' name='password'><br>"
      "Device ID: <input type='text' name='deviceId' required><br>"
      "User ID: <input type='text' name='userId' required><br>"
      "User Email: <input type='email' name='userEmail' required><br>"
      "<input type='submit' value='Save'>"
      "</form></body></html>"
    );
  });

  server.on("/save", HTTP_POST, []() {
    String ssid = server.arg("ssid");
    String password = server.arg("password");
    deviceId = server.arg("deviceId");
    currentUserId = server.arg("userId");
    currentUserEmail = server.arg("userEmail");

    if (ssid.length() == 0 || deviceId.length() == 0 || currentUserId.length() == 0 || currentUserEmail.length() == 0) {
      server.send(400, "text/plain", "All fields except password are required");
      return;
    }

    infoPrint("Received provisioning request");
    debugPrint("New SSID: " + ssid);
    debugPrint("New Device ID: " + deviceId);

    infoPrint("Connecting to: " + ssid);
    WiFi.begin(ssid.c_str(), password.c_str());

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
      digitalWrite(LED_PIN, attempts % 2);
      delay(500);
      attempts++;
      debugPrint("Connection attempt " + String(attempts) + ", status: " + String(WiFi.status()));
    }

    if (WiFi.status() == WL_CONNECTED) {
      infoPrint("WiFi connected");
      server.send(200, "text/plain", "WiFi connected. Configuring device...");

      strncpy(savedConfig.ssid, ssid.c_str(), sizeof(savedConfig.ssid));
      strncpy(savedConfig.password, password.c_str(), sizeof(savedConfig.password));
      strncpy(savedConfig.deviceId, deviceId.c_str(), sizeof(savedConfig.deviceId));
      strncpy(savedConfig.userId, currentUserId.c_str(), sizeof(savedConfig.userId));
      strncpy(savedConfig.userEmail, currentUserEmail.c_str(), sizeof(savedConfig.userEmail));
      saveConfigToEEPROM();

      setupNTP();
      initializeFirebase();
    } else {
      errorPrint("WiFi connection failed");
      server.send(200, "text/plain", "WiFi connection failed");
    }
  });

  server.begin();
  infoPrint("Web server started on port 80");
}

void initializeFirebase() {
  config.api_key = API_KEY;
  config.database_url = FIREBASE_URL;
  config.token_status_callback = tokenStatusCallback;
  config.timeout.serverResponse = 20000;
  config.timeout.sslHandshake = 20000;

  auth.user.email = DEVICE_EMAIL;
  auth.user.password = DEVICE_PASSWORD;

  infoPrint("Initializing Firebase...");
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  int wait = 0;
  while (!Firebase.ready() && wait++ < 10) {
    delay(500);
  }

  if (Firebase.ready()) {
    signupOK = true;
    isConnected = true;
    infoPrint("Firebase ready: true");

    delay(500);

    String path = "devices/" + deviceId;
    infoPrint("Updating device path: " + path);
    if (Firebase.RTDB.setString(&fbdo, path + "/ownerId", currentUserId) &&
        Firebase.RTDB.setString(&fbdo, path + "/userEmail", currentUserEmail)) {
      updateDeviceStatus("ONLINE");
    }
    Firebase.RTDB.setBool(&fbdo, path + "/isOn", false);
    Firebase.RTDB.setString(&fbdo, path + "/switchState", "OFF");

    setupFirebaseStream();
    blinkLED(5, 200);
    apShutdownTime = millis() + apShutdownDelay;
  } else {
    errorPrint("Firebase initialization failed");
  }
}

void checkTimers() {
  if (!Firebase.ready() || deviceId.isEmpty() || millis() - lastTimerCheck < timerCheckInterval) {
    return;
  }

  String timerPath = "devices/" + deviceId + "/timers";
  if (Firebase.RTDB.getJSON(&fbdo, timerPath)) {
    FirebaseJson *json = fbdo.jsonObjectPtr();
    size_t count = json->iteratorBegin();

    struct tm timeinfo;
    if (getLocalTime(&timeinfo)) {
      char currentTime[6];
      snprintf(currentTime, sizeof(currentTime), "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);

      for (size_t i = 0; i < count; i++) {
        String key;
        String value;
        int type = 0;
        json->iteratorGet(i, type, key, value);

        if (type == FirebaseJson::JSON_OBJECT && key.startsWith("timer_")) {
          FirebaseJsonData timeData, actionData, enabledData;
          
          if (json->get(timeData, key + "/time") &&
              json->get(actionData, key + "/action") &&
              json->get(enabledData, key + "/enabled")) {

            String timerTime = timeData.stringValue;
            String timerAction = actionData.stringValue;
            bool timerEnabled = enabledData.boolValue;

            if (timerEnabled && timerTime == currentTime) {
              bool newState = (timerAction == "turn_on");
              if (newState != lastIsOnState) {
                Firebase.RTDB.setBool(&fbdo, "devices/" + deviceId + "/isOn", newState);
                infoPrint("Timer triggered: " + timerAction + " at " + timerTime);
                delay(1000);
              }
            }
          }
        }
      }
    }
    json->iteratorEnd();
    lastTimerCheck = millis();
  } else {
    errorPrint("Failed to get timers: " + fbdo.errorReason());
  }
}

void setup() {
  Serial.begin(115200);
  while (!Serial);

  infoPrint("Starting Homuino Device");

  EEPROM.begin(EEPROM_SIZE);
  pinMode(RESET_BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  myServo.setPeriodHertz(50);
  myServo.attach(SERVO_PIN, SERVO_MIN, SERVO_MAX);
  myServo.write(0); // Initialize to OFF position
  infoPrint("Hardware initialized");

  if (digitalRead(RESET_BUTTON_PIN) == LOW) {
    delay(5000);
    if (digitalRead(RESET_BUTTON_PIN) == LOW) {
      factoryReset();
    }
  }

  loadConfigFromEEPROM();

  if (!provisioningMode && deviceId.length() > 0) {
    infoPrint("Attempting connection with saved credentials");
    connectWithSavedCredentials();

    if (WiFi.status() != WL_CONNECTED) {
      warnPrint("Connection failed, starting provisioning AP");
      startProvisioningAP();
    }
  } else {
    infoPrint("Starting in provisioning mode");
    startProvisioningAP();
  }

  setupWebServer();
}

void loop() {
  server.handleClient();
  checkTimers();

  if (digitalRead(RESET_BUTTON_PIN) == LOW) {
    delay(5000);
    if (digitalRead(RESET_BUTTON_PIN) == LOW) {
      factoryReset();
    }
  }

  if (apShutdownTime > 0 && millis() > apShutdownTime) {
    disableAP();
    apShutdownTime = 0;
  }

  if (Firebase.ready() && isConnected && !deviceId.isEmpty()) {
    if (fbdo.streamTimeout()) {
      setupFirebaseStream();
    }

    if (millis() - lastHttpGetAttempt > httpGetInterval) {
      checkFirebaseData();
      lastHttpGetAttempt = millis();
    }

    if (millis() - lastReconnectAttempt > reconnectInterval) {
      String path = "devices/" + deviceId;

      if (!Firebase.RTDB.setInt(&fbdo, path + "/lastSeen", millis())) {
        if (fbdo.httpCode() == FIREBASE_ERROR_TCP_ERROR_CONNECTION_REFUSED ||
            fbdo.httpCode() == FIREBASE_ERROR_TCP_ERROR_CONNECTION_LOST) {
          isConnected = false;
          updateDeviceStatus("OFFLINE");
        }
      } else {
        updateDeviceStatus("ONLINE");
      }

      lastReconnectAttempt = millis();
    }
  }
  else if (!Firebase.ready() && !deviceId.isEmpty()) {
    Firebase.reconnectWiFi(true);
    if (Firebase.ready()) {
      isConnected = true;
      signupOK = true;
      updateDeviceStatus("ONLINE");
      setupFirebaseStream();
    } else {
      updateDeviceStatus("OFFLINE");
    }
  }

  delay(100);
}
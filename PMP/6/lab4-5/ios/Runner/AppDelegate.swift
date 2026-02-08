import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "com.example.lab4_5/battery", binaryMessenger: controller.binaryMessenger)
    let alarmChannel = FlutterMethodChannel(name: "com.example.lab4_5/alarm", binaryMessenger: controller.binaryMessenger)

    // Battery Channel
    batteryChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getBatteryLevel" {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        if batteryLevel >= 0 {
          result(batteryLevel)
        } else {
          result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Alarm Channel
    alarmChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "setAlarm" {
        guard let args = call.arguments as? [String: Int],
              let hour = args["hour"],
              let minute = args["minute"] else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Hour or minute is null", details: nil))
          return
        }
        // iOS does not have a direct equivalent to Android's AlarmClock intent
        // For simplicity, we'll return an error as iOS alarm setting requires user interaction via the Clock app
        result(FlutterError(code: "UNSUPPORTED", message: "Setting alarms programmatically is not supported on iOS", details: nil))
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
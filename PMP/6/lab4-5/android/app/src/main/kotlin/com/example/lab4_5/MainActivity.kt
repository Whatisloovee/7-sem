package com.example.lab4_5

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.location.LocationManager
import android.content.Context
import android.content.Intent
import android.os.BatteryManager
import android.provider.AlarmClock
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val GPS_CHANNEL = "com.example.lab4_5/gps"
    private val BATTERY_CHANNEL = "com.example.lab4_5/battery"
    private val ALARM_CHANNEL = "com.example.lab4_5/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // GPS Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GPS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isGpsEnabled") {
                val isGpsEnabled = isGpsEnabled()
                result.success(isGpsEnabled)
            } else {
                result.notImplemented()
            }
        }

        // Battery Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Alarm Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAlarm") {
                val hour = call.argument<Int>("hour")
                val minute = call.argument<Int>("minute")
                if (hour != null && minute != null) {
                    try {
                        setAlarm(hour, minute)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Не удалось открыть приложение Часы: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Час или минута не указаны", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isGpsEnabled(): Boolean {
        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun setAlarm(hour: Int, minute: Int) {
        val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
            putExtra(AlarmClock.EXTRA_HOUR, hour)
            putExtra(AlarmClock.EXTRA_MINUTES, minute)
            putExtra(AlarmClock.EXTRA_MESSAGE, "Plant Shop Alarm")
            putExtra(AlarmClock.EXTRA_SKIP_UI, false) // Показываем интерфейс для подтверждения
        }
        if (intent.resolveActivity(packageManager) != null) {
            try {
                startActivity(intent)
                Toast.makeText(this, "Подтвердите будильник на $hour:${minute.toString().padStart(2, '0')} в приложении Часы", Toast.LENGTH_LONG).show()
            } catch (e: SecurityException) {
                // В случае ошибки разрешения открываем список будильников
                val fallbackIntent = Intent(AlarmClock.ACTION_SHOW_ALARMS)
                if (fallbackIntent.resolveActivity(packageManager) != null) {
                    startActivity(fallbackIntent)
                    Toast.makeText(this, "Добавьте будильник на $hour:${minute.toString().padStart(2, '0')} вручную в приложении Часы", Toast.LENGTH_LONG).show()
                } else {
                    Toast.makeText(this, "Приложение Часы недоступно", Toast.LENGTH_SHORT).show()
                    throw Exception("Приложение Часы недоступно")
                }
            }
        } else {
            Toast.makeText(this, "Приложение Часы недоступно", Toast.LENGTH_SHORT).show()
            throw Exception("Приложение Часы недоступно")
        }
    }
}
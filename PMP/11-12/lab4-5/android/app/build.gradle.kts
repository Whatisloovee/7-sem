plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lab4_5"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
        isCoreLibraryDesugaringEnabled = true   // ← ЭТО РЕШАЕТ ОШИБКУ flutter_local_notifications
        // ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.lab4_5"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."        // ← без точки!
}

// ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
// ЭТОТ БЛОК В САМЫЙ КОНЕЦ ФАЙЛА (после flutter { })
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
}
// ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
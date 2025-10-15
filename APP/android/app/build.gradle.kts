plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.SN.weatherly"
    compileSdk = 36  // Updated from 34 to 36 to resolve plugin compatibility
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"  // Simplified syntax
    }

    defaultConfig {
        applicationId = "com.SN.weatherly"
        minSdk = flutter.minSdkVersion
        targetSdk = 36  // Updated from 34 to 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val rootGoogleServices = file("../../google-services.json")
val googleServicesJson = file("google-services.json")
if (rootGoogleServices.exists()) {
    rootGoogleServices.copyTo(googleServicesJson, overwrite = true)
} else if (!googleServicesJson.exists()) {
    googleServicesJson.writeText("""
    {
      "project_info": {
        "project_number": "1234567890",
        "project_id": "mock-potaleaf",
        "storage_bucket": "mock-potaleaf.appspot.com"
      },
      "client": [
        {
          "client_info": {
            "mobilesdk_app_id": "1:1234567890:android:abcdef123456",
            "android_client_info": {
              "package_name": "com.example.alya_project"
            }
          },
          "oauth_client": [],
          "api_key": [
            {
              "current_key": "mock_api_key_for_local_testing"
            }
          ],
          "services": {
            "appinvite_service": {
              "other_platform_oauth_client": []
            }
          }
        }
      ],
      "configuration_version": "3"
    }
    """.trimIndent())
}

android {
    namespace = "com.example.alya_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.alya_project"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

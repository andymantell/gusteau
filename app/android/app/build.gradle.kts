import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing, in priority order:
//
// 1. key.properties (never committed — see android/.gitignore) pointing
//    at the real, CloudShell-generated keystore. Exists locally only if
//    the owner has generated it, or in CI via the ANDROID_KEYSTORE_*
//    secrets that ci.yml/release.yml write out before this build runs.
//    This is the permanent path — see docs/planning/ci-cd.md, "Android
//    signing".
// 2. sideload.keystore.jks, checked into the repo with a fixed,
//    non-secret password. TEMPORARY: stands in for #1 until the owner
//    can reach AWS CloudShell to generate the real keystore (blocked as
//    of this commit — see ci-cd.md). Every build using it shares one
//    identity, which is the only property that actually matters for
//    upgrades to install cleanly; the password being public is an
//    accepted, temporary risk tracked in ci-cd.md.
// 3. Neither present (local dev without either set up) — falls back to
//    debug signing so `flutter run`/`flutter build apk` still work.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val sideloadKeystoreFile = file("sideload.keystore.jks")

android {
    namespace = "com.gusteau.gusteau"
    // Overrides Flutter's own default (36): flutter_secure_storage 11.x
    // requires compiling against 37 or later, checked by AGP's AAR
    // metadata task at build time.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gusteau.gusteau"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        } else if (sideloadKeystoreFile.exists()) {
            create("release") {
                storeFile = sideloadKeystoreFile
                storePassword = "sideload123"
                keyAlias = "sideload"
                keyPassword = "sideload123"
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists() || sideloadKeystoreFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Neither the real nor the temporary sideload keystore
                // is available — debug signing keeps local builds
                // working rather than failing outright.
                signingConfigs.getByName("debug")
            }
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

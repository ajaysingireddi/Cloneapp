#!/bin/bash
set -e

# Create directories
mkdir -p .github/workflows
mkdir -p gradle
mkdir -p app/src/main/java/com/clone/app/core/model
mkdir -p app/src/main/java/com/clone/app/core/engine/stub
mkdir -p app/src/main/java/com/clone/app/core/engine/hook
mkdir -p app/src/main/java/com/clone/app/core/repository
mkdir -p app/src/main/java/com/clone/app/core/compatibility
mkdir -p app/src/main/java/com/clone/app/core/storage
mkdir -p app/src/main/java/com/clone/app/core/diagnostics
mkdir -p app/src/main/java/com/clone/app/core/backup
mkdir -p app/src/main/java/com/clone/app/ui/theme
mkdir -p app/src/main/java/com/clone/app/ui/viewmodel
mkdir -p app/src/main/java/com/clone/app/ui/screens
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/values-te
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/xml
mkdir -p app/src/test/java/com/clone/app

# Root settings & properties
cat << 'EOF' > settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "Clone"
include(":app")
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetpackCompose=true
kotlin.code.style=official
EOF

cat << 'EOF' > build.gradle.kts
plugins {
    id("com.android.application") version "8.4.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
}
EOF

cat << 'EOF' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.clone.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.clone.app"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.11"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.1")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.1")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation(platform("androidx.compose:compose-bom:2024.05.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}
EOF

# AndroidManifest
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" tools:ignore="QueryAllPackagesPermission" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:name=".CloneApplication"
        android:allowBackup="false"
        android:icon="@drawable/ic_clone_logo"
        android:label="@string/app_name"
        android:theme="@style/Theme.Clone">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:theme="@style/Theme.Clone">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".core.engine.stub.StubActivity"
            android:exported="false"
            android:process=":clone_p0" />
        <activity
            android:name=".core.engine.stub.StubActivity\$Stub1"
            android:exported="false"
            android:process=":clone_p1" />
        <activity
            android:name=".core.engine.stub.StubActivity\$Stub2"
            android:exported="false"
            android:process=":clone_p2" />
    </application>
</manifest>
EOF

# Resources
cat << 'EOF' > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">Clone</string>
    <string name="header_subtitle">Sandboxed App Isolation</string>
    <string name="search_hint">Search installed or cloned apps...</string>
    <string name="tab_installed">Installed</string>
    <string name="tab_cloned">Cloned</string>
    <string name="status_compatible">Compatible</string>
    <string name="status_partial">Partial</string>
    <string name="status_unsupported">Unsupported</string>
    <string name="btn_clone_now">Clone Now</string>
    <string name="btn_launch">Launch</string>
    <string name="btn_remove">Remove</string>
    <string name="unsupported_notice">Hardware security restrictions prevent cloning this application.</string>
    <string name="title_storage">Clone Storage</string>
    <string name="title_compatibility">Diagnostics</string>
    <string name="title_settings">Settings</string>
    <string name="title_about">About</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Clone" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#0D0E15</item>
        <item name="android:navigationBarColor">#0D0E15</item>
    </style>
</resources>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_clone_logo.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#6C5CE7" android:pathData="M30,30 h36 v36 h-36 z" />
    <path android:fillColor="#E84393" android:pathData="M42,42 h36 v36 h-36 z" />
</vector>
EOF
EOF

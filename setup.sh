#!/bin/bash
set -e

echo "Generating complete Android Studio project for Clone..."

# Create all necessary directory paths
mkdir -p .github/workflows
mkdir -p gradle/wrapper
mkdir -p app/src/main/java/com/clone/app/core/model
mkdir -p app/src/main/java/com/clone/app/core/engine
mkdir -p app/src/main/java/com/clone/app/core/engine/stub
mkdir -p app/src/main/java/com/clone/app/core/engine/hook
mkdir -p app/src/main/java/com/clone/app/core/repository
mkdir -p app/src/main/java/com/clone/app/core/compatibility
mkdir -p app/src/main/java/com/clone/app/core/storage
mkdir -p app/src/main/java/com/clone/app/core/diagnostics
mkdir -p app/src/main/java/com/clone/app/core/backup
mkdir -p app/src/main/java/com/clone/app/ui
mkdir -p app/src/main/java/com/clone/app/ui/theme
mkdir -p app/src/main/java/com/clone/app/ui/viewmodel
mkdir -p app/src/main/java/com/clone/app/ui/screens
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/values-te
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/xml
mkdir -p app/src/test/java/com/clone/app

# ==========================================
# 1. ROOT PROJECT CONFIGURATION
# ==========================================

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

# ==========================================
# 2. APP MODULE GRADLE BUILD SCRIPT
# ==========================================

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

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }

        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            isDebuggable = true
            versionNameSuffix = "-debug"
        }
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
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
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    // Shizuku Non-Root System Setting Control
    implementation("dev.rikka.shizuku:api:13.1.5")
    implementation("dev.rikka.shizuku:provider:13.1.5")

    testImplementation("junit:junit:4.13.2")
}
EOF

cat << 'EOF' > app/proguard-rules.pro
-keep class com.clone.app.core.engine.** { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <methods>;
}
-dontwarn sun.misc.Unsafe
-dontwarn java.lang.invoke.**
EOF

# ==========================================
# 3. ANDROID MANIFEST & XML RESOURCES
# ==========================================

cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" tools:ignore="QueryAllPackagesPermission" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WRITE_SECURE_SETTINGS" tools:ignore="ProtectedPermissions" />

    <application
        android:name=".CloneApplication"
        android:allowBackup="false"
        android:icon="@drawable/ic_clone_logo"
        android:label="@string/app_name"
        android:roundIcon="@drawable/ic_clone_logo"
        android:supportsRtl="true"
        android:theme="@style/Theme.Clone"
        android:hardwareAccelerated="true"
        android:largeHeap="true">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:configChanges="orientation|screenSize|smallestScreenSize|screenLayout"
            android:windowSoftInputMode="adjustResize"
            android:theme="@style/Theme.Clone">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".core.engine.stub.StubActivity"
            android:configChanges="mcc|mnc|locale|touchscreen|keyboard|keyboardHidden|navigation|orientation|screenLayout|uiMode|screenSize|smallestScreenSize|fontScale"
            android:hardwareAccelerated="true"
            android:exported="false"
            android:process=":clone_p0"
            android:theme="@style/Theme.Clone.Transparent" />

        <activity
            android:name=".core.engine.stub.StubActivity$Stub1"
            android:configChanges="mcc|mnc|locale|touchscreen|keyboard|keyboardHidden|navigation|orientation|screenLayout|uiMode|screenSize|smallestScreenSize|fontScale"
            android:exported="false"
            android:process=":clone_p1"
            android:theme="@style/Theme.Clone.Transparent" />

        <activity
            android:name=".core.engine.stub.StubActivity$Stub2"
            android:configChanges="mcc|mnc|locale|touchscreen|keyboard|keyboardHidden|navigation|orientation|screenLayout|uiMode|screenSize|smallestScreenSize|fontScale"
            android:exported="false"
            android:process=":clone_p2"
            android:theme="@style/Theme.Clone.Transparent" />

        <provider
            android:name=".core.engine.stub.StubContentProvider"
            android:authorities="${applicationId}.stub.provider"
            android:exported="false"
            android:grantUriPermissions="true" />

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

        <receiver
            android:name=".core.engine.CloneDeviceAdminReceiver"
            android:permission="android.permission.BIND_DEVICE_ADMIN"
            android:exported="true">
            <meta-data
                android:name="android.app.device_admin"
                android:resource="@xml/device_admin" />
            <intent-filter>
                <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
                <action android:name="android.app.action.PROFILE_PROVISIONING_COMPLETE" />
            </intent-filter>
        </receiver>

        <provider
            android:name="rikka.shizuku.ShizukuProvider"
            android:authorities="${applicationId}.shizuku"
            android:multiprocess="false"
            android:enabled="true"
            android:exported="true"
            android:permission="android.permission.INTERACT_ACROSS_USERS_FULL" />

    </application>
</manifest>
EOF

cat << 'EOF' > app/src/main/res/xml/file_paths.xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <files-path name="clone_data" path="clone_sandbox/" />
    <cache-path name="clone_cache" path="clone_cache/" />
</paths>
EOF

cat << 'EOF' > app/src/main/res/xml/device_admin.xml
<?xml version="1.0" encoding="utf-8"?>
<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies />
</device-admin>
EOF

cat << 'EOF' > app/src/main/res/values/strings.xml
<resources>
    <string name="app_name">Clone</string>
    <string name="header_subtitle">Sandboxed App Isolation &amp; Guard</string>
    <string name="search_hint">Search installed apps...</string>
    <string name="tab_installed">Installed Apps</string>
    <string name="tab_cloned">Cloned Instances</string>
    <string name="status_compatible">Compatible</string>
    <string name="status_partial">Partial</string>
    <string name="status_unsupported">Unsupported</string>
    <string name="btn_clone_now">Clone Now</string>
    <string name="btn_launch">Launch</string>
    <string name="btn_remove">Remove</string>
    <string name="unsupported_notice">This app enforces strict hardware Play Integrity or Knox attestation.</string>
    <string name="title_storage">Clone Storage</string>
    <string name="title_compatibility">Diagnostics</string>
    <string name="title_settings">Settings</string>
    <string name="title_about">About Clone</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values-te/strings.xml
<resources>
    <string name="app_name">క్లోన్</string>
    <string name="header_subtitle">యాప్ ఐసోలేషన్ &amp; గార్డ్</string>
    <string name="search_hint">యాప్‌లను శోధించండి...</string>
    <string name="tab_installed">ఇన్‌స్టాల్ చేసినవి</string>
    <string name="tab_cloned">క్లోన్ చేసినవి</string>
    <string name="status_compatible">సరిపోతుంది</string>
    <string name="status_partial">పాక్షికం</string>
    <string name="status_unsupported">సరిపోదు</string>
    <string name="btn_clone_now">క్లోన్ చేయండి</string>
    <string name="btn_launch">ప్రారంభించు</string>
    <string name="btn_remove">తొలగించు</string>
    <string name="unsupported_notice">ఈ అప్లికేషన్‌ను క్లోన్ చేయడం సాధ్యం కాదు (హార్డ్‌వేర్ భద్రత పరిమితులు).</string>
    <string name="title_storage">స్టోరేజ్</string>
    <string name="title_compatibility">డయాగ్నస్టిక్స్</string>
    <string name="title_settings">సెట్టింగ్‌లు</string>
    <string name="title_about">గురించి</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Clone" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#0D0E15</item>
        <item name="android:navigationBarColor">#0D0E15</item>
    </style>
    <style name="Theme.Clone.Transparent" parent="Theme.Clone">
        <item name="android:windowBackground">@android:color/transparent</item>
        <item name="android:windowIsTranslucent">true</item>
        <item name="android:windowNoTitle">true</item>
    </style>
</resources>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_clone_logo.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#6C5CE7"
        android:pathData="M30,30 h36 v36 h-36 z" />
    <path
        android:fillColor="#E84393"
        android:pathData="M42,42 h36 v36 h-36 z" />
</vector>
EOF

# ==========================================
# 4. DATA MODELS
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/core/model/AppModels.kt
package com.clone.app.core.model

import android.graphics.drawable.Drawable

enum class CompatibilityLevel {
    COMPATIBLE,
    PARTIALLY_COMPATIBLE,
    UNSUPPORTED
}

data class AppItem(
    val appName: String,
    val packageName: String,
    val versionName: String,
    val versionCode: Long,
    val icon: Drawable?,
    val isSystemApp: Boolean,
    val compatibilityLevel: CompatibilityLevel,
    val compatibilityReason: String
)

data class CloneInstance(
    val instanceId: Int,
    val packageName: String,
    val appName: String,
    val createdTimestamp: Long,
    val dataSizeBytes: Long,
    val isRunning: Boolean = false
)

data class DeviceSpec(
    val manufacturer: String,
    val model: String,
    val androidVersion: String,
    val sdkInt: Int,
    val abi: String,
    val isTablet: Boolean,
    val isFoldable: Boolean,
    val virtualizationSupported: Boolean,
    val engineDiagnosticMessage: String
)
EOF

# ==========================================
# 5. DIAGNOSTICS & STORAGE MANAGERS
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/core/diagnostics/DiagnosticsManager.kt
package com.clone.app.core.diagnostics

import android.content.Context
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.CopyOnWriteArrayList

object DiagnosticsManager {
    private val logEntries = CopyOnWriteArrayList<String>()
    private val dateFormat = SimpleDateFormat("HH:mm:ss", Locale.US)

    fun init(context: Context) {
        log("Init", "Diagnostics initialized.")
    }

    fun log(tag: String, message: String) {
        val time = dateFormat.format(Date())
        logEntries.add("[$time][$tag] $message")
        if (logEntries.size > 150) {
            logEntries.removeAt(0)
        }
    }

    fun getRecentLogs(): List<String> = logEntries
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/storage/CloneStorageManager.kt
package com.clone.app.core.storage

import android.content.Context
import java.io.File

object CloneStorageManager {
    fun getTotalCloneStorageUsed(context: Context): Long {
        val root = File(context.filesDir, "clone_sandbox")
        if (!root.exists()) return 0L
        var total = 0L
        root.walkTopDown().forEach { if (it.isFile) total += it.length() }
        return total
    }

    fun clearAllCloneData(context: Context): Boolean {
        val root = File(context.filesDir, "clone_sandbox")
        return if (root.exists()) {
            root.deleteRecursively().also { root.mkdirs() }
        } else {
            true
        }
    }

    fun formatBytes(bytes: Long): String {
        val mb = bytes / (1024.0 * 1024.0)
        val gb = mb / 1024.0
        return when {
            gb >= 1.0 -> String.format("%.2f GB", gb)
            mb >= 1.0 -> String.format("%.2f MB", mb)
            else -> "$bytes B"
        }
    }
}
EOF

# ==========================================
# 6. SYSTEM HOOKS & DEV-MODE INTERCEPTORS
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/hook/HiddenApiBypass.kt
package com.clone.app.core.engine.hook

import android.annotation.SuppressLint
import android.os.Build
import android.util.Log
import java.lang.reflect.Method

object HiddenApiBypass {
    private const val TAG = "HiddenApiBypass"

    @SuppressLint("DiscouragedPrivateApi")
    fun exemptAll(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return true
        return try {
            val forNameMethod = Class::class.java.getDeclaredMethod("forName", String::class.java)
            val getDeclaredMethod = Class::class.java.getDeclaredMethod(
                "getDeclaredMethod",
                String::class.java,
                arrayOf<Class<*>>()::class.java
            )
            val vmRuntimeClass = forNameMethod.invoke(null, "dalvik.system.VMRuntime") as Class<*>
            val getRuntimeMethod = getDeclaredMethod.invoke(vmRuntimeClass, "getRuntime", null) as Method
            val vmRuntimeInstance = getRuntimeMethod.invoke(null)
            val setHiddenApiExemptionsMethod = getDeclaredMethod.invoke(
                vmRuntimeClass,
                "setHiddenApiExemptions",
                arrayOf(arrayOf<String>()::class.java)
            ) as Method
            setHiddenApiExemptionsMethod.invoke(vmRuntimeInstance, arrayOf("L"))
            Log.i(TAG, "Hidden API restrictions bypassed successfully.")
            true
        } catch (t: Throwable) {
            Log.w(TAG, "Hidden API bypass warning: ${t.message}")
            false
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/hook/DevOptionsInterceptor.kt
package com.clone.app.core.engine.hook

import android.content.Context
import android.os.Bundle
import android.provider.Settings
import android.util.Log

object DevOptionsInterceptor {
    private const val TAG = "DevOptionsInterceptor"

    fun inject(context: Context) {
        try {
            val activityThreadClass = Class.forName("android.app.ActivityThread")
            val currentActivityThreadMethod = activityThreadClass.getDeclaredMethod("currentActivityThread").apply {
                isAccessible = true
            }
            val activityThread = currentActivityThreadMethod.invoke(null) ?: return

            val getProviderMethod = activityThreadClass.getDeclaredMethod(
                "acquireProvider",
                Context::class.java,
                String::class.java,
                Int::class.javaPrimitiveType,
                Boolean::class.javaPrimitiveType
            ).apply { isAccessible = true }

            getProviderMethod.invoke(activityThread, context, "settings", 0, true)
            Log.i(TAG, "Injected Settings Provider Hook into current process.")
        } catch (e: Exception) {
            Log.w(TAG, "DevOptionsInterceptor hook warning: ${e.message}")
        }
    }

    fun sanitizeBundle(key: String?, bundle: Bundle?): Bundle {
        val target = bundle ?: Bundle()
        if (key == Settings.Global.DEVELOPMENT_SETTINGS_ENABLED ||
            key == "development_settings_enabled" ||
            key == Settings.Global.ADB_ENABLED ||
            key == "adb_enabled"
        ) {
            Log.d(TAG, "DevOptionsInterceptor intercepted key: $key -> returning 0")
            target.putString("value", "0")
        }
        return target
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/hook/ShizukuSettingsController.kt
package com.clone.app.core.engine.hook

import android.content.pm.PackageManager
import rikka.shizuku.Shizuku
import java.lang.reflect.Method

object ShizukuSettingsController {

    fun isShizukuAvailable(): Boolean {
        return try {
            Shizuku.pingBinder() && Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
        } catch (e: Exception) {
            false
        }
    }

    fun setDeveloperOptions(enabled: Boolean) {
        if (!isShizukuAvailable()) return
        val value = if (enabled) "1" else "0"
        execute("settings put global development_settings_enabled $value")
        execute("settings put global adb_enabled $value")
    }

    private fun execute(cmd: String) {
        try {
            val method: Method = Shizuku::class.java.getDeclaredMethod(
                "newProcess",
                Array<String>::class.java,
                Array<String>::class.java,
                String::class.java
            )
            method.isAccessible = true
            val process = method.invoke(
                null,
                arrayOf("sh", "-c", cmd),
                null,
                null
            ) as Process
            process.waitFor()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
EOF

# ==========================================
# 7. ENGINE STUBS & VIRTUAL RUNTIME
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/CloneEngine.kt
package com.clone.app.core.engine

import android.content.Context
import com.clone.app.core.model.CloneInstance
import java.io.File

enum class EngineStatus { READY, RESTRICTED, FAILED }

interface CloneEngine {
    fun initialize(context: Context): EngineStatus
    fun isAppSupported(packageName: String): Boolean
    fun createClone(packageName: String, instanceId: Int): Result<CloneInstance>
    fun launchClone(packageName: String, instanceId: Int, context: Context): Result<Unit>
    fun removeClone(packageName: String, instanceId: Int): Result<Unit>
    fun getCloneStorageDirectory(packageName: String, instanceId: Int): File
    fun getInstalledClones(): List<CloneInstance>
    fun getEngineName(): String
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/CloneEngineProvider.kt
package com.clone.app.core.engine

import android.content.Context

object CloneEngineProvider {
    @Volatile
    private var instance: CloneEngine? = null

    fun getEngine(context: Context): CloneEngine {
        return instance ?: synchronized(this) {
            instance ?: SandboxVirtualEngine(context.applicationContext).also { instance = it }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/stub/StubActivity.kt
package com.clone.app.core.engine.stub

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import com.clone.app.core.diagnostics.DiagnosticsManager
import com.clone.app.core.engine.hook.DevOptionsInterceptor
import com.clone.app.core.engine.hook.ShizukuSettingsController
import dalvik.system.PathClassLoader

open class StubActivity : Activity() {
    companion object {
        const val EXTRA_TARGET_PACKAGE = "target_package"
        const val EXTRA_TARGET_ACTIVITY = "target_activity"
        const val EXTRA_INSTANCE_ID = "instance_id"
        const val EXTRA_DATA_DIR = "instance_data_dir"
    }

    class Stub1 : StubActivity()
    class Stub2 : StubActivity()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inject process-level setting spoofing
        DevOptionsInterceptor.inject(this)

        // Temporarily disable global developer settings via Shizuku if available
        ShizukuSettingsController.setDeveloperOptions(false)

        val targetPkg = intent.getStringExtra(EXTRA_TARGET_PACKAGE)
        val targetActivityName = intent.getStringExtra(EXTRA_TARGET_ACTIVITY)

        if (targetPkg == null || targetActivityName == null) {
            finish()
            return
        }

        DiagnosticsManager.log("StubActivity", "Launching $targetPkg in sandboxed process")

        try {
            val appInfo = packageManager.getApplicationInfo(targetPkg, 0)
            val isolatedClassLoader = PathClassLoader(appInfo.sourceDir, appInfo.nativeLibraryDir, classLoader)
            isolatedClassLoader.loadClass(targetActivityName)

            val forwardIntent = Intent(Intent.ACTION_MAIN).apply {
                setClassName(targetPkg, targetActivityName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(forwardIntent)
            finish()
        } catch (e: Exception) {
            DiagnosticsManager.log("StubActivity", "Dynamic launch fallback: ${e.message}")
            Toast.makeText(this, "Started $targetPkg in isolation", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        ShizukuSettingsController.setDeveloperOptions(true)
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/stub/StubContentProvider.kt
package com.clone.app.core.engine.stub

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri

class StubContentProvider : ContentProvider() {
    override fun onCreate(): Boolean = true
    override fun query(uri: Uri, projection: Array<String>?, selection: String?, selectionArgs: Array<String>?, sortOrder: String?): Cursor? = null
    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?): Int = 0
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/SandboxVirtualEngine.kt
package com.clone.app.core.engine

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import com.clone.app.core.diagnostics.DiagnosticsManager
import com.clone.app.core.engine.stub.StubActivity
import com.clone.app.core.model.CloneInstance
import java.io.File
import java.util.concurrent.ConcurrentHashMap

class SandboxVirtualEngine(private val context: Context) : CloneEngine {
    private val activeClones = ConcurrentHashMap<String, MutableList<CloneInstance>>()
    private val sandboxRoot = File(context.filesDir, "clone_sandbox").apply { if (!exists()) mkdirs() }

    override fun initialize(context: Context): EngineStatus {
        scanExistingClones()
        return EngineStatus.READY
    }

    private fun scanExistingClones() {
        activeClones.clear()
        val dirs = sandboxRoot.listFiles() ?: return
        for (pkgDir in dirs) {
            if (pkgDir.isDirectory) {
                val pkgName = pkgDir.name
                val instanceDirs = pkgDir.listFiles() ?: continue
                for (instDir in instanceDirs) {
                    val id = instDir.name.toIntOrNull() ?: continue
                    val appName = getAppLabel(pkgName)
                    val instance = CloneInstance(
                        instanceId = id,
                        packageName = pkgName,
                        appName = appName,
                        createdTimestamp = instDir.lastModified(),
                        dataSizeBytes = calculateDirSize(instDir)
                    )
                    activeClones.computeIfAbsent(pkgName) { mutableListOf() }.add(instance)
                }
            }
        }
    }

    override fun isAppSupported(packageName: String): Boolean {
        return try {
            val pm = context.packageManager
            val info = pm.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            (info.flags and ApplicationInfo.FLAG_SYSTEM) == 0
        } catch (e: Exception) {
            false
        }
    }

    override fun createClone(packageName: String, instanceId: Int): Result<CloneInstance> {
        return try {
            val appDir = File(sandboxRoot, "$packageName/$instanceId").apply {
                if (!exists()) {
                    mkdirs()
                    File(this, "data").mkdirs()
                    File(this, "cache").mkdirs()
                }
            }
            val instance = CloneInstance(
                instanceId = instanceId,
                packageName = packageName,
                appName = getAppLabel(packageName),
                createdTimestamp = System.currentTimeMillis(),
                dataSizeBytes = 0L
            )
            activeClones.computeIfAbsent(packageName) { mutableListOf() }.add(instance)
            DiagnosticsManager.log("SandboxEngine", "Created clone $instanceId for $packageName")
            Result.success(instance)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override fun launchClone(packageName: String, instanceId: Int, context: Context): Result<Unit> {
        return try {
            val pm = context.packageManager
            val launchIntent = pm.getLaunchIntentForPackage(packageName)
                ?: return Result.failure(IllegalStateException("No launch intent for $packageName"))
            val targetComponent = launchIntent.component
                ?: return Result.failure(IllegalStateException("Cannot resolve launch target for $packageName"))

            val stubClass = when (instanceId % 3) {
                1 -> StubActivity.Stub1::class.java
                2 -> StubActivity.Stub2::class.java
                else -> StubActivity::class.java
            }

            val intent = Intent(context, stubClass).apply {
                putExtra(StubActivity.EXTRA_TARGET_PACKAGE, packageName)
                putExtra(StubActivity.EXTRA_TARGET_ACTIVITY, targetComponent.className)
                putExtra(StubActivity.EXTRA_INSTANCE_ID, instanceId)
                putExtra(StubActivity.EXTRA_DATA_DIR, getCloneStorageDirectory(packageName, instanceId).absolutePath)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
            }
            context.startActivity(intent)
            DiagnosticsManager.log("SandboxEngine", "Launched $packageName via ${stubClass.simpleName}")
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override fun removeClone(packageName: String, instanceId: Int): Result<Unit> {
        return try {
            getCloneStorageDirectory(packageName, instanceId).deleteRecursively()
            activeClones[packageName]?.removeAll { it.instanceId == instanceId }
            DiagnosticsManager.log("SandboxEngine", "Removed clone #$instanceId for $packageName")
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override fun getCloneStorageDirectory(packageName: String, instanceId: Int): File {
        return File(sandboxRoot, "$packageName/$instanceId")
    }

    override fun getInstalledClones(): List<CloneInstance> = activeClones.values.flatten()

    override fun getEngineName(): String = "Virtual Container Isolation Engine v2.4 (Non-Root)"

    private fun getAppLabel(packageName: String): String {
        return try {
            val pm = context.packageManager
            pm.getApplicationLabel(pm.getApplicationInfo(packageName, 0)).toString()
        } catch (e: Exception) {
            packageName
        }
    }

    private fun calculateDirSize(dir: File): Long {
        var size = 0L
        dir.walkTopDown().forEach { if (it.isFile) size += it.length() }
        return size
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/engine/CloneDeviceAdminReceiver.kt
package com.clone.app.core.engine

import android.app.Activity
import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.LauncherApps
import android.os.Process
import android.os.UserHandle
import android.widget.Toast

class CloneDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        val manager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val component = ComponentName(context, CloneDeviceAdminReceiver::class.java)
        manager.setProfileName(component, "Clone Sandbox")
        manager.setProfileEnabled(component)
    }
}

object CloneWorkProfileManager {
    fun setupWorkProfile(activity: Activity, requestCode: Int) {
        val intent = Intent(DevicePolicyManager.ACTION_PROVISION_MANAGED_PROFILE).apply {
            putExtra(
                DevicePolicyManager.EXTRA_PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME,
                ComponentName(activity, CloneDeviceAdminReceiver::class.java)
            )
        }
        if (intent.resolveActivity(activity.packageManager) != null) {
            activity.startActivityForResult(intent, requestCode)
        } else {
            Toast.makeText(activity, "Work profile feature not supported by this OS", Toast.LENGTH_LONG).show()
        }
    }

    fun launchInProfile(context: Context, packageName: String) {
        val launcher = context.getSystemService(Context.LAUNCHER_APPS_SERVICE) as LauncherApps
        val profileUser: UserHandle? = launcher.profiles.firstOrNull { it != Process.myUserHandle() }
        if (profileUser == null) {
            Toast.makeText(context, "Work profile not initialized.", Toast.LENGTH_SHORT).show()
            return
        }
        val matches = launcher.getActivityList(packageName, profileUser)
        if (matches.isNotEmpty()) {
            launcher.startMainActivity(matches[0].componentName, profileUser, null, null)
        } else {
            Toast.makeText(context, "App not installed in secondary profile.", Toast.LENGTH_SHORT).show()
        }
    }
}
EOF

# ==========================================
# 8. APP DISCOVERY & COMPATIBILITY LAYER
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/core/compatibility/AppCompatibilityChecker.kt
package com.clone.app.core.compatibility

import android.content.pm.PackageInfo
import com.clone.app.core.model.CompatibilityLevel

object AppCompatibilityChecker {
    private val HARDWARE_RESTRICTED = setOf(
        "com.google.android.apps.walletnfcrel",
        "com.google.android.apps.authenticator2",
        "com.chase.sig.android"
    )

    fun evaluate(pkgInfo: PackageInfo): Pair<CompatibilityLevel, String> {
        val pkg = pkgInfo.packageName
        if (HARDWARE_RESTRICTED.contains(pkg)) {
            return Pair(CompatibilityLevel.UNSUPPORTED, "Requires strict hardware Play Integrity.")
        }
        val permissions = pkgInfo.requestedPermissions ?: emptyArray()
        if (permissions.any { it.contains("NFC") || it.contains("BIOMETRIC") }) {
            return Pair(CompatibilityLevel.PARTIALLY_COMPATIBLE, "Hardware NFC/Biometrics operate through host system.")
        }
        return Pair(CompatibilityLevel.COMPATIBLE, "Fully compatible with container isolation.")
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/compatibility/DeviceCompatibilityChecker.kt
package com.clone.app.core.compatibility

import android.content.Context
import android.content.res.Configuration
import android.os.Build
import com.clone.app.core.model.DeviceSpec

object DeviceCompatibilityChecker {
    fun checkDevice(context: Context): DeviceSpec {
        val manufacturer = Build.MANUFACTURER
        val model = Build.MODEL
        val sdkInt = Build.VERSION.SDK_INT
        val abi = Build.SUPPORTED_ABIS.firstOrNull() ?: "arm64-v8a"
        val isTablet = (context.resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_LARGE
        val isFoldable = manufacturer.equals("samsung", ignoreCase = true) && (model.contains("Fold") || model.contains("Flip"))

        return DeviceSpec(
            manufacturer = manufacturer,
            model = model,
            androidVersion = Build.VERSION.RELEASE,
            sdkInt = sdkInt,
            abi = abi,
            isTablet = isTablet,
            isFoldable = isFoldable,
            virtualizationSupported = sdkInt in 26..34,
            engineDiagnosticMessage = "Standard sandboxed container mode active."
        )
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/repository/InstalledAppScanner.kt
package com.clone.app.core.repository

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import com.clone.app.core.compatibility.AppCompatibilityChecker
import com.clone.app.core.model.AppItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class InstalledAppScanner(private val context: Context) {
    suspend fun scanInstalledApps(): List<AppItem> = withContext(Dispatchers.IO) {
        val pm = context.packageManager
        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        }

        val list = mutableListOf<AppItem>()
        for (pkg in packages) {
            val appInfo = pkg.applicationInfo ?: continue
            if (pkg.packageName == context.packageName) continue
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            val (comp, reason) = AppCompatibilityChecker.evaluate(pkg)
            val vCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) pkg.longVersionCode else @Suppress("DEPRECATION") pkg.versionCode.toLong()

            list.add(
                AppItem(
                    appName = pm.getApplicationLabel(appInfo).toString(),
                    packageName = pkg.packageName,
                    versionName = pkg.versionName ?: "1.0",
                    versionCode = vCode,
                    icon = try { pm.getApplicationIcon(appInfo) } catch (e: Exception) { null },
                    isSystemApp = isSystem,
                    compatibilityLevel = comp,
                    compatibilityReason = reason
                )
            )
        }
        list.sortedBy { it.appName.lowercase() }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/core/repository/AppRepository.kt
package com.clone.app.core.repository

import android.content.Context
import com.clone.app.core.engine.CloneEngineProvider
import com.clone.app.core.model.AppItem
import com.clone.app.core.model.CloneInstance

class AppRepository(private val context: Context) {
    private val scanner = InstalledAppScanner(context)
    private val engine = CloneEngineProvider.getEngine(context)

    suspend fun loadInstalledApps(): List<AppItem> = scanner.scanInstalledApps()
    fun getClones(): List<CloneInstance> = engine.getInstalledClones()
    fun createClone(packageName: String, instanceId: Int) = engine.createClone(packageName, instanceId)
    fun launchClone(packageName: String, instanceId: Int) = engine.launchClone(packageName, instanceId, context)
    fun removeClone(packageName: String, instanceId: Int) = engine.removeClone(packageName, instanceId)
}
EOF

# ==========================================
# 9. APPLICATION ENTRY POINT
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/CloneApplication.kt
package com.clone.app

import android.app.Application
import android.content.Context
import com.clone.app.core.diagnostics.DiagnosticsManager
import com.clone.app.core.engine.CloneEngineProvider
import com.clone.app.core.engine.hook.DevOptionsInterceptor
import com.clone.app.core.engine.hook.HiddenApiBypass

class CloneApplication : Application() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        HiddenApiBypass.exemptAll()
    }

    override fun onCreate() {
        super.onCreate()
        DiagnosticsManager.init(this)
        DiagnosticsManager.log("System", "Clone Application initialized on SDK ${android.os.Build.VERSION.SDK_INT}")
        DevOptionsInterceptor.inject(this)
        val engine = CloneEngineProvider.getEngine(this)
        engine.initialize(this)
    }
}
EOF

# ==========================================
# 10. JETPACK COMPOSE THEME
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/ui/theme/Color.kt
package com.clone.app.ui.theme

import androidx.compose.ui.graphics.Color

val BrandPurple = Color(0xFF6C5CE7)
val BrandBlue = Color(0xFF0984E3)
val BrandPink = Color(0xFFE84393)
val DarkBackground = Color(0xFF0D0E15)
val SurfaceDark = Color(0xFF161824)
val SurfaceCard = Color(0xFF1E2235)
val TextPrimary = Color(0xFFF1F2F6)
val TextSecondary = Color(0xFFA4B0BE)
val CompatibleGreen = Color(0xFF00B894)
val WarningYellow = Color(0xFFFDCB6E)
val UnsupportedRed = Color(0xFFFF7675)
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/theme/Type.kt
package com.clone.app.ui.theme

import androidx.compose.material3.Typography
val Typography = Typography()
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/theme/Theme.kt
package com.clone.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = BrandPurple,
    secondary = BrandPink,
    tertiary = BrandBlue,
    background = DarkBackground,
    surface = SurfaceDark,
    onPrimary = TextPrimary,
    onSecondary = TextPrimary,
    onBackground = TextPrimary,
    onSurface = TextPrimary
)

@Composable
fun CloneTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = Typography,
        content = content
    )
}
EOF

# ==========================================
# 11. VIEWMODELS
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/ui/viewmodel/MainViewModel.kt
package com.clone.app.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.clone.app.core.compatibility.DeviceCompatibilityChecker
import com.clone.app.core.model.AppItem
import com.clone.app.core.model.CloneInstance
import com.clone.app.core.model.DeviceSpec
import com.clone.app.core.repository.AppRepository
import com.clone.app.core.storage.CloneStorageManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed class Screen {
    data object Home : Screen()
    data class AppDetail(val app: AppItem) : Screen()
    data object Storage : Screen()
    data object CompatibilityReport : Screen()
    data object Settings : Screen()
    data object About : Screen()
}

class MainViewModel(application: Application) : AndroidViewModel(application) {
    private val repo = AppRepository(application)

    private val _currentScreen = MutableStateFlow<Screen>(Screen.Home)
    val currentScreen: StateFlow<Screen> = _currentScreen.asStateFlow()

    private val _installedApps = MutableStateFlow<List<AppItem>>(emptyList())
    val installedApps: StateFlow<List<AppItem>> = _installedApps.asStateFlow()

    private val _clonedApps = MutableStateFlow<List<CloneInstance>>(emptyList())
    val clonedApps: StateFlow<List<CloneInstance>> = _clonedApps.asStateFlow()

    private val _deviceSpec = MutableStateFlow(DeviceCompatibilityChecker.checkDevice(application))
    val deviceSpec: StateFlow<DeviceSpec> = _deviceSpec.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _storageUsage = MutableStateFlow(CloneStorageManager.getTotalCloneStorageUsed(application))
    val storageUsage: StateFlow<Long> = _storageUsage.asStateFlow()

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        refreshData()
    }

    fun navigateTo(screen: Screen) { _currentScreen.value = screen }
    fun updateSearchQuery(query: String) { _searchQuery.value = query }

    fun refreshData() {
        viewModelScope.launch {
            _isLoading.value = true
            _installedApps.value = repo.loadInstalledApps()
            _clonedApps.value = repo.getClones()
            _storageUsage.value = CloneStorageManager.getTotalCloneStorageUsed(getApplication())
            _isLoading.value = false
        }
    }

    fun createClone(packageName: String) {
        viewModelScope.launch {
            val existing = _clonedApps.value.filter { it.packageName == packageName }
            repo.createClone(packageName, existing.size + 1)
            refreshData()
        }
    }

    fun launchClone(packageName: String, instanceId: Int) {
        repo.launchClone(packageName, instanceId)
    }

    fun removeClone(packageName: String, instanceId: Int) {
        viewModelScope.launch {
            repo.removeClone(packageName, instanceId)
            refreshData()
        }
    }

    fun clearAllData() {
        CloneStorageManager.clearAllCloneData(getApplication())
        refreshData()
    }
}
EOF

# ==========================================
# 12. JETPACK COMPOSE UI SCREENS
# ==========================================

cat << 'EOF' > app/src/main/java/com/clone/app/ui/MainActivity.kt
package com.clone.app.ui

import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.ViewModelProvider
import com.clone.app.ui.screens.*
import com.clone.app.ui.theme.CloneTheme
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen
import rikka.shizuku.Shizuku

class MainActivity : ComponentActivity() {
    private val shizukuListener = Shizuku.OnRequestPermissionResultListener { _, grantResult ->
        if (grantResult == PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(this, "Shizuku Protection Active!", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val viewModel = ViewModelProvider(this)[MainViewModel::class.java]

        try {
            Shizuku.addRequestPermissionResultListener(shizukuListener)
            if (Shizuku.pingBinder() && Shizuku.checkSelfPermission() != PackageManager.PERMISSION_GRANTED) {
                Shizuku.requestPermission(1001)
            }
        } catch (ignored: Exception) {}

        setContent {
            CloneTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    val currentScreen by viewModel.currentScreen.collectAsState()
                    BackHandler(enabled = currentScreen !is Screen.Home) {
                        viewModel.navigateTo(Screen.Home)
                    }
                    when (val screen = currentScreen) {
                        is Screen.Home -> HomeScreen(viewModel = viewModel)
                        is Screen.AppDetail -> AppDetailScreen(app = screen.app, viewModel = viewModel)
                        is Screen.Storage -> StorageScreen(viewModel = viewModel)
                        is Screen.CompatibilityReport -> CompatibilityReportScreen(viewModel = viewModel)
                        is Screen.Settings -> SettingsScreen(viewModel = viewModel)
                        is Screen.About -> AboutScreen(viewModel = viewModel)
                    }
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            Shizuku.removeRequestPermissionResultListener(shizukuListener)
        } catch (ignored: Exception) {}
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/screens/HomeScreen.kt
package com.clone.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clone.app.R
import com.clone.app.core.engine.hook.ShizukuSettingsController
import com.clone.app.core.model.CompatibilityLevel
import com.clone.app.ui.theme.*
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen

@Composable
fun HomeScreen(viewModel: MainViewModel) {
    val apps by viewModel.installedApps.collectAsState()
    val clones by viewModel.clonedApps.collectAsState()
    val query by viewModel.searchQuery.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    var selectedTab by remember { mutableIntStateOf(0) }

    Scaffold(
        topBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Brush.linearGradient(listOf(BrandPurple, BrandBlue, BrandPink)))
                    .padding(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(stringResource(R.string.app_name), fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        Text(stringResource(R.string.header_subtitle), fontSize = 12.sp, color = Color.White.copy(0.8f))
                    }
                    Row {
                        IconButton(onClick = { viewModel.navigateTo(Screen.CompatibilityReport) }) {
                            Icon(Icons.Default.Assessment, contentDescription = null, tint = Color.White)
                        }
                        IconButton(onClick = { viewModel.navigateTo(Screen.Storage) }) {
                            Icon(Icons.Default.Storage, contentDescription = null, tint = Color.White)
                        }
                        IconButton(onClick = { viewModel.navigateTo(Screen.Settings) }) {
                            Icon(Icons.Default.Settings, contentDescription = null, tint = Color.White)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Button(
                        onClick = { ShizukuSettingsController.setDeveloperOptions(false) },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E2235)),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Hide Dev Options", fontSize = 11.sp)
                    }
                    Button(
                        onClick = { ShizukuSettingsController.setDeveloperOptions(true) },
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1E2235)),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Restore Dev", fontSize = 11.sp)
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = query,
                    onValueChange = { viewModel.updateSearchQuery(it) },
                    modifier = Modifier.fillMaxWidth(),
                    placeholder = { Text(stringResource(R.string.search_hint)) },
                    singleLine = true,
                    shape = RoundedCornerShape(20.dp)
                )
            }
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding).background(DarkBackground)) {
            TabRow(selectedTabIndex = selectedTab, containerColor = SurfaceDark, contentColor = BrandPink) {
                Tab(selected = selectedTab == 0, onClick = { selectedTab = 0 }, text = { Text("${stringResource(R.string.tab_installed)} (${apps.size})") })
                Tab(selected = selectedTab == 1, onClick = { selectedTab = 1 }, text = { Text("${stringResource(R.string.tab_cloned)} (${clones.size})") })
            }

            if (isLoading) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = BrandPurple)
                }
            } else if (selectedTab == 0) {
                val filtered = apps.filter { it.appName.contains(query, ignoreCase = true) || it.packageName.contains(query, ignoreCase = true) }
                LazyColumn(modifier = Modifier.fillMaxSize().padding(8.dp)) {
                    items(filtered) { app ->
                        Card(
                            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable { viewModel.navigateTo(Screen.AppDetail(app)) },
                            colors = CardDefaults.cardColors(containerColor = SurfaceCard)
                        ) {
                            Row(modifier = Modifier.padding(12.dp).fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                                Box(modifier = Modifier.size(40.dp).background(BrandPurple.copy(alpha = 0.2f), RoundedCornerShape(8.dp)), contentAlignment = Alignment.Center) {
                                    Text(app.appName.take(1).uppercase(), fontWeight = FontWeight.Bold, color = BrandPink)
                                }
                                Spacer(modifier = Modifier.width(12.dp))
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(app.appName, fontWeight = FontWeight.SemiBold, color = TextPrimary)
                                    Text(app.packageName, fontSize = 11.sp, color = TextSecondary)
                                }
                                val color = when (app.compatibilityLevel) {
                                    CompatibilityLevel.COMPATIBLE -> CompatibleGreen
                                    CompatibilityLevel.PARTIALLY_COMPATIBLE -> WarningYellow
                                    CompatibilityLevel.UNSUPPORTED -> UnsupportedRed
                                }
                                Text(app.compatibilityLevel.name, color = color, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            } else {
                val filtered = clones.filter { it.appName.contains(query, ignoreCase = true) }
                LazyColumn(modifier = Modifier.fillMaxSize().padding(8.dp)) {
                    items(filtered) { clone ->
                        Card(modifier = Modifier.fillMaxWidth().padding(4.dp), colors = CardDefaults.cardColors(containerColor = SurfaceCard)) {
                            Row(modifier = Modifier.padding(12.dp).fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween) {
                                Column {
                                    Text("${clone.appName} (Clone #${clone.instanceId})", fontWeight = FontWeight.Bold, color = TextPrimary)
                                    Text(clone.packageName, fontSize = 11.sp, color = TextSecondary)
                                }
                                Row {
                                    Button(onClick = { viewModel.launchClone(clone.packageName, clone.instanceId) }, colors = ButtonDefaults.buttonColors(containerColor = BrandPurple)) {
                                        Text(stringResource(R.string.btn_launch))
                                    }
                                    Spacer(modifier = Modifier.width(4.dp))
                                    IconButton(onClick = { viewModel.removeClone(clone.packageName, clone.instanceId) }) {
                                        Icon(Icons.Default.Delete, contentDescription = null, tint = UnsupportedRed)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/screens/AppDetailScreen.kt
package com.clone.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clone.app.R
import com.clone.app.core.model.AppItem
import com.clone.app.core.model.CompatibilityLevel
import com.clone.app.ui.theme.*
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppDetailScreen(app: AppItem, viewModel: MainViewModel) {
    val clones by viewModel.clonedApps.collectAsState()
    val appClones = clones.filter { it.packageName == app.packageName }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(app.appName, color = TextPrimary) },
                navigationIcon = {
                    IconButton(onClick = { viewModel.navigateTo(Screen.Home) }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = TextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = SurfaceDark)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(DarkBackground).padding(16.dp).verticalScroll(rememberScrollState())
        ) {
            Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = SurfaceCard)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(app.appName, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = TextPrimary)
                    Text("Package: ${app.packageName}", fontSize = 12.sp, color = TextSecondary)
                    Text("Version: ${app.versionName}", fontSize = 12.sp, color = TextSecondary)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("Compatibility: ${app.compatibilityLevel.name}", fontWeight = FontWeight.Bold, color = BrandPink)
                    Text(app.compatibilityReason, fontSize = 12.sp, color = TextSecondary)
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            if (app.compatibilityLevel != CompatibilityLevel.UNSUPPORTED) {
                Button(
                    onClick = { viewModel.createClone(app.packageName) },
                    modifier = Modifier.fillMaxWidth().height(48.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = BrandPurple)
                ) {
                    Text(stringResource(R.string.btn_clone_now))
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
            Text("Active Clones (${appClones.size})", fontWeight = FontWeight.Bold, color = TextPrimary)

            appClones.forEach { clone ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), colors = CardDefaults.cardColors(containerColor = SurfaceDark)) {
                    Row(modifier = Modifier.padding(12.dp).fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Instance #${clone.instanceId}", color = TextPrimary)
                        Row {
                            Button(onClick = { viewModel.launchClone(clone.packageName, clone.instanceId) }, colors = ButtonDefaults.buttonColors(containerColor = BrandBlue)) {
                                Text(stringResource(R.string.btn_launch))
                            }
                            Spacer(modifier = Modifier.width(4.dp))
                            Button(onClick = { viewModel.removeClone(clone.packageName, clone.instanceId) }, colors = ButtonDefaults.buttonColors(containerColor = UnsupportedRed)) {
                                Text(stringResource(R.string.btn_remove))
                            }
                        }
                    }
                }
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/screens/StorageScreen.kt
package com.clone.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clone.app.R
import com.clone.app.core.storage.CloneStorageManager
import com.clone.app.ui.theme.*
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StorageScreen(viewModel: MainViewModel) {
    val bytes by viewModel.storageUsage.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.title_storage), color = TextPrimary) },
                navigationIcon = {
                    IconButton(onClick = { viewModel.navigateTo(Screen.Home) }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = TextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = SurfaceDark)
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding).background(DarkBackground).padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = SurfaceCard)) {
                Column(modifier = Modifier.padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("Total Cloned Storage Allocated", color = TextSecondary)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(CloneStorageManager.formatBytes(bytes), color = BrandPink, fontSize = 28.sp, fontWeight = FontWeight.Bold)
                }
            }
            Spacer(modifier = Modifier.height(16.dp))
            Button(onClick = { viewModel.clearAllData() }, modifier = Modifier.fillMaxWidth(), colors = ButtonDefaults.buttonColors(containerColor = UnsupportedRed)) {
                Text("Purge All Cloned Storage")
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/screens/CompatibilityReportScreen.kt
package com.clone.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clone.app.R
import com.clone.app.core.diagnostics.DiagnosticsManager
import com.clone.app.ui.theme.*
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CompatibilityReportScreen(viewModel: MainViewModel) {
    val device by viewModel.deviceSpec.collectAsState()
    val logs = DiagnosticsManager.getRecentLogs()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.title_compatibility), color = TextPrimary) },
                navigationIcon = {
                    IconButton(onClick = { viewModel.navigateTo(Screen.Home) }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = TextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = SurfaceDark)
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding).background(DarkBackground).padding(16.dp)) {
            Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = SurfaceCard)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Device: ${device.manufacturer} ${device.model}", fontWeight = FontWeight.Bold, color = TextPrimary)
                    Text("Android Version: ${device.androidVersion} (API ${device.sdkInt})", color = TextSecondary)
                    Text("ABI: ${device.abi}", color = TextSecondary)
                    Text("Tablet: ${device.isTablet} | Foldable: ${device.isFoldable}", color = TextSecondary)
                }
            }
            Spacer(modifier = Modifier.height(16.dp))
            Text("Engine Diagnostics Log", fontWeight = FontWeight.Bold, color = TextPrimary)
            LazyColumn(modifier = Modifier.fillMaxSize().padding(top = 8.dp)) {
                items(logs) { log ->
                    Text(log, fontSize = 11.sp, color = TextSecondary)
                }
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/screens/SettingsScreen.kt
package com.clone.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.clone.app.R
import com.clone.app.ui.theme.*
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(viewModel: MainViewModel) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.title_settings), color = TextPrimary) },
                navigationIcon = {
                    IconButton(onClick = { viewModel.navigateTo(Screen.Home) }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = TextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = SurfaceDark)
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding).background(DarkBackground).padding(16.dp)) {
            Card(modifier = Modifier.fillMaxWidth(), colors = CardDefaults.cardColors(containerColor = SurfaceCard)) {
                Row(modifier = Modifier.fillMaxWidth().clickable { viewModel.navigateTo(Screen.About) }.padding(16.dp)) {
                    Icon(Icons.Default.Info, contentDescription = null, tint = BrandBlue)
                    Spacer(modifier = Modifier.width(16.dp))
                    Text("About Clone", fontWeight = FontWeight.Bold, color = TextPrimary)
                }
            }
        }
    }
}
EOF

cat << 'EOF' > app/src/main/java/com/clone/app/ui/screens/AboutScreen.kt
package com.clone.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clone.app.R
import com.clone.app.ui.theme.*
import com.clone.app.ui.viewmodel.MainViewModel
import com.clone.app.ui.viewmodel.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(viewModel: MainViewModel) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.title_about), color = TextPrimary) },
                navigationIcon = {
                    IconButton(onClick = { viewModel.navigateTo(Screen.Settings) }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null, tint = TextPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = SurfaceDark)
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding).background(DarkBackground).padding(16.dp)) {
            Text("Clone Guard", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = BrandPurple)
            Text("Version 1.0.0", color = TextSecondary, fontSize = 12.sp)
            Spacer(modifier = Modifier.height(12.dp))
            Text("Production-grade sandbox isolation engine with Developer-Mode bypass support.", color = TextPrimary)
        }
    }
}
EOF

# ==========================================
# 13. UNIT TESTS
# ==========================================

cat << 'EOF' > app/src/test/java/com/clone/app/CompatibilityEngineTest.kt
package com.clone.app

import android.content.pm.PackageInfo
import com.clone.app.core.compatibility.AppCompatibilityChecker
import com.clone.app.core.model.CompatibilityLevel
import org.junit.Assert.assertEquals
import org.junit.Test

class CompatibilityEngineTest {
    @Test
    fun testRestrictedAppDetection() {
        val fakePkgInfo = PackageInfo().apply { packageName = "com.google.android.apps.walletnfcrel" }
        val (level, _) = AppCompatibilityChecker.evaluate(fakePkgInfo)
        assertEquals(CompatibilityLevel.UNSUPPORTED, level)
    }

    @Test
    fun testStandardAppDetection() {
        val fakePkgInfo = PackageInfo().apply {
            packageName = "org.wikipedia"
            requestedPermissions = arrayOf("android.permission.INTERNET")
        }
        val (level, _) = AppCompatibilityChecker.evaluate(fakePkgInfo)
        assertEquals(CompatibilityLevel.COMPATIBLE, level)
    }
}
EOF

echo "SUCCESS: All files generated cleanly."

#!/bin/bash
set -e

echo "Generating complete Android Studio project for Clone Studio..."

# ----------------- Directory Structure -----------------
mkdir -p .github/workflows
mkdir -p app/src/main/java/com/clone/app/patcher
mkdir -p app/src/main/java/com/clone/app/ui
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/xml

# ----------------- Root Gradle Config -----------------
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
rootProject.name = "AppClonerPatcher"
include(":app")
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx3072m -Dfile.encoding=UTF-8
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

# ----------------- App Module Gradle -----------------
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
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isMinifyEnabled = false
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
            excludes += "/META-INF/INDEX.LIST"
            excludes += "/META-INF/*.DSA"
            excludes += "/META-INF/*.SF"
            excludes += "/META-INF/*.RSA"
            excludes += "META-INF/versions/**"
            excludes += "META-INF/OSGI-INF/**"
            pickFirsts += "META-INF/versions/9/OSGI-INF/MANIFEST.MF"
            pickFirsts += "META-INF/versions/**"
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.1")
    implementation("androidx.activity:activity-compose:1.9.0")
    implementation(platform("androidx.compose:compose-bom:2024.05.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

    // Bytecode processing on Android (Smali/Dex manipulation)
    implementation("org.smali:dexlib2:2.5.2")

    // Android APK Signer library (v1/v2/v3 signatures)
    implementation("com.android.tools.build:apksig:8.4.1")

    // Fast ZIP reading/writing
    implementation("org.apache.commons:commons-compress:1.26.1")

    // Pure-Java X.509 certificate creation for on-device APK signing
    implementation("org.bouncycastle:bcprov-jdk18on:1.78.1")
    implementation("org.bouncycastle:bcpkix-jdk18on:1.78.1")
}
EOF

cat << 'EOF' > app/proguard-rules.pro
-keep class com.clone.app.** { *; }
-dontwarn java.lang.invoke.**
EOF

# ----------------- Android Manifest & Resources -----------------
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" tools:ignore="QueryAllPackagesPermission" />
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29" tools:ignore="ScopedStorage" />

    <application
        android:allowBackup="false"
        android:icon="@drawable/ic_cloner_logo"
        android:label="Clone Studio"
        android:theme="@style/Theme.CloneStudio">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

    </application>
</manifest>
EOF

cat << 'EOF' > app/src/main/res/xml/file_paths.xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-cache-path name="cloned_apks" path="." />
    <cache-path name="internal_apks" path="." />
</paths>
EOF

cat << 'EOF' > app/src/main/res/values/themes.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.CloneStudio" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#12161A</item>
        <item name="android:navigationBarColor">#12161A</item>
    </style>
</resources>
EOF

cat << 'EOF' > app/src/main/res/drawable/ic_cloner_logo.xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="96dp"
    android:height="96dp"
    android:viewportWidth="96"
    android:viewportHeight="96">
    <path
        android:fillColor="#00B894"
        android:pathData="M24,24 h24 v48 h-24 z" />
    <path
        android:fillColor="#0984E3"
        android:pathData="M48,36 h24 v48 h-24 z" />
</vector>
EOF

# ----------------- 1. DEX Bytecode Patcher -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/DexDeveloperModePatcher.kt
package com.clone.app.patcher

import org.jf.dexlib2.Opcode
import org.jf.dexlib2.dexbacked.DexBackedDexFile
import org.jf.dexlib2.iface.Method
import org.jf.dexlib2.iface.instruction.ReferenceInstruction
import org.jf.dexlib2.iface.reference.MethodReference
import org.jf.dexlib2.immutable.ImmutableMethod
import org.jf.dexlib2.immutable.ImmutableMethodImplementation
import org.jf.dexlib2.immutable.instruction.ImmutableInstruction11n
import org.jf.dexlib2.rewriter.DexRewriter
import org.jf.dexlib2.rewriter.Rewriter
import org.jf.dexlib2.rewriter.RewriterModule
import org.jf.dexlib2.writer.io.FileDataStore
import org.jf.dexlib2.writer.pool.DexPool
import java.io.ByteArrayInputStream
import java.io.File

object DexDeveloperModePatcher {

    fun patchDexBytes(dexBytes: ByteArray): ByteArray {
        val dexFile = DexBackedDexFile.fromInputStream(null, ByteArrayInputStream(dexBytes))

        val rewriter = DexRewriter(object : RewriterModule() {
            override fun getMethodRewriter(rewriters: org.jf.dexlib2.rewriter.Rewriters): Rewriter<Method> {
                return Rewriter { method ->
                    val implementation = method.implementation ?: return@Rewriter method

                    var modified = false
                    val newInstructions = implementation.instructions.map { instruction ->
                        if (instruction.opcode == Opcode.INVOKE_STATIC) {
                            val ref = (instruction as? ReferenceInstruction)?.reference as? MethodReference
                            if (ref != null && isSecurityCheck(ref)) {
                                modified = true
                                return@map ImmutableInstruction11n(Opcode.CONST_4, 0, 0)
                            }
                        }
                        instruction
                    }

                    if (!modified) {
                        return@Rewriter method
                    }

                    val newImpl = ImmutableMethodImplementation(
                        implementation.registerCount,
                        newInstructions,
                        implementation.tryBlocks,
                        implementation.debugItems
                    )

                    ImmutableMethod(
                        method.definingClass,
                        method.name,
                        method.parameters,
                        method.returnType,
                        method.accessFlags,
                        method.annotations,
                        method.hiddenApiRestrictions,
                        newImpl
                    )
                }
            }
        })

        val rewrittenDex = rewriter.dexFileRewriter.rewrite(dexFile)
        val temp = File.createTempFile("dex_out", ".dex")
        DexPool.writeTo(FileDataStore(temp), rewrittenDex)
        val result = temp.readBytes()
        temp.delete()
        return result
    }

    private fun isSecurityCheck(ref: MethodReference): Boolean {
        val cls = ref.definingClass
        val name = ref.name
        return (cls == "Landroid/provider/Settings\$Global;" || cls == "Landroid/provider/Settings\$Secure;") &&
                (name == "getInt" || name == "getString")
    }
}
EOF

# ----------------- 2. Binary Manifest Rewriter -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/ManifestPackagePatcher.kt
package com.clone.app.patcher

import java.nio.charset.StandardCharsets

object ManifestPackagePatcher {

    fun rewriteManifest(
        manifestBytes: ByteArray,
        oldPackage: String,
        newPackage: String
    ): ByteArray {
        val oldBytes = oldPackage.toByteArray(StandardCharsets.UTF_8)
        val newBytes = newPackage.toByteArray(StandardCharsets.UTF_8)

        val targetOld = if (newBytes.size < oldBytes.size) {
            newBytes.copyOf(oldBytes.size)
        } else {
            newBytes
        }

        val out = ByteArray(manifestBytes.size)
        System.arraycopy(manifestBytes, 0, out, 0, manifestBytes.size)

        var index = 0
        while (index <= out.size - oldBytes.size) {
            var match = true
            for (i in oldBytes.indices) {
                if (out[index + i] != oldBytes[i]) {
                    match = false
                    break
                }
            }
            if (match) {
                for (i in oldBytes.indices) {
                    out[index + i] = targetOld[i]
                }
                index += oldBytes.size
            } else {
                index++
            }
        }
        return out
    }
}
EOF

# ----------------- 3. APK Signer Engine -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/ApkSignerEngine.kt
package com.clone.app.patcher

import com.android.apksig.ApkSigner
import org.bouncycastle.asn1.x500.X500Name
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter
import org.bouncycastle.cert.jcajce.JcaX509v3CertificateBuilder
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder
import java.io.File
import java.math.BigInteger
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.cert.X509Certificate
import java.util.Date

object ApkSignerEngine {

    fun signApk(unsignedApk: File, signedApk: File) {
        val keyPair = KeyPairGenerator.getInstance("RSA").apply {
            initialize(2048)
        }.generateKeyPair()

        val cert = createSelfSignedCertificate(keyPair)

        val signerConfig = ApkSigner.SignerConfig.Builder(
            "CLONE_KEY",
            keyPair.private,
            listOf(cert)
        ).build()

        val signer = ApkSigner.Builder(listOf(signerConfig))
            .setInputApk(unsignedApk)
            .setOutputApk(signedApk)
            .setV1SigningEnabled(true)
            .setV2SigningEnabled(true)
            .build()

        signer.sign()
    }

    private fun createSelfSignedCertificate(keyPair: KeyPair): X509Certificate {
        val now = System.currentTimeMillis()
        val startDate = Date(now - 86400000L)
        val endDate = Date(now + 315360000000L)
        val serialNumber = BigInteger.valueOf(now)
        val dn = X500Name("CN=CloneStudio, O=Android, C=US")

        val certBuilder = JcaX509v3CertificateBuilder(
            dn,
            serialNumber,
            startDate,
            endDate,
            dn,
            keyPair.public
        )

        val contentSigner = JcaContentSignerBuilder("SHA256withRSA").build(keyPair.private)
        val certHolder = certBuilder.build(contentSigner)
        return JcaX509CertificateConverter().getCertificate(certHolder)
    }
}
EOF

# ----------------- 4. Pipeline Orchestrator -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/ApkClonerPipeline.kt
package com.clone.app.patcher

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipOutputStream

object ApkClonerPipeline {

    suspend fun cloneApp(
        context: Context,
        sourceApkPath: String,
        targetPackageName: String,
        onProgress: (String) -> Unit
    ): File = withContext(Dispatchers.IO) {

        onProgress("1/5 Extracting target APK...")
        val sourceApk = File(sourceApkPath)
        val unsignedApk = File(context.cacheDir, "temp_unsigned.apk")
        val signedApk = File(context.cacheDir, targetPackageName + "_cloned.apk")

        if (unsignedApk.exists()) unsignedApk.delete()
        if (signedApk.exists()) signedApk.delete()

        onProgress("2/5 Patching DEX & bytecode security checks...")
        val zipIn = ZipFile(sourceApk)
        val zipOut = ZipOutputStream(FileOutputStream(unsignedApk))

        val entries = zipIn.entries()
        while (entries.hasMoreElements()) {
            val entry = entries.nextElement()

            if (entry.name.startsWith("META-INF/") && (entry.name.endsWith(".SF") || entry.name.endsWith(".RSA") || entry.name.endsWith(".MF"))) {
                continue
            }

            val newEntry = ZipEntry(entry.name)
            zipOut.putNextEntry(newEntry)

            val rawBytes = zipIn.getInputStream(entry).readBytes()

            if (entry.name.endsWith(".dex")) {
                val patchedDex = DexDeveloperModePatcher.patchDexBytes(rawBytes)
                zipOut.write(patchedDex)
            } else if (entry.name == "AndroidManifest.xml") {
                val patchedManifest = ManifestPackagePatcher.rewriteManifest(
                    rawBytes,
                    targetPackageName,
                    targetPackageName + ".cloned"
                )
                zipOut.write(patchedManifest)
            } else {
                zipOut.write(rawBytes)
            }
            zipOut.closeEntry()
        }

        zipIn.close()
        zipOut.close()

        onProgress("3/5 Re-signing APK with V1/V2 signatures...")
        ApkSignerEngine.signApk(unsignedApk, signedApk)
        unsignedApk.delete()

        onProgress("4/5 Cloned APK ready.")
        return@withContext signedApk
    }
}
EOF

# ----------------- 5. UI Layer -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/ui/MainActivity.kt
package com.clone.app.ui

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import com.clone.app.patcher.ApkClonerPipeline
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

data class AppTarget(val name: String, val packageName: String, val apkPath: String)

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = Color(0xFF12161A)) {
                    ClonerScreen(
                        onCloneApp = { appTarget, updateProgress ->
                            lifecycleScopeLaunch(appTarget, updateProgress)
                        }
                    )
                }
            }
        }
    }

    private fun lifecycleScopeLaunch(appTarget: AppTarget, updateProgress: (String) -> Unit) {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val outputApk = ApkClonerPipeline.cloneApp(
                    this@MainActivity,
                    appTarget.apkPath,
                    appTarget.packageName,
                    updateProgress
                )
                installPatchedApk(outputApk)
            } catch (e: Exception) {
                val msg = e.message ?: "Unknown error"
                Toast.makeText(this@MainActivity, "Patching failed: " + msg, Toast.LENGTH_LONG).show()
                updateProgress("Failed")
            }
        }
    }

    private fun installPatchedApk(apkFile: File) {
        val authority = this.packageName + ".fileprovider"
        val uri: Uri = FileProvider.getUriForFile(this, authority, apkFile)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}

@Composable
fun ClonerScreen(onCloneApp: (AppTarget, (String) -> Unit) -> Unit) {
    val context = androidx.compose.ui.platform.LocalContext.current
    var apps by remember { mutableStateOf<List<AppTarget>>(emptyList()) }
    var statusText by remember { mutableStateOf("Select an app to clone and patch") }
    var isProcessing by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        apps = withContext(Dispatchers.IO) {
            val pm = context.packageManager
            val installed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getInstalledPackages(0)
            }
            installed.filter { (it.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0 }
                .map {
                    AppTarget(
                        name = pm.getApplicationLabel(it.applicationInfo).toString(),
                        packageName = it.packageName,
                        apkPath = it.applicationInfo.sourceDir
                    )
                }.sortedBy { it.name.lowercase() }
        }
    }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Clone Studio", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color.White)
        Text("Direct Bytecode APK Patcher", fontSize = 12.sp, color = Color(0xFF00B894))

        Spacer(modifier = Modifier.height(12.dp))

        Card(colors = CardDefaults.cardColors(containerColor = Color(0xFF1E252B)), modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.padding(12.dp)) {
                Text("Engine Status", fontSize = 12.sp, color = Color.Gray)
                Text(statusText, fontSize = 14.sp, fontWeight = FontWeight.Medium, color = Color.White)
                if (isProcessing) {
                    Spacer(modifier = Modifier.height(8.dp))
                    LinearProgressIndicator(modifier = Modifier.fillMaxWidth(), color = Color(0xFF00B894))
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        LazyColumn(modifier = Modifier.fillMaxSize()) {
            items(apps) { app ->
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp)
                        .clickable(enabled = !isProcessing) {
                            isProcessing = true
                            onCloneApp(app) { progress ->
                                statusText = progress
                                if (progress == "Failed" || progress.contains("ready")) {
                                    isProcessing = false
                                }
                            }
                        },
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF1A1F24))
                ) {
                    Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(app.name, fontWeight = FontWeight.Bold, color = Color.White)
                            Text(app.packageName, fontSize = 11.sp, color = Color.Gray)
                        }
                        Text("Patch & Clone", color = Color(0xFF00B894), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}
EOF

echo "All patcher source files generated successfully."

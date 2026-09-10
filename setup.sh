#!/bin/bash
set -e

echo "Generating complete Android Studio project for Clone Studio with AXML & Split Merger..."

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

    // Android APK Signer library (v1/v2 signatures)
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

# ----------------- 1. High-Speed DEX Patcher -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/FastDexPatcher.kt
package com.clone.app.patcher

import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.security.MessageDigest
import java.util.zip.Adler32

object FastDexPatcher {

    private val TARGET_KEYS = listOf(
        "development_settings_enabled",
        "adb_enabled"
    )

    fun patchDexBytes(dexBytes: ByteArray): ByteArray {
        if (dexBytes.size < 0x70) return dexBytes
        if (dexBytes[0] != 0x64.toByte() || dexBytes[1] != 0x65.toByte() || dexBytes[2] != 0x78.toByte()) {
            return dexBytes
        }

        var modified = false
        for (target in TARGET_KEYS) {
            val targetBytes = target.toByteArray(Charsets.UTF_8)
            val replacement = ("disabled_" + target.take(target.length - 9)).toByteArray(Charsets.UTF_8)

            var i = 0x70
            val limit = dexBytes.size - targetBytes.size
            while (i <= limit) {
                if (dexBytes[i] == targetBytes[0]) {
                    var match = true
                    for (j in 1 until targetBytes.size) {
                        if (dexBytes[i + j] != targetBytes[j]) {
                            match = false
                            break
                        }
                    }
                    if (match) {
                        System.arraycopy(replacement, 0, dexBytes, i, targetBytes.size)
                        modified = true
                        i += targetBytes.size
                        continue
                    }
                }
                i++
            }
        }

        if (modified) {
            recalculateChecksums(dexBytes)
        }
        return dexBytes
    }

    private fun recalculateChecksums(dex: ByteArray) {
        val md = MessageDigest.getInstance("SHA-1")
        md.update(dex, 32, dex.size - 32)
        val sha1 = md.digest()
        System.arraycopy(sha1, 0, dex, 12, 20)

        val adler = Adler32()
        adler.update(dex, 12, dex.size - 12)
        val checksum = adler.value.toInt()

        val buf = ByteBuffer.wrap(dex, 8, 4).order(ByteOrder.LITTLE_ENDIAN)
        buf.putInt(checksum)
    }
}
EOF

# ----------------- 2. Binary AXML String Pool & Component Patcher -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/ManifestPackagePatcher.kt
package com.clone.app.patcher

import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.StandardCharsets

object ManifestPackagePatcher {

    private const val CHUNK_STRING_POOL = 0x001C0001

    fun rewriteManifest(
        manifestBytes: ByteArray,
        oldPackage: String,
        newPackage: String,
        originalAppLabel: String
    ): ByteArray {
        val buf = ByteBuffer.wrap(manifestBytes).order(ByteOrder.LITTLE_ENDIAN)
        if (buf.remaining() < 8) return manifestBytes

        val magic = buf.short.toInt() and 0xFFFF
        val headerSize = buf.short.toInt() and 0xFFFF
        val totalSize = buf.int

        if (magic != 0x0003) {
            return manifestBytes
        }

        var offset = headerSize
        var stringPoolOffset = -1
        while (offset + 8 <= manifestBytes.size) {
            val chunkType = ByteBuffer.wrap(manifestBytes, offset, 4).order(ByteOrder.LITTLE_ENDIAN).int
            val chunkSize = ByteBuffer.wrap(manifestBytes, offset + 4, 4).order(ByteOrder.LITTLE_ENDIAN).int

            if (chunkType == CHUNK_STRING_POOL) {
                stringPoolOffset = offset
                break
            }
            if (chunkSize <= 0) break
            offset += chunkSize
        }

        if (stringPoolOffset == -1) {
            return manifestBytes
        }

        return rewriteStringPool(manifestBytes, stringPoolOffset, oldPackage, newPackage, originalAppLabel)
    }

    private fun rewriteStringPool(
        data: ByteArray,
        spOffset: Int,
        oldPackage: String,
        newPackage: String,
        originalAppLabel: String
    ): ByteArray {
        val buf = ByteBuffer.wrap(data, spOffset, data.size - spOffset).order(ByteOrder.LITTLE_ENDIAN)
        val chunkType = buf.int
        val chunkSize = buf.int
        val stringCount = buf.int
        val styleCount = buf.int
        val flags = buf.int
        val stringsStart = buf.int
        val stylesStart = buf.int

        val isUtf8 = (flags and (1 shl 8)) != 0

        val stringOffsets = IntArray(stringCount)
        for (i in 0 until stringCount) {
            stringOffsets[i] = buf.int
        }

        val stringsAbsStart = spOffset + stringsStart
        val originalStrings = mutableListOf<String>()

        for (i in 0 until stringCount) {
            val strOffset = stringsAbsStart + stringOffsets[i]
            val s = if (isUtf8) {
                readUtf8String(data, strOffset)
            } else {
                readUtf16String(data, strOffset)
            }
            originalStrings.add(s)
        }

        val modifiedStrings = originalStrings.map { str ->
            when {
                str == oldPackage -> newPackage
                str == originalAppLabel -> "$originalAppLabel Clone"
                str.startsWith("$oldPackage.") -> str.replace(oldPackage, newPackage)
                str.startsWith(".") -> "$oldPackage$str" // Qualify shorthand activities (.MainActivity -> oldPackage.MainActivity)
                else -> str
            }
        }

        val newStringData = ByteArrayOutputStream()
        val newOffsets = IntArray(stringCount)

        for (i in 0 until stringCount) {
            newOffsets[i] = newStringData.size()
            val s = modifiedStrings[i]
            if (isUtf8) {
                writeUtf8String(newStringData, s)
            } else {
                writeUtf16String(newStringData, s)
            }
        }

        while (newStringData.size() % 4 != 0) {
            newStringData.write(0)
        }

        val newStringsBytes = newStringData.toByteArray()
        val stylesSize = if (styleCount > 0 && stylesStart > 0) {
            chunkSize - stylesStart
        } else {
            0
        }

        val newHeaderSize = 28 + (stringCount * 4) + (styleCount * 4)
        val newStringsStart = newHeaderSize
        val newStylesStart = if (styleCount > 0) newStringsStart + newStringsBytes.size else 0
        val newChunkSize = newHeaderSize + newStringsBytes.size + stylesSize

        val newPoolHeader = ByteBuffer.allocate(newHeaderSize).order(ByteOrder.LITTLE_ENDIAN)
        newPoolHeader.putInt(chunkType)
        newPoolHeader.putInt(newChunkSize)
        newPoolHeader.putInt(stringCount)
        newPoolHeader.putInt(styleCount)
        newPoolHeader.putInt(flags)
        newPoolHeader.putInt(newStringsStart)
        newPoolHeader.putInt(newStylesStart)

        for (off in newOffsets) {
            newPoolHeader.putInt(off)
        }

        val beforePool = data.copyOfRange(0, spOffset)
        val stylesData = if (stylesSize > 0) {
            data.copyOfRange(spOffset + stylesStart, spOffset + stylesStart + stylesSize)
        } else {
            ByteArray(0)
        }
        val afterPool = data.copyOfRange(spOffset + chunkSize, data.size)

        val resultStream = ByteArrayOutputStream()
        resultStream.write(beforePool)
        resultStream.write(newPoolHeader.array())
        resultStream.write(newStringsBytes)
        if (stylesSize > 0) {
            resultStream.write(stylesData)
        }
        resultStream.write(afterPool)

        val finalBytes = resultStream.toByteArray()
        val finalBuf = ByteBuffer.wrap(finalBytes).order(ByteOrder.LITTLE_ENDIAN)
        finalBuf.putInt(4, finalBytes.size)

        return finalBytes
    }

    private fun readUtf8String(data: ByteArray, offset: Int): String {
        var pos = offset
        var charLen = data[pos++].toInt() and 0xFF
        if ((charLen and 0x80) != 0) {
            charLen = ((charLen and 0x7F) shl 8) or (data[pos++].toInt() and 0xFF)
        }

        var byteLen = data[pos++].toInt() and 0xFF
        if ((byteLen and 0x80) != 0) {
            byteLen = ((byteLen and 0x7F) shl 8) or (data[pos++].toInt() and 0xFF)
        }

        return String(data, pos, byteLen, StandardCharsets.UTF_8)
    }

    private fun readUtf16String(data: ByteArray, offset: Int): String {
        var pos = offset
        var len = (data[pos].toInt() and 0xFF) or ((data[pos + 1].toInt() and 0xFF) shl 8)
        pos += 2
        if ((len and 0x8000) != 0) {
            val high = len and 0x7FFF
            val low = (data[pos].toInt() and 0xFF) or ((data[pos + 1].toInt() and 0xFF) shl 8)
            len = (high shl 16) or low
            pos += 2
        }
        return String(data, pos, len * 2, StandardCharsets.UTF_16LE)
    }

    private fun writeUtf8String(out: ByteArrayOutputStream, str: String) {
        val bytes = str.toByteArray(StandardCharsets.UTF_8)
        val charLen = str.length
        val byteLen = bytes.size

        if (charLen > 127) {
            out.write((charLen shr 8) or 0x80)
            out.write(charLen and 0xFF)
        } else {
            out.write(charLen)
        }

        if (byteLen > 127) {
            out.write((byteLen shr 8) or 0x80)
            out.write(byteLen and 0xFF)
        } else {
            out.write(byteLen)
        }

        out.write(bytes)
        out.write(0)
    }

    private fun writeUtf16String(out: ByteArrayOutputStream, str: String) {
        val len = str.length
        if (len > 0x7FFF) {
            val high = (len shr 16) or 0x8000
            val low = len and 0xFFFF
            out.write(high and 0xFF)
            out.write((high shr 8) and 0xFF)
            out.write(low and 0xFF)
            out.write((low shr 8) and 0xFF)
        } else {
            out.write(len and 0xFF)
            out.write((len shr 8) and 0xFF)
        }
        val bytes = str.toByteArray(StandardCharsets.UTF_16LE)
        out.write(bytes)
        out.write(0)
        out.write(0)
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

# ----------------- 4. Pipeline Orchestrator with Split-APK Merging -----------------
cat << 'EOF' > app/src/main/java/com/clone/app/patcher/ApkClonerPipeline.kt
package com.clone.app.patcher

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.BufferedOutputStream
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
        appLabel: String,
        splitApkPaths: List<String>?,
        onProgress: (String) -> Unit
    ): File = withContext(Dispatchers.IO) {

        withContext(Dispatchers.Main) { onProgress("1/5 Inspecting APK package...") }
        val sourceApk = File(sourceApkPath)
        val unsignedApk = File(context.cacheDir, "temp_unsigned.apk")
        val signedApk = File(context.cacheDir, targetPackageName + "_cloned.apk")

        if (unsignedApk.exists()) unsignedApk.delete()
        if (signedApk.exists()) signedApk.delete()

        val zipIn = ZipFile(sourceApk)
        val zipOut = ZipOutputStream(BufferedOutputStream(FileOutputStream(unsignedApk), 65536))
        val buffer = ByteArray(65536)
        val writtenEntries = HashSet<String>()

        val entries = zipIn.entries()
        while (entries.hasMoreElements()) {
            val entry = entries.nextElement()

            if (entry.name.startsWith("META-INF/") && (entry.name.endsWith(".SF") || entry.name.endsWith(".RSA") || entry.name.endsWith(".MF") || entry.name.endsWith(".DSA"))) {
                continue
            }

            writtenEntries.add(entry.name)
            val newEntry = ZipEntry(entry.name)
            zipOut.putNextEntry(newEntry)

            if (entry.name.endsWith(".dex")) {
                withContext(Dispatchers.Main) { onProgress("2/5 Neutralizing Developer Mode checks in " + entry.name) }
                val rawBytes = zipIn.getInputStream(entry).use { it.readBytes() }
                val patchedDex = FastDexPatcher.patchDexBytes(rawBytes)
                zipOut.write(patchedDex)
            } else if (entry.name == "AndroidManifest.xml") {
                withContext(Dispatchers.Main) { onProgress("2/5 Normalizing package name & home screen icon...") }
                val rawBytes = zipIn.getInputStream(entry).use { it.readBytes() }
                val patchedManifest = ManifestPackagePatcher.rewriteManifest(
                    rawBytes,
                    targetPackageName,
                    targetPackageName + ".cloned",
                    appLabel
                )
                zipOut.write(patchedManifest)
            } else {
                zipIn.getInputStream(entry).use { streamIn ->
                    var read: Int
                    while (streamIn.read(buffer).also { read = it } != -1) {
                        zipOut.write(buffer, 0, read)
                    }
                }
            }
            zipOut.closeEntry()
        }
        zipIn.close()

        // Merge native shared libraries from Split APKs (split_config.arm64_v8a.apk)
        if (!splitApkPaths.isNullOrEmpty()) {
            withContext(Dispatchers.Main) { onProgress("2/5 Merging split native architecture libraries...") }
            for (splitPath in splitApkPaths) {
                val splitFile = File(splitPath)
                if (!splitFile.exists()) continue

                val splitZip = ZipFile(splitFile)
                val splitEntries = splitZip.entries()
                while (splitEntries.hasMoreElements()) {
                    val se = splitEntries.nextElement()
                    if (se.name.startsWith("lib/") && se.name.endsWith(".so") && !writtenEntries.contains(se.name)) {
                        writtenEntries.add(se.name)
                        zipOut.putNextEntry(ZipEntry(se.name))
                        splitZip.getInputStream(se).use { sIn ->
                            var read: Int
                            while (sIn.read(buffer).also { read = it } != -1) {
                                zipOut.write(buffer, 0, read)
                            }
                        }
                        zipOut.closeEntry()
                    }
                }
                splitZip.close()
            }
        }

        zipOut.flush()
        zipOut.close()

        withContext(Dispatchers.Main) { onProgress("3/5 Re-signing APK with V1/V2 signatures...") }
        ApkSignerEngine.signApk(unsignedApk, signedApk)
        unsignedApk.delete()

        withContext(Dispatchers.Main) { onProgress("4/5 Done. Launching Android installer...") }
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

data class AppTarget(
    val name: String,
    val packageName: String,
    val apkPath: String,
    val splitApkPaths: List<String>?
)

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
                    appTarget.name,
                    appTarget.splitApkPaths,
                    updateProgress
                )
                installPatchedApk(outputApk)
            } catch (e: Exception) {
                val msg = e.message ?: "Unknown error"
                Toast.makeText(this@MainActivity, "Patching failed: " + msg, Toast.LENGTH_LONG).show()
                updateProgress("Failed: " + msg)
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
                    val splits = it.applicationInfo.splitSourceDirs?.toList()
                    AppTarget(
                        name = pm.getApplicationLabel(it.applicationInfo).toString(),
                        packageName = it.packageName,
                        apkPath = it.applicationInfo.sourceDir,
                        splitApkPaths = splits
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
                                if (progress.startsWith("Failed") || progress.contains("Done")) {
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

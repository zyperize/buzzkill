package com.buzzkill

import android.content.ClipData
import android.content.ClipboardManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Bundle
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.buzzkill.accessibility.BuzzkillAccessibilityService
import com.buzzkill.core.GrayscaleController
import com.buzzkill.data.BuzzkillSettings
import com.buzzkill.data.InstalledAppInfo
import com.buzzkill.data.InstalledAppProvider
import com.buzzkill.data.SettingsRepository
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MaterialTheme {
                Surface(Modifier.fillMaxSize(), color = Color(0xFF0A0A0A)) { BuzzkillHome() }
            }
        }
    }
}

@Composable
private fun BuzzkillHome() {
    val context = LocalContext.current
    val repository = remember { SettingsRepository(context) }
    val controller = remember { GrayscaleController(context, repository) }
    val appProvider = remember { InstalledAppProvider(context) }
    val scope = rememberCoroutineScope()
    val settings by repository.settings.collectAsState(initial = BuzzkillSettings(false, emptySet(), null))
    var accessibilityEnabled by remember { mutableStateOf(false) }
    var installedApps by remember { mutableStateOf<List<InstalledAppInfo>>(emptyList()) }
    var pickerOpen by remember { mutableStateOf(false) }

    fun refresh() {
        accessibilityEnabled = isAccessibilityServiceEnabled(context)
        installedApps = appProvider.loadInstalledApps()
    }

    LaunchedEffect(Unit) { refresh() }

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Header()
        StatusCard(
            secureSettingsGranted = controller.hasSecureSettingsAccess(),
            accessibilityEnabled = accessibilityEnabled,
            enabled = settings.enabled,
            onRefresh = ::refresh,
        )
        SetupCard(
            secureSettingsGranted = controller.hasSecureSettingsAccess(),
            accessibilityEnabled = accessibilityEnabled,
            onOpenDeveloperOptions = { openDeveloperOptions(context) },
            onCopyAdbCommand = { copyAdbCommand(context) },
            onOpenAccessibility = { context.startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)) },
        )
        AppsCard(
            selectedCount = settings.selectedPackages.size,
            onChoose = { pickerOpen = true },
        )
        EnabledCard(
            enabled = settings.enabled,
            canEnable = controller.hasSecureSettingsAccess() && accessibilityEnabled && settings.selectedPackages.isNotEmpty(),
            onToggle = { scope.launch { repository.setEnabled(it) } },
        )
        PrivacyNote()
    }

    if (pickerOpen) {
        AppPicker(
            apps = installedApps,
            selected = settings.selectedPackages,
            onClose = { pickerOpen = false },
            onToggle = { packageName, selected ->
                val next = settings.selectedPackages.toMutableSet().apply {
                    if (selected) add(packageName) else remove(packageName)
                }
                scope.launch { repository.setSelectedPackages(next) }
            },
        )
    }
}

@Composable
private fun Header() {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(14.dp)) {
        Box(
            Modifier.size(54.dp).clip(RoundedCornerShape(18.dp)).background(Color.White),
            contentAlignment = Alignment.Center,
        ) { Text("B", color = Color.Black, fontWeight = FontWeight.Black, style = MaterialTheme.typography.headlineSmall) }
        Column {
            Text("Buzzkill", style = MaterialTheme.typography.headlineLarge, fontWeight = FontWeight.Black, color = Color.White)
            Text("Real grayscale for selected apps.", color = Color(0xFFB0B0B0))
        }
    }
}

@Composable
private fun StatusCard(
    secureSettingsGranted: Boolean,
    accessibilityEnabled: Boolean,
    enabled: Boolean,
    onRefresh: () -> Unit,
) = DarkCard {
    Text(if (enabled) "Buzzkill is on" else "Set up Buzzkill", color = Color.White, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleLarge)
    Spacer(Modifier.height(10.dp))
    StatusRow("Secure settings access", secureSettingsGranted)
    StatusRow("Foreground detection", accessibilityEnabled)
    Button(
        onClick = onRefresh,
        modifier = Modifier.padding(top = 8.dp),
        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2A2A2A), contentColor = Color.White),
    ) { Text("Refresh status") }
}

@Composable
private fun SetupCard(
    secureSettingsGranted: Boolean,
    accessibilityEnabled: Boolean,
    onOpenDeveloperOptions: () -> Unit,
    onCopyAdbCommand: () -> Unit,
    onOpenAccessibility: () -> Unit,
) = DarkCard {
    Text("One-time Android setup", color = Color.White, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleLarge)
    Text(
        "Android protects the real grayscale setting. Grant secure-settings access once, then let Buzzkill watch only which app is in front.",
        color = Color(0xFFB0B0B0),
        modifier = Modifier.padding(top = 6.dp),
    )
    Spacer(Modifier.height(12.dp))
    Text("1. Grant secure settings with ADB", color = Color.White, fontWeight = FontWeight.SemiBold)
    Text("Connect your phone, then run the copied command from your computer.", color = Color(0xFF9A9A9A), style = MaterialTheme.typography.bodySmall)
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.padding(top = 8.dp)) {
        Button(onClick = onCopyAdbCommand, colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black)) { Text("Copy ADB command") }
        Button(onClick = onOpenDeveloperOptions, colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2A2A2A), contentColor = Color.White)) { Text("Developer options") }
    }
    Text(if (secureSettingsGranted) "Secure settings access is ready." else "Buzzkill cannot turn on real grayscale until this is granted.", color = if (secureSettingsGranted) Color(0xFF8CD790) else Color(0xFFB0B0B0), modifier = Modifier.padding(top = 8.dp), style = MaterialTheme.typography.bodySmall)
    Spacer(Modifier.height(14.dp))
    Text("2. Enable foreground detection", color = Color.White, fontWeight = FontWeight.SemiBold)
    Text("Buzzkill only receives the foreground package name. It does not read screen content or touch another app.", color = Color(0xFF9A9A9A), style = MaterialTheme.typography.bodySmall)
    Button(onClick = onOpenAccessibility, modifier = Modifier.padding(top = 8.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black)) {
        Text(if (accessibilityEnabled) "Accessibility is enabled" else "Open Accessibility settings")
    }
}

@Composable
private fun AppsCard(selectedCount: Int, onChoose: () -> Unit) = DarkCard {
    Text("Apps to make grayscale", color = Color.White, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleLarge)
    Text(if (selectedCount == 0) "Choose apps that should trigger grayscale." else "$selectedCount apps selected.", color = Color(0xFFB0B0B0), modifier = Modifier.padding(top = 6.dp))
    Button(onClick = onChoose, modifier = Modifier.padding(top = 10.dp), colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black)) { Text("Choose apps") }
}

@Composable
private fun EnabledCard(enabled: Boolean, canEnable: Boolean, onToggle: (Boolean) -> Unit) = DarkCard {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f)) {
            Text("Automatic grayscale", color = Color.White, fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleLarge)
            Text(if (canEnable) "Turns grayscale on when a selected app opens and restores your previous display setting when it closes." else "Finish both setup steps and choose at least one app first.", color = Color(0xFFB0B0B0), modifier = Modifier.padding(top = 6.dp))
        }
        Switch(checked = enabled, enabled = canEnable || enabled, onCheckedChange = onToggle)
    }
}

@Composable
private fun AppPicker(
    apps: List<InstalledAppInfo>,
    selected: Set<String>,
    onClose: () -> Unit,
    onToggle: (String, Boolean) -> Unit,
) {
    Surface(Modifier.fillMaxSize(), color = Color(0xFF0A0A0A)) {
        Column(Modifier.fillMaxSize().padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text("Choose apps", color = Color.White, style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Black)
                    Text("They stay fully usable. Buzzkill changes only the display color.", color = Color(0xFFB0B0B0))
                }
                Button(onClick = onClose, colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black)) { Text("Done") }
            }
            Spacer(Modifier.height(16.dp))
            Column(Modifier.weight(1f).verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                apps.forEach { app ->
                    Row(
                        modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(16.dp)).background(Color(0xFF171717)).clickable { onToggle(app.packageName, app.packageName !in selected) }.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Checkbox(checked = app.packageName in selected, onCheckedChange = { onToggle(app.packageName, it) })
                        Spacer(Modifier.width(8.dp))
                        Column {
                            Text(app.label, color = Color.White, fontWeight = FontWeight.SemiBold, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Text(app.packageName, color = Color(0xFF9A9A9A), style = MaterialTheme.typography.bodySmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun DarkCard(content: @Composable () -> Unit) {
    Card(colors = CardDefaults.cardColors(containerColor = Color(0xFF141414)), shape = RoundedCornerShape(24.dp)) {
        Column(Modifier.fillMaxWidth().padding(20.dp)) { content() }
    }
}

@Composable
private fun StatusRow(label: String, complete: Boolean) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 3.dp)) {
        Box(Modifier.size(10.dp).clip(CircleShape).background(if (complete) Color(0xFF8CD790) else Color(0xFF777777)))
        Spacer(Modifier.width(8.dp))
        Text(label, color = Color.White)
    }
}

@Composable
private fun PrivacyNote() {
    Text("Buzzkill does not block apps, limit time, draw an overlay, read screen content, or send data anywhere. Turn off Automatic grayscale before revoking secure-settings access.", color = Color(0xFF9A9A9A), style = MaterialTheme.typography.bodySmall)
}

private fun isAccessibilityServiceEnabled(context: Context): Boolean {
    val manager = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
    val expected = ComponentName(context, BuzzkillAccessibilityService::class.java).flattenToString()
    return manager.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        .any { it.resolveInfo.serviceInfo.run { "$packageName/$name" } == expected }
}

private fun openDeveloperOptions(context: Context) {
    runCatching { context.startActivity(Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)) }
        .onFailure { context.startActivity(Intent(Settings.ACTION_SETTINGS)) }
}

private fun copyAdbCommand(context: Context) {
    val command = "adb shell pm grant ${context.packageName} android.permission.WRITE_SECURE_SETTINGS"
    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    clipboard.setPrimaryClip(ClipData.newPlainText("Buzzkill ADB command", command))
}

package com.buzzkill.accessibility

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import com.buzzkill.core.GrayscaleController
import com.buzzkill.data.BuzzkillSettings
import com.buzzkill.data.SettingsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class BuzzkillAccessibilityService : AccessibilityService() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private lateinit var repository: SettingsRepository
    private lateinit var controller: GrayscaleController
    @Volatile private var settings = BuzzkillSettings(false, emptySet(), null)

    override fun onServiceConnected() {
        super.onServiceConnected()
        repository = SettingsRepository(this)
        controller = GrayscaleController(this, repository)
        scope.launch {
            repository.settings.collectLatest { next ->
                settings = next
                if (!next.enabled || !controller.hasSecureSettingsAccess()) {
                    controller.restoreIfNeeded(next)
                }
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val packageName = event.packageName?.toString() ?: return
        if (!::controller.isInitialized) return
        scope.launch { controller.handleForeground(packageName, settings) }
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        if (::controller.isInitialized) {
            controller.restoreImmediately(settings)
        }
        scope.cancel()
        super.onDestroy()
    }
}

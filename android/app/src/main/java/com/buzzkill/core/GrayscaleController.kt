package com.buzzkill.core

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.provider.Settings
import com.buzzkill.data.BuzzkillSettings
import com.buzzkill.data.DisplayState
import com.buzzkill.data.SettingsRepository
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class GrayscaleController(
    private val context: Context,
    private val repository: SettingsRepository,
) {
    private val resolver = context.contentResolver
    private val mutex = Mutex()
    private var sessionDisplayState: DisplayState? = null

    fun hasSecureSettingsAccess(): Boolean =
        context.checkSelfPermission(Manifest.permission.WRITE_SECURE_SETTINGS) ==
            PackageManager.PERMISSION_GRANTED

    suspend fun handleForeground(packageName: String, settings: BuzzkillSettings) {
        mutex.withLock {
            val shouldBeGrayscale = settings.enabled &&
                hasSecureSettingsAccess() &&
                packageName in settings.selectedPackages

            if (shouldBeGrayscale) {
                enableGrayscale(settings)
            } else {
                restoreDisplay(settings)
            }
        }
    }

    suspend fun restoreIfNeeded(settings: BuzzkillSettings) {
        mutex.withLock { restoreDisplay(settings) }
    }

    /** Restores color during service teardown, before its coroutine scope is cancelled. */
    fun restoreImmediately(settings: BuzzkillSettings) {
        if (!hasSecureSettingsAccess()) return
        val previous = settings.savedDisplayState ?: sessionDisplayState ?: return
        Settings.Secure.putInt(resolver, DALTONIZER_MODE, previous.mode)
        Settings.Secure.putInt(resolver, DALTONIZER_ENABLED, previous.isEnabled)
        sessionDisplayState = null
    }

    private suspend fun enableGrayscale(settings: BuzzkillSettings) {
        if (sessionDisplayState == null) {
            sessionDisplayState = settings.savedDisplayState ?: readCurrentDisplayState()
        }
        if (settings.savedDisplayState == null) {
            repository.saveDisplayState(requireNotNull(sessionDisplayState))
        }
        Settings.Secure.putInt(resolver, DALTONIZER_MODE, MONOCHROMACY_MODE)
        Settings.Secure.putInt(resolver, DALTONIZER_ENABLED, 1)
    }

    private suspend fun restoreDisplay(settings: BuzzkillSettings) {
        if (!hasSecureSettingsAccess()) return
        val previous = settings.savedDisplayState ?: sessionDisplayState ?: return
        Settings.Secure.putInt(resolver, DALTONIZER_MODE, previous.mode)
        Settings.Secure.putInt(resolver, DALTONIZER_ENABLED, previous.isEnabled)
        sessionDisplayState = null
        repository.clearSavedDisplayState()
    }

    private fun readCurrentDisplayState(): DisplayState = DisplayState(
        isEnabled = Settings.Secure.getInt(resolver, DALTONIZER_ENABLED, 0),
        mode = Settings.Secure.getInt(resolver, DALTONIZER_MODE, MONOCHROMACY_MODE),
    )

    private companion object {
        const val DALTONIZER_ENABLED = "accessibility_display_daltonizer_enabled"
        const val DALTONIZER_MODE = "accessibility_display_daltonizer"
        const val MONOCHROMACY_MODE = 0
    }
}

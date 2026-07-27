package com.buzzkill.data

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.buzzkillDataStore by preferencesDataStore(name = "buzzkill_settings")

class SettingsRepository(context: Context) {
    private val dataStore = context.applicationContext.buzzkillDataStore

    val settings: Flow<BuzzkillSettings> = dataStore.data.map(::mapPreferences)

    suspend fun setEnabled(value: Boolean) {
        dataStore.edit { it[ENABLED] = value }
    }

    suspend fun setSelectedPackages(packages: Set<String>) {
        dataStore.edit { it[SELECTED_PACKAGES] = packages }
    }

    suspend fun saveDisplayState(state: DisplayState) {
        dataStore.edit {
            it[HAS_SAVED_DISPLAY_STATE] = true
            it[PREVIOUS_DALTONIZER_ENABLED] = state.isEnabled
            it[PREVIOUS_DALTONIZER_MODE] = state.mode
        }
    }

    suspend fun clearSavedDisplayState() {
        dataStore.edit {
            it.remove(HAS_SAVED_DISPLAY_STATE)
            it.remove(PREVIOUS_DALTONIZER_ENABLED)
            it.remove(PREVIOUS_DALTONIZER_MODE)
        }
    }

    private fun mapPreferences(prefs: Preferences): BuzzkillSettings = BuzzkillSettings(
        enabled = prefs[ENABLED] ?: false,
        selectedPackages = prefs[SELECTED_PACKAGES] ?: emptySet(),
        savedDisplayState = if (prefs[HAS_SAVED_DISPLAY_STATE] == true) {
            DisplayState(
                isEnabled = prefs[PREVIOUS_DALTONIZER_ENABLED] ?: 0,
                mode = prefs[PREVIOUS_DALTONIZER_MODE] ?: 0,
            )
        } else {
            null
        },
    )

    companion object {
        private val ENABLED = booleanPreferencesKey("enabled")
        private val SELECTED_PACKAGES = stringSetPreferencesKey("selected_packages")
        private val HAS_SAVED_DISPLAY_STATE = booleanPreferencesKey("has_saved_display_state")
        private val PREVIOUS_DALTONIZER_ENABLED = intPreferencesKey("previous_daltonizer_enabled")
        private val PREVIOUS_DALTONIZER_MODE = intPreferencesKey("previous_daltonizer_mode")
    }
}

data class BuzzkillSettings(
    val enabled: Boolean,
    val selectedPackages: Set<String>,
    val savedDisplayState: DisplayState?,
)

data class DisplayState(
    val isEnabled: Int,
    val mode: Int,
)

package com.buzzkill.data

import android.content.Context
import android.content.pm.ApplicationInfo

data class InstalledAppInfo(
    val packageName: String,
    val label: String,
)

class InstalledAppProvider(private val context: Context) {
    fun loadInstalledApps(): List<InstalledAppInfo> {
        val pm = context.packageManager
        return pm.getInstalledApplications(0)
            .asSequence()
            .filter { app ->
                pm.getLaunchIntentForPackage(app.packageName) != null &&
                    app.packageName != context.packageName &&
                    (app.flags and ApplicationInfo.FLAG_SYSTEM == 0 || app.packageName in preferredPackages)
            }
            .map { app ->
                InstalledAppInfo(
                    packageName = app.packageName,
                    label = pm.getApplicationLabel(app).toString()
                )
            }
            .sortedWith(compareBy<InstalledAppInfo> { rankFor(it.packageName) }.thenBy { it.label.lowercase() })
            .toList()
    }

    private fun rankFor(packageName: String): Int {
        val index = preferredPackages.indexOf(packageName)
        return if (index >= 0) index else Int.MAX_VALUE
    }

    companion object {
        private val preferredPackages = listOf(
            "com.instagram.android",
            "com.zhiliaoapp.musically",
            "com.twitter.android",
            "com.snapchat.android",
            "com.facebook.katana",
            "com.reddit.frontpage",
            "com.google.android.youtube"
        )
    }
}
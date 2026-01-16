package com.ccdevllc.veohoy

import android.os.Build
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            // Show status bar with white background
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                window.statusBarColor = android.graphics.Color.WHITE
                window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
            }

            // Hide navigation bar with immersive sticky
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.setDecorFitsSystemWindows(false)
                window.insetsController?.let {
                    it.hide(android.view.WindowInsets.Type.navigationBars())
                    it.systemBarsBehavior = 
                        android.view.WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                }
            } else {
                @Suppress("DEPRECATION")
                window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                        or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_STABLE)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Ensure status bar is white with dark icons
        window.statusBarColor = android.graphics.Color.WHITE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        }
    }
}
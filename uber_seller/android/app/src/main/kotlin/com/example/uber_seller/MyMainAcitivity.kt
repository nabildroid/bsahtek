package me.laknabil.uber_seller

import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

class MyMainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", "transparent")
        super.onCreate(savedInstanceState)
        val window = this.window

        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
    }
}
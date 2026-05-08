package trade.manic.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val EVENTS_CHANNEL = "trade.manic.app/events"
        private const val METHODS_CHANNEL = "trade.manic.app/methods"
    }

    private var initialLink: String? = null
    private var linksReceiver: BroadcastReceiver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // 在 super.onCreate 之前获取启动时的 Deep Link
        initialLink = intent?.data?.toString()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 设置 Event Channel 用于接收 Deep Link 事件
        EventChannel(messenger, EVENTS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    linksReceiver = createLinkReceiver(events)
                }

                override fun onCancel(arguments: Any?) {
                    linksReceiver = null
                }
            }
        )

        // 设置 Method Channel 用于获取初始链接
        MethodChannel(messenger, METHODS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialLink" -> {
                    result.success(initialLink)
                    // 清除初始链接，避免重复处理
                    initialLink = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // 处理应用已在前台时收到的 Deep Link
        if (intent.action == Intent.ACTION_VIEW) {
            linksReceiver?.onReceive(applicationContext, intent)
        }
    }

    private fun createLinkReceiver(events: EventChannel.EventSink): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val dataString = intent.dataString
                if (dataString != null) {
                    events.success(dataString)
                } else {
                    events.error("UNAVAILABLE", "Link unavailable", null)
                }
            }
        }
    }
}
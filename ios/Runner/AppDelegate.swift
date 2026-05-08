import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private static let EVENTS_CHANNEL = "trade.manic.app/events"
    private static let METHODS_CHANNEL = "trade.manic.app/methods"
    
    private var eventsChannel: FlutterEventChannel?
    private var methodsChannel: FlutterMethodChannel?
    private var initialLink: String?
    private let linkStreamHandler = LinkStreamHandler()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // 设置 Event Channel 和 Method Channel
        if let controller = window?.rootViewController as? FlutterViewController {
            eventsChannel = FlutterEventChannel(
                name: AppDelegate.EVENTS_CHANNEL,
                binaryMessenger: controller.binaryMessenger
            )
            eventsChannel?.setStreamHandler(linkStreamHandler)
            
            methodsChannel = FlutterMethodChannel(
                name: AppDelegate.METHODS_CHANNEL,
                binaryMessenger: controller.binaryMessenger
            )
            methodsChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) in
                if call.method == "initialLink" {
                    if let link = self?.initialLink {
                        let handled = self?.linkStreamHandler.handleLink(link)
                        if handled == true {
                            self?.initialLink = nil
                        }
                    }
                    result(self?.initialLink)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }
        
        // 检查是否通过 URL 启动
        if let url = launchOptions?[.url] as? URL {
            initialLink = url.absoluteString
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // 处理 URL Scheme
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = linkStreamHandler.handleLink(url.absoluteString)
        if !handled {
            initialLink = url.absoluteString
        }
        return handled || super.application(app, open: url, options: options)
    }
    
    // 处理 Universal Link
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let handled = linkStreamHandler.handleLink(url.absoluteString)
                if !handled {
                    initialLink = url.absoluteString
                }
                return true
            }
        }
        return false
    }
}

// MARK: - Link Stream Handler
class LinkStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    var queuedLinks = [String]()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        // 发送之前队列中的链接
        queuedLinks.forEach { events($0) }
        queuedLinks.removeAll()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func handleLink(_ link: String) -> Bool {
        guard let eventSink = eventSink else {
            // 如果还没有监听器，先缓存链接
            queuedLinks.append(link)
            return false
        }
        eventSink(link)
        return true
    }
}

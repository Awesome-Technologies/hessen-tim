//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Marco Festini on 02.09.20.
//  Copyright © 2020 Awesome Technologies Innovationslabor GmbH. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    let defaultTitle = "Neue Informationen verfügbar"

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = defaultTitle
            // Determine what kind of Push Notification was received
            if let aps = bestAttemptContent.userInfo["aps"] as? [String: AnyObject], let alert = aps["alert"] as? [AnyHashable: Any], let type = alert["loc-key"] as? String {
                switch type {
                case "CASE_CREATED", "CASE_UPDATED":
                    bestAttemptContent.title = "Falldaten aktualisiert"
                case "CALL_UPDATED":
                    bestAttemptContent.title = "Anruf aktualisiert"

                default:
                    bestAttemptContent.title = defaultTitle
                }
            }

            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.title = defaultTitle
            contentHandler(bestAttemptContent)
        }
    }

}

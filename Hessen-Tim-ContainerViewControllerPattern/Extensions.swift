//
//  Extensions.swift
//  Hessen-Tim-ContainerViewControllerPattern
//
//  Created by Michael Rojkov on 25.03.20.
//  Copyright © 2020 Michael Rojkov. All rights reserved.
//

import Foundation
import UIKit
import SMART

extension Media {
    var image: UIImage? {
        guard let imageData = content?.data?.value, let data = Data(base64Encoded: imageData), let decodedImage = UIImage(data: data) else {
            return nil
        }
        return decodedImage
    }
}

extension Media {
    public enum MediaFilter {
        case modality(String)
        case created(String, DateTime)
        case status(EventStatus)

        func key() -> String {
            switch self {
            case .modality(_):
                return "modality"
            case .created(_, _):
                return "created"
            case .status(_):
                return "status"
            }
        }
    }
}

extension Patient {
    public enum PatientFilter {
        case practitioner(String)

        func key() -> String {
            switch self {
            case .practitioner(_):
                return "general-practitioner"
            }
        }
    }
}

extension Organization {
    public enum OrganizationFilter {
        case type(String)

        func key() -> String {
            switch self {
            case .type(_):
                return "type"
            }
        }
    }
}

extension ServiceRequest {
    public enum ServiceRequestFilter {
        case requester(type: DomainResource.Type, id: String)
        case status(RequestStatus)

        func key() -> String {
            switch self {
            case .requester(_, _):
                return "requester"
            case .status(_):
                return "status"
            }
        }
    }
}

extension DomainResource {
    var isLocalEcho: Bool {
        return localEchoId != nil ? true : false
    }

    var localEchoUrl: String {
        "care.amp.institute.local-echo-id"
    }

    var localEchoId: String? {
        return extensions(forURI: localEchoUrl)?.first?.valueString?.string
    }

    func makeLocalEcho() {
        guard localEchoId == nil else {
            return
        }
        let ext = Extension()
        ext.url = localEchoUrl.fhir_string
        ext.valueString = FHIRString(ProcessInfo.processInfo.globallyUniqueString)

        var extensions: [Extension] = extension_fhir ?? []
        extensions.append(ext)
        extension_fhir = extensions
    }

    public enum SearchFilter {
        case id(String)
        case subject(type: DomainResource.Type, id: String)
        case basedOn([String: Any]? = nil)
        case summary(FHIRRequestParameterField.Summary)
        case sort(String)
        case has([String], String)

        func sortString() -> String? {
            switch self {
            case .sort(let value):
                return value
            default:
                return nil
            }
        }

        func key() -> String {
            switch self {
            case .id(_):
                return "_id"
            case .subject(_, _):
                return "subject"
            case .basedOn(_):
                return "based-on"
            case .summary(_):
                return FHIRRequestParameterField.summary.rawValue
            case .sort(_):
                return "_sort"
            case .has(_, _):
                return "$has"
            }
        }
    }
}

extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

extension String
{
    var digitString: String { filter { ("0"..."9").contains($0) } }
}

//
//  NSError+Mapers.swift
//  AlfrescoActiviti
//
//  Created by Florin Baincescu on 20/01/2020.
//  Copyright © 2020 Emanuel Lupu-Marinei. All rights reserved.
//

import Foundation
import AlfrescoCore
import AlfrescoAuth

extension NSError {
    
    func mapToMessage() -> String {

        if self.domain == AFURLResponseSerializationErrorDomain {
            return NSLocalizedString(kLocalizationErrorCredentialProvided, comment: "Error")
        }
        
        let genericError = String(format: NSLocalizedString(kLocalizationGenericErrorText, comment: "Generic Error"), self.code)
        
        switch self.code {
        case 1000..<1999: //AlfrescoCore
           return genericError
        case ModuleErrorType.errorIssuerNil.code: 
            return NSLocalizedString(kLocalizationErrorCheckConnectURL, comment: "Error")
        case ModuleErrorType.errorAuthenticationServiceNotFound.code:
            return NSLocalizedString(kLocalizationErrorNoAuthAlfrescoURL, comment: "Error")
        case ModuleErrorType.errorUsernameNotEmpty.code, ModuleErrorType.errorPasswordNotEmpty.code:
            return self.localizedDescription
        default:
            return genericError
        }
    }
}

extension APIError {
    
    func mapToMessage() -> String {
        
        let genericError = String(format: NSLocalizedString(kLocalizationGenericErrorText, comment: "Generic Error"), self.responseCode)
        switch self.responseCode {
        case 1000..<1999: //AlfrescoCore
           return genericError
        case ModuleErrorType.errorIssuerNil.code:
            return NSLocalizedString(kLocalizationErrorCheckConnectURL, comment: "Error")
        case ModuleErrorType.errorAuthenticationServiceNotFound.code:
            return NSLocalizedString(kLocalizationErrorNoAuthAlfrescoURL, comment: "Error")
        case ModuleErrorType.errorUsernameNotEmpty.code, ModuleErrorType.errorPasswordNotEmpty.code:
            return self.localizedDescription
        default:
            return genericError
        }
    }
}

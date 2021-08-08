//
//  NetworkResponseDataModel.swift
//  SMoreTest
//
//  Created by Onseen on 8/6/21.
//

import UIKit
import Alamofire

class NetworkResponseDataModel<T>: NSObject {
    var payload: [String: Any] = [:]
    var parsedObject: T? = nil
    
    var code: EnumNetworkResponseCode! = .CODE_200_OK
    var errorMessage: String = ""
    var errorCode: EnumNetworkErrorCode = .USER_INVALID_CREDENTIALS
    
    func initialize() {
        self.payload = [:]
        self.parsedObject = nil
        self.code = .CODE_200_OK
        
        self.errorMessage = ""
        self.errorCode = .USER_INVALID_CREDENTIALS
    }
    
    func isSuccess() -> Bool {
        return (
            self.code == .CODE_200_OK ||
            self.code == .CODE_201_CREATED ||
            self.code == .CODE_204_NO_CONTENT
        )
    }
    
    func isTokenExpired() -> Bool {
        return (self.code == .CODE_403_FORBIDDEN) && (self.errorCode == .TOKEN_EXPIRED)
    }
    
    func isServiceUnreachable() -> Bool {
        return (
            self.code == .CODE_408_TIMEOUT ||
//            self.code == .CODE_500_INTERNAL_SERVER_ERROR ||
            self.code == .CODE_502_BAD_GATEWAY ||
            self.code == .CODE_503_SERVICE_UNAVAILABLE ||
            self.code == .CODE_504_GATEWAY_TIMEOUT ||
            self.code == .CODE_0_UNREACHABLE
        )
    }
    
    func isAuthFailed() -> Bool {
        return (
            self.code == .CODE_401_UNAUTHORIZED ||
            self.code == .CODE_403_FORBIDDEN
        )
    }
    
    func getBeautifiedErrorMessage() -> String {
        if self.isSuccess() {
            return ""
        }
        if self.errorMessage != "" {
            return self.errorMessage
        }
        return "Sorry, we've encountered an error."
    }
    
    static func instanceFromDataResponse(_ response: DataResponse<Any>) -> NetworkResponseDataModel<Any> {
        let modelResponse = NetworkResponseDataModel<Any>()
        if let JSON = response.result.value as? [String: Any] {
            modelResponse.payload = JSON
            
            if let error = UtilsString.toString(JSON["error"]) {
                modelResponse.errorMessage = error
            }
            if let message = UtilsString.toString(JSON["message"]) {
                modelResponse.errorMessage = message
            }
            if let code = UtilsString.toString(JSON["name"]) {
                modelResponse.errorCode = EnumNetworkErrorCode.fromString(code)
            }
        }
        
        modelResponse.code = EnumNetworkResponseCode.fromInt(response.response?.statusCode)
        return modelResponse
    }
    
    static func instanceForFailure() -> NetworkResponseDataModel<T> {
        let instance = NetworkResponseDataModel<T>()
        instance.code = .CODE_400_BAD_REQUEST
        return instance
    }
    
    static func instanceForFailure(failureCode: EnumNetworkResponseCode) -> NetworkResponseDataModel<T> {
        let instance = NetworkResponseDataModel<T>()
        instance.code = failureCode
        return instance
    }
    
    static func instanceForSuccess() -> NetworkResponseDataModel<T> {
        let instance = NetworkResponseDataModel<T>()
        return instance
    }
}

enum EnumNetworkResponseCode: Int, CaseIterable {
    case CODE_200_OK = 200
    case CODE_201_CREATED = 201
    case CODE_204_NO_CONTENT = 204
    case CODE_400_BAD_REQUEST = 400
    case CODE_401_UNAUTHORIZED = 401
    case CODE_403_FORBIDDEN = 403
    case CODE_404_NOT_FOUND = 404
    case CODE_408_TIMEOUT = 408
    case CODE_500_INTERNAL_SERVER_ERROR = 500
    case CODE_502_BAD_GATEWAY = 502
    case CODE_503_SERVICE_UNAVAILABLE = 503
    case CODE_504_GATEWAY_TIMEOUT = 504
    case CODE_0_UNREACHABLE = 0
    
    static func fromInt(_ value: Int?) -> EnumNetworkResponseCode {
        guard let value = value else {
            return .CODE_200_OK
        }
        
        for code in EnumNetworkResponseCode.allCases {
            if code.rawValue == value {
                return code
            }
        }
        
        // check if other success code (2xx)
        if value >= 200 && value <= 299 {
            return .CODE_200_OK
        }
        
        // check if other server error (5xx)
        if value >= 500 && value <= 599 {
            return .CODE_500_INTERNAL_SERVER_ERROR
        }
        
        return .CODE_400_BAD_REQUEST
    }
}

enum EnumNetworkErrorCode: String, CaseIterable {
    case NONE = ""
    case UNKNOWN = "UnkwownError"
    case USER_INVALID_CREDENTIALS = "InvalidCredentialError"
    case TOKEN_EXPIRED = "ExpiredTokenError"
    
    static func fromString(_ string: String?) -> EnumNetworkErrorCode {
        guard let string = string else {
            return .NONE
        }
        for c in EnumNetworkErrorCode.allCases {
            if c.rawValue.caseInsensitiveCompare(string) == .orderedSame {
                return c
            }
        }
        return .UNKNOWN
    }
    
}

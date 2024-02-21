//
//  WWSimpleChatGPT.swift
//  WWSimpleChatGPT
//
//  Created by William.Weng on 2024/2/21.
//

import UIKit
import WWNetworking

// MARK: - WWSimpleChatGPT
open class WWSimpleChatGPT {
    
    public static let shared = WWSimpleChatGPT()
    
    static let baseURL = "https://api.openai.com"
    
    static var version = "v1"
    static var bearerToken = "<BearerToken>"
    
    public struct Model {}
    
    private init() {}
}

// MARK: - 初始值設定 (static function)
public extension WWSimpleChatGPT {
    
    /// [參數設定](https://platform.openai.com/docs/api-reference/making-requests)
    /// - Parameters:
    ///   - bearerToken: [String](https://platform.openai.com/account/api-keys)
    ///   - version: String
    static func configure(bearerToken: String, version: String = "v1") {
        self.bearerToken = bearerToken
        self.version = version
    }
}

// MARK: - 開放工具
public extension WWSimpleChatGPT {
    
    /// 執行API功能
    /// - Parameters:
    ///   - method: WWNetworking.Constant.HttpMethod
    ///   - apiURL: String
    ///   - httpBody: String
    /// - Returns: Result<WWNetworking.ResponseInformation, Error>
    func execute(method: WWNetworking.Constant.HttpMethod = .POST, apiURL: String, httpBody: String?) async -> Result<WWNetworking.ResponseInformation, Error> {
        
        let headers = authorizationHeaders()
        let result = await WWNetworking.shared.request(with: method, urlString: apiURL, contentType: .json, paramaters: nil, headers: headers, httpBody: httpBody?._data())
        
        return result
    }
    
    /// 模型列表
    /// - Returns: Result<WWNetworking.ResponseInformation, Error>
    func models() async -> Result<Any?, Error> {
        
        let apiURL: WWSimpleChatGPT.API = .models
        let result = await execute(method: .GET, apiURL: apiURL.value(), httpBody: nil)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let data = info.data,
                  let jsonObject = data._jsonObject()
            else {
                return .success(nil)
            }
            
            return .success(jsonObject)
        }
    }
    
    /// 執行聊天功能
    /// - Parameters:
    ///   - model: WWSimpleChatGPT.Model.Chat
    ///   - role: String
    ///   - temperature: Double
    ///   - content: String
    /// - Returns: Result<String?, Error>
    func chat(model: WWSimpleChatGPT.Model.Chat = .v3_5, role: String = "user", temperature: Double = 0.7, content: String) async -> Result<String?, Error> {
        let apiURL: WWSimpleChatGPT.API = .chat
        return await chat(apiURL: apiURL.value(), model: model.value(), role: role, temperature: temperature, content: content)
    }
    
    /// 文字轉語音
    /// - Parameters:
    ///   - model: WWSimpleChatGPT.Model.TTS
    ///   - voice: WWSimpleChatGPT.Model.Voice
    ///   - speed: Double
    ///   - input: Double
    /// - Returns: Result<Data?, Error>
    func speech(model: WWSimpleChatGPT.Model.TTS = .tts, voice: WWSimpleChatGPT.Model.Voice = .alloy, speed: Double = 1.0, input: String) async -> Result<Data?, Error> {
        let apiURL: WWSimpleChatGPT.API = .speech
        return await speech(apiURL: apiURL.value(), model: model.value(), voice: voice.value(), speed: speed, input: input)
    }
    
    /// 語音轉文字
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 語音模組
    ///   - contentType: 語音資料類型
    ///   - data: 語音資料
    /// - Returns: Result<String?, Error>
    func whisper(model: WWSimpleChatGPT.Model.Whisper = .v1, contentType: WWNetworking.Constant.ContentType, data: Data) async -> Result<String?, Error> {
        let apiURL: WWSimpleChatGPT.API = .whisper
        return await whisper(apiURL: apiURL.value(), model: model.value(), contentType: contentType, data: data)
    }
    
    /// 文字生成圖片
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 圖片模型
    ///   - prompt: 圖片述敘文字
    ///   - n: 生成張數 (1-10)
    ///   - size: 圖片大小
    /// - Returns: Result<[Any]?, Error>
    func image(model: WWSimpleChatGPT.Model.ImageModel = .v2, prompt: String, n: Int = 1, size: WWSimpleChatGPT.Model.ImageSize = ._256x256) async -> Result<[Any]?, Error> {
        let apiURL: WWSimpleChatGPT.API = .images
        return await image(apiURL: apiURL.value(), model: model.value(), prompt: prompt, n: n, size: size.value())
    }
}

// MARK: 小工具
private extension WWSimpleChatGPT {
    
    /// 安全認證Header
    /// - Returns: [String: String?]
    func authorizationHeaders() -> [String: String?] {
        let headers: [String: String?] = ["Authorization": "Bearer \(WWSimpleChatGPT.bearerToken)"]
        return headers
    }
    
    /// [聊天功能](https://platform.openai.com/docs/api-reference/chat/create)
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: [GPT模型](https://platform.openai.com/docs/models/gpt-3-5-turbo)
    ///   - content: 提問文字
    ///   - role: 角色名稱
    ///   - temperature: 準確性 / 機率分佈
    /// - Returns: Result<String?, Error>
    func chat(apiURL: String, model: String, role: String, temperature: Double, content: String) async -> Result<String?, Error> {
        
        let httpBody = """
        {
          "model": "\(model)",
          "messages": [{"role": "\(role)","content": "\(content)"}],
          "temperature": \(temperature)
        }
        """
        
        let result = await execute(apiURL: apiURL, httpBody: httpBody)
        var content: String?
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let dictionary = info.data?._jsonObject() as? [String: Any] else { return .success(content) }
            
            if let error = dictionary["error"] as? [String: Any] { return .failure(WWSimpleChatGPT.ChatGPTError.error(error)) }
            
            guard let _choices = dictionary["choices"] as? [Any],
                  let _choice = _choices.first as? [String: Any],
                  let _message = _choice["message"] as? [String: Any],
                  let _content = _message["content"] as? String
            else {
                return .success(content)
            }
            
            content = _content
        }
        
        return .success(content)
    }
    
    /// 文字轉語音
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 聲音模組
    ///   - voice: 說話語音
    ///   - speed: 聲音語速
    ///   - input: 轉換文字
    /// - Returns: Result<Data?, Error>
    func speech(apiURL: String, model: String, voice: String, speed: Double, input: String) async -> Result<Data?, Error> {
        
        let httpBody = """
        {
          "model": "\(model)",
          "input": "\(input)",
          "voice": "\(voice)",
          "speed": \(speed)
        }
        """
        
        let result = await execute(apiURL: apiURL, httpBody: httpBody)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info): return .success(info.data)
        }
    }
    
    /// 語音轉文字
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 語音模組
    ///   - contentType: 語音資料類型
    ///   - data: 語音資料
    /// - Returns: Result<String?, Error>
    func whisper(apiURL: String, model: String, contentType: WWNetworking.Constant.ContentType, data: Data) async -> Result<String?, Error>  {
        
        let headers = authorizationHeaders()
        let formData: WWNetworking.FormDataInformation = (name: "file", filename: "whisper.mp3", contentType: contentType, data: data)
        let parameters = ["model": model]
        let result = await WWNetworking.shared.upload(urlString: apiURL, formData: formData, parameters: parameters, headers: headers)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let dictionary = info.data?._jsonObject() as? [String: Any],
                  let text = dictionary["text"] as? String
            else {
                return .success(nil)
            }
            
            return .success(text)
        }
    }
    
    /// 文字生成圖片
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 圖片模型
    ///   - prompt: 圖片述敘文字
    ///   - n: 生成張數 (1-10)
    ///   - size: 圖片大小
    /// - Returns: Result<[Any]?, Error>
    func image(apiURL: String, model: String, prompt: String, n: Int, size: String) async -> Result<[Any]?, Error> {
        
        let httpBody = """
        {
            "model": "\(model)",
            "prompt": "\(prompt)",
            "n": \(n),
            "size": "\(size)"
        }
        """
        
        let result = await execute(apiURL: apiURL, httpBody: httpBody)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let dictionary = info.data?._jsonObject() as? [String: Any] else { return .success(nil) }
            
            if let error = dictionary["error"] as? [String: Any] { return .failure(WWSimpleChatGPT.ChatGPTError.error(error)) }
            if let datas = dictionary["data"] as? [Any] { return .success(datas) }
            
            return .success(nil)
        }
    }
}

//
//  Constant.swift
//  ChatGPTAPI
//
//  Created by William.Weng on 2024/2/21.
//

import UIKit
import WWNetworking

public extension WWSimpleChatGPT {
    
    typealias WhisperAudio = (type: WWSimpleChatGPT.Model.WhisperAudioType, data: Data)     // 語音轉文字 (WhisperAudioType, Data)
}

// MARK: - enum
public extension WWSimpleChatGPT {
    
    /// API功能
    enum API {
        
        case chat           // 聊天問答
        case speech         // 文字轉語音
        case whisper        // 語音轉文字
        case images         // 圖片生成
        case models         // 模型列表
        case embeddings     // 將文字轉為數字表示 (？)
        case fineTuning     // 訓練模型微調 (？)
        case files          // 檔案上傳 / 下載 (？)
        case moderations    // 文字是否違反OpenAI的內容政策進行分類 (？)
        case assistants     // 建立一個助手 (？)
        case threads        // 建立線程 (？)
        
        /// 取得url
        /// - Returns: String
        func value() -> String {
            
            let path: String
            
            switch self {
            case .chat: path = "chat/completions"
            case .speech: path = "audio/speech"
            case .whisper: path = "audio/transcriptions"
            case .images: path = "images/generations"
            case .embeddings: path = "embeddings"
            case .fineTuning: path = "fine_tuning/jobs"
            case .files: path = "files"
            case .models: path = "models"
            case .moderations: path = "moderations"
            case .assistants: path = "assistants"
            case .threads: path = "threads"
            }
            
            return "\(WWSimpleChatGPT.baseURL)/\(WWSimpleChatGPT.version)/\(path)"
        }
    }
    
    /// ChatGPT錯誤
    enum ChatGPTError: Error {
        case error(_ error: [String: Any])
    }
}

// MARK: - 模組
public extension WWSimpleChatGPT.Model {
    
    /// [聊天模組](https://platform.openai.com/docs/models)
    enum Chat {
        
        case v3_5
        case v4
        case v4o
        case v4o_mini
        case vo1
        case vo1_mini
        case custom(_ version: String)
        
        /// 取得GPT模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v3_5: return "gpt-3.5-turbo"
            case .v4: return "gpt-4-turbo"
            case .v4o: return "gpt-4o"
            case .v4o_mini: return "gpt-4o-mini"
            case .vo1: return "o1-preview"
            case .vo1_mini: return "o1-mini"
            case .custom(let version): return version
            }
        }
    }
    
    /// 語音模組
    enum TTS {
        
        case v1
        case v1_hd
        
        /// 取得語音模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v1: return "tts-1"
            case .v1_hd: return "tts-1-hd"
            }
        }
    }
    
    /// 聲音模組
    enum Voice {
        
        case alloy
        case echo
        case fable
        case onyx
        case nova
        case shimmer
        
        /// 取得聲音模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .alloy: return "alloy"
            case .echo: return "echo"
            case .fable: return "fable"
            case .onyx: return "onyx"
            case .nova: return "nova"
            case .shimmer: return "shimmer"
            }
        }
    }
    
    /// 耳語模組
    enum Whisper {
        
        case v1
        
        /// 取得語音轉文字模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v1: return "whisper-1"
            }
        }
    }
    
    /// 耳語模組能轉換的類型
    enum WhisperAudioType: String {
        
        case flac
        case mp3
        case mp4
        case mpeg
        case mpga
        case m4a
        case ogg
        case wav
        case webm
        
        /// [取得MIME類型文字](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
        /// - Returns: [String](https://www.iana.org/assignments/media-types/media-types.xhtml)
        func contentType() -> WWNetworking.Constant.ContentType {
            
            let mime: WWNetworking.Constant.ContentType
            
            switch self {
            case .mp3: mime = .mp3
            case .mpeg: mime = .mpeg
            case .mpga: mime = .mpga
            case .mp4: mime = .mp4
            case .ogg: mime = .ogg
            case .wav: mime = .wav
            case .webm: mime = .webm
            case .m4a: mime = .m4a
            case .flac: mime = .flac
            }
            
            return mime
        }
    }
    
    /// 圖片生成支援的尺寸
    enum ImageSize {
        
        case _256x256
        case _512x512
        case _1024x1024
        case _1024x1792
        case _1792x1024
        
        /// 尺寸文字
        /// - Returns: String
        func value() -> String {
            switch self {
            case ._256x256: return "256x256"
            case ._512x512: return "512x512"
            case ._1024x1024: return "1024x1024"
            case ._1024x1792: return "1024x1792"
            case ._1792x1024: return "1792x1024"
            }
        }
    }
    
    /// 圖片生成模型
    enum ImageModel {
        
        case v2
        case v3
        
        /// 模型名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v2: return "dall-e-2"
            case .v3: return "dall-e-3"
            }
        }
    }
}

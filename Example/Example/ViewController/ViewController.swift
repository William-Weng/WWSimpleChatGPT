//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/1/1.
//

import UIKit
import WWHUD
import WWSimpleChatGPT

// MARK: - ViewController
final class ViewController: UIViewController {
    
    private let apiKey = "<apiKey>"
    
    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
    }
    
    @IBAction func chat(_ sender: UIButton) { chatAction(content: myTextField.text) }
    @IBAction func images(_ sender: UIButton) { imagesAction(prompt: myTextField.text, count: 1) }
    @IBAction func speech(_ sender: UIButton) { speechAction(input: myTextField.text) }
    @IBAction func whisper(_ sender: UIButton) { whisperAction(filename: "speech.mp3") }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 設定Token
    func initSetting() {
        WWSimpleChatGPT.configure(apiKey: apiKey)
    }
    
    /// 顯示結果
    /// - Parameter result: Result<T?, Error>
    func displayResult<T>(result: Result<T?, Error>) {
        
        switch result {
        case .failure(let error): resultTextView.text = "\(error)"
        case .success(let value): resultTextView.text = "\(String(describing: value))"
        }
        
        WWHUD.shared.dismiss(completion: nil)
    }
    
    /// Loading動畫
    func loading() {
        guard let url = Bundle.main.url(forResource: "loading.gif", withExtension: nil) else { return }
        WWHUD.shared.display(effect: .gif(url: url), height: 256)
    }
}

// MARK: - 小工具
private extension ViewController {
        
    /// 聊天功能
    /// - Parameter content: 提出的問題文字
    func chatAction(content: String?) {
        
        guard let content = content else { return }
        
        loading()
        
        Task {
            let result = await WWSimpleChatGPT.shared.chat(model: .v4o, content: content)
            displayResult(result: result)
        }
    }
    
    /// 圖片生成
    /// - Parameters:
    ///   - prompt: 對想繪出的圖片述敘
    ///   - count: 生成的張數
    func imagesAction(prompt: String?, count: Int) {
     
        guard let prompt = prompt else { return }
        
        loading()
        
        Task {
            let result = await WWSimpleChatGPT.shared.image(model: .v3, prompt: prompt, n: count, size: ._1024x1024)
            displayResult(result: result)
        }
    }
    
    /// 文字轉語音
    /// - Parameter input: String?
    func speechAction(input: String?) {
        
        guard let input = input else { return }
        
        loading()
        
        Task {
            let result = await WWSimpleChatGPT.shared.speech(input: input)
            displayResult(result: result)
        }
    }
    
    /// 語音轉文字
    /// - Parameter audioData: Data?
    func whisperAction(filename: String) {
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let data = try? Data(contentsOf: url)
        else {
            return
        }

        loading()
        
        Task {
            let result = await WWSimpleChatGPT.shared.whisper(model: .v1, audio: (type: .mp3, data: data))
            displayResult(result: result)
        }
    }
}

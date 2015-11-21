//
//  ViewController.swift
//  Techtagram
//
//  Created by Takemi Watanuki on 2015/11/13.
//  Copyright © 2015年 Takemi Watanuki. All rights reserved.
//

import UIKit

//加工した写真を保存するためのフレームワーク
import AssetsLibrary

//写真をシェアするためのUIActivityを使用するために必要なフレームワーク
import Accounts

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var cameraImageView: UIImageView!
    
    //撮った写真の最初の状態を保持
    var originalImage : UIImage!
    
    //フィルター
    var filter : CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(){
        
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            //カメラを起動する
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            
            //カメラを自由な形に開きたいとき(今回は正方形)
            picker.allowsEditing = true
            
            presentViewController(picker, animated: true, completion: nil)
            
        }
        else{
            //カメラが利用出来ない時はerrorがコンソールに表示される
            print("error")
            
        }
        
    }
    
    @IBAction func savePhoto(){
        
        //保存する加工した画像を取得して保存
        let imageToSave = filter.outputImage!
        let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
        let cgimg = softwareContext.createCGImage(imageToSave, fromRect:imageToSave.extent)
        let library = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(cgimg,metadata:imageToSave.properties,completionBlock:nil)
        

    }
    @IBAction func colorFilter(){
        
        //加工したい画像を用意する
        let filterImage : CIImage = CIImage(image:originalImage)!
        
        //加工フィルターの準備を行うよ、今回は"色調節フィルター"
        filter = CIFilter(name: "CIColorControls")!
        filter.setValue(filterImage, forKey: kCIInputImageKey)
        filter.setValue(1.0, forKey: "inputSaturation")
        filter.setValue(0.5, forKey: "inputBrightness")
        filter.setValue(2.5, forKey: "inputContrast")
        
        //加工した画像を表示させよう
        let ctx = CIContext(options:nil)
        let cgImage = ctx.createCGImage(filter.outputImage!, fromRect:filter.outputImage!.extent)
        cameraImageView.image = UIImage(CGImage: cgImage)

    }
    
    @IBAction func openAlbum(){
        
        // カメラロールが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            //カメラを自由な形に開きたいとき(今回は正方形)
            picker.allowsEditing = true
            
            //アプリ画面へ戻る
            self.presentViewController(picker, animated: true, completion: nil)
        }

    }
    
    //カメラを起動して撮影が終わったときに呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        cameraImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        //撮った写真を最初の画像として記憶しておく
        originalImage = cameraImageView.image
        
        dismissViewControllerAnimated(true, completion: nil)  // アプリ画面へ 戻る
    }
    
    @IBAction func snsPost(){
        
        // 共有する項目
        let shareText = "写真を加工したよ！！"
        let shareImage = cameraImageView.image!
    
        let activityItems = [shareText, shareImage]
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePrint
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        // UIActivityViewControllerを表示
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
}


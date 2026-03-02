//
//  ExtensionChatController.swift
//  ChatApp
//
//  Created by Алеся Афанасенкова on 24.02.2026.
//

import UIKit
import SDWebImage
import ImageSlideshow
import SwiftAudioPlayer

extension ChatViewController {

    @objc func handleCamera() {
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
    
    @objc func handleGallery() {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true)
    }
}
//MARK: -UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) { [weak self] in
            guard let mediatype = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaType.rawValue)] as? String else { return }
             
            if mediatype == "public.image" {
                guard let image = info[.editedImage] as? UIImage else { return }
                self?.uploadImage(withImage: image)
            } else {
                guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
                self?.uploadVideo(withVideoURL: videoURL)
            }
        }
    }
}

extension ChatViewController {
    func uploadImage(withImage image: UIImage) {
        showLoader(true)
        FileUploader.uploadImage(image: image) { [unowned self] imageURL in
            MessageService.fetchSingleRecentMsg(otherUser: self.otherUser) { unReadMsgCount in
                MessageService.uploadMessage(imageURL: imageURL, currentUser: self.currentUser, unReadCount: unReadMsgCount + 1, otherUser: self.otherUser) { error in
                    self.showLoader(false)
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    func uploadVideo(withVideoURL videoURL: URL) {
        showLoader(true)
        FileUploader.uploadVideo(url: videoURL) { [unowned self] videoURL in
            MessageService.fetchSingleRecentMsg(otherUser: self.otherUser) { unReadMessageCount in
                MessageService.uploadMessage(videoURL: videoURL,currentUser: self.currentUser, unReadCount: unReadMessageCount + 1, otherUser: self.otherUser) { error in
                    self.showLoader(false)
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        } failure: { error in
            self.showLoader(false)
            print(error.localizedDescription)
        }

    }
}

extension ChatViewController: ChatCellDelegate {
    func cell(wantToShowImage cell: ChatCell, imageURL videoURL: URL?) {
        guard let videoURL = videoURL else { return }
        let controller = VideoPlayerVC(videoURL: videoURL)
        navigationController?.pushViewController(controller, animated: true)
    }
    func cell(wantToPlayVideo cell: ChatCell, videoURL imageURL: URL?) {
        let slideshow = ImageSlideshow()
        guard let imageURL = imageURL else { return }
        
        SDWebImageManager.shared.loadImage(with: imageURL, progress: nil) {image,_,_,_,_,_ in
            guard let image = image else { return }
            slideshow.setImageInputs([
                ImageSource(image: image)
            ])
            slideshow.delegate = self as? ImageSlideshowDelegate
            let controller = slideshow.presentFullScreenController(from: self)
            controller.slideshow.activityIndicator = DefaultActivityIndicator()
        }
    }
    func cell(wantToPlayAudio cell: ChatCell, audioURL: URL?, isPlay: Bool) {
        audioStatusSubscription = nil
        if isPlay {
            guard let audioURL = audioURL else { return }
            SAPlayer.shared.startRemoteAudio(withRemoteUrl: audioURL)
            SAPlayer.shared.play()
            
             audioStatusSubscription = SAPlayer.Updates.PlayingStatus.subscribe { [weak cell, weak self] playingStatus in
                if playingStatus == .ended {
                    cell?.resetAudioSettings()
                    self?.audioStatusSubscription = nil
                }
            }
        } else {
            SAPlayer.shared.stopStreamingRemoteAudio()
        }
    }
}

//
//  ViewController.swift
//  AsyncImageDownloader
//
//  Created by Imho Jang on 2023/03/04.
//

import UIKit

final class ViewController: UIViewController {
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    private lazy var downloadAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Download All", for: .normal)
        button.backgroundColor = .magenta
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 10
        
        let action = UIAction { [weak self] _ in
            self?.stack.arrangedSubviews.forEach {
                ($0 as? ImageButtonStack)?.downloadAndSetImage()
            }
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()
    
    private let urlStrings = [
        "https://www.cnet.com/a/img/resize/6b9a13a710d464d90c52123dd614d0d69395a559/hub/2019/06/04/88528943-c6c3-4fc5-854a-2b2ebbc0f59e/apple-wwdc-2019-ios-2760.jpg?auto=webp&fit=crop&height=675&width=1200",
        "https://cdn.vox-cdn.com/thumbor/Hg5NURRu56KJ45FCu4fbU-sflb4=/0x0:5436x3624/1400x1400/filters:focal(2718x1812:2719x1813)/cdn.vox-cdn.com/uploads/chorus_asset/file/24013850/iOS16hero.jpg",
        "https://imageio.forbes.com/specials-images/imageserve/5f8ab5c07bdfce7eac675e02/In-this-photo-illustration-a-screenshot-from-Apple-s-launch---/960x0.jpg?format=jpg&width=960",
        "https://yagomacademy.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb6ae0a9d-76eb-43b4-a2a8-e762fc9c9568%2FSymbol-300px-bg.png?table=block&id=3f670cc9-788f-4384-b000-bfe940447d59&spaceId=431128ec-0482-4966-b5f0-0bed1417e8c6&width=250&userId=&cache=v2",
        "https://cdn.osxdaily.com/wp-content/uploads/2023/01/ios-16-3.jpg",
        "https://economictimes.indiatimes.com/thumb/msid-94133286,width-1920,height-1080,resizemode-4,imgsize-17478/apple-iphone-ios-16-to-be-released-on-monday-check-out-features.jpg?from=mdr"
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        addImageButtonStacks()
    }
    
    private func layout() {
        view.addSubview(stack)
        view.addSubview(downloadAllButton)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            downloadAllButton.widthAnchor.constraint(equalToConstant: 200),
            downloadAllButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addImageButtonStacks() {
        urlStrings
            .map { createImageButtonStack(with: $0) }
            .forEach { stack.addArrangedSubview($0) }
    }
    
    private func createImageButtonStack(with urlString: String) -> ImageButtonStack {
        let stack = ImageButtonStack(urlString: urlString)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}

final class ImageButtonStack: UIView {
    private lazy var stackView = createStackView()
    private lazy var imageView = createImageView()
    private lazy var barView = createBarView()
    private lazy var button = createButton()
    
    private let imageURLString: String
    
    init(urlString: String) {
        imageURLString = urlString
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(barView)
        stackView.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            
            imageView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            barView.heightAnchor.constraint(equalToConstant: 4),
            barView.widthAnchor.constraint(equalToConstant: 100),
            button.widthAnchor.constraint(equalToConstant: 80),
            
            heightAnchor.constraint(equalToConstant: 110),
        ])
    }
    
    func downloadAndSetImage() {
        guard imageView.image == nil,
              let url = URL(string: imageURLString) else { return }
        
        getData(from: url) { data, urlResponse, error in
            guard
                let data = data,
                error == nil,
                let image = UIImage(data: data)
            else {
                return
                
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
                self?.button.isEnabled = false
            }
        }
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: completion)
        task.resume()
    }
    
    private func createStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 3
        view.alignment = .center
        return view
    }
    
    private func createImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }
    
    private func createBarView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }
    
    private func createButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Load", for: .normal)
        button.layer.cornerCurve = .continuous
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.backgroundColor = .systemBlue
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.downloadAndSetImage()
        }
        
        button.addAction(action, for: .touchUpInside)
        return button
    }
}

extension UIImageView {
    func setImage(image: UIImage) {
        self.image = image
    }
}

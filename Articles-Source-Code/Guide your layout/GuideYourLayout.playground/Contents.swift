import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    
    // MARK: Constants
    private enum Constants {
        static let introLabelTopSpacing: CGFloat = 16.0
        static let photoDimension: CGFloat = 250.0
        static let photo = UIImage(named:"photo.jpg")
        static let intro = "I’m Pedro, a Portuguese iOS Engineer since February 2017. I’ve studied at Instituto Superior de Engenharia do Porto and there I’ve got my bachelor’s degree in Software Engineering. Currently, I’m working in Farfetch."
    }
    
    // MARK: Properties
    private var photoImageView: UIImageView = {
        let imageView = UIImageView(image: Constants.photo)
        imageView.layer.cornerRadius = Constants.photoDimension/2
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private var introLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.intro
        label.textAlignment = .center
        label.numberOfLines = 0;
        
        return label
    }()
    
    private let layoutGuide: UILayoutGuide = UILayoutGuide()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSubviewsAndGuides()
        setupConstraints()
    }
    
    // MARK: Setup
    private func setupSubviewsAndGuides() {
        
        // Layout Guide
        view.addLayoutGuide(layoutGuide)
        
        // Intro Label
        view.addSubview(introLabel)
        
        // Photo ImageView
        view.addSubview(photoImageView)
    }
    
    private func setupConstraints() {
        
        [introLabel, photoImageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate(
            [
                layoutGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                layoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                layoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                photoImageView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
                
                photoImageView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
                photoImageView.heightAnchor.constraint(equalToConstant: Constants.photoDimension),
                photoImageView.widthAnchor.constraint(equalToConstant: Constants.photoDimension),
                
                introLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: Constants.introLabelTopSpacing),
                introLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
                introLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
                introLabel.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor)
            ]
        )
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

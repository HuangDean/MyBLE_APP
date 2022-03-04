import UIKit

class DetectBoardView: UIView {
    
    open var titleLabel: UILabel!
    open var imageView1: UIImageView!
    open var imageView2: UIImageView!
    
    private var count: Int!
    
    init(count: Int) {
        super.init(frame: .zero)
        
        self.count = count
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        // image base px: 14
        
        imageView1 = UIImageView(frame: .zero)
        imageView1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView1)
        imageView1.image = UIImage(named: "detect_board_normal")
        imageView1.contentMode = .scaleAspectFit
        
        if count == 2 {
            imageView2 = UIImageView(frame: .zero)
            imageView2.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(imageView2)
            imageView2.image = UIImage(named: "detect_board_normal")
            imageView2.contentMode = .scaleAspectFit
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                
                imageView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                imageView1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                imageView1.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                
                imageView2.centerYAnchor.constraint(equalTo: imageView1.centerYAnchor),
                imageView2.leadingAnchor.constraint(equalTo: imageView1.leadingAnchor, constant: 30),
                imageView2.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                
                imageView1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                imageView1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 28),
                imageView1.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -28),
                imageView1.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
    
    // MARK: - Public func
    
    open func updateLamp(lampIndex: Int, isLight: Bool) {
        let lampView: UIImageView!
        
        if lampIndex == 1 {
            lampView = imageView1
        } else {
            lampView = imageView2
        }
        
        if isLight {
            lampView.image = UIImage(named: "detect_board_light")
        } else {
            lampView.image = UIImage(named: "detect_board_normal")
        }
    }
}

import UIKit

class StatusTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var statusLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpViews()
    }
    
    func setUpViews() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.backgroundColor = UIColor.init(named: "theme")
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        statusLabel = UILabel(frame: .zero)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(statusLabel)
        statusLabel.backgroundColor = .white
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 66),
            
            statusLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 15),
            statusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            statusLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
        ])
    }
}

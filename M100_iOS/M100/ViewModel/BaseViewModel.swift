import RxSwift
import UIKit

class BaseViewModel {
    
    enum BaseStatus {
        case Loading
        case Complete
        case DisConnect
        case Save
    }
    
    internal var disposeBag = DisposeBag()
    
    func viewWillDisappear() {
        disposeBag = DisposeBag()
    }
    
    func getResString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

//import Foundation
//import SQLite
//
//struct DBManager {
//
//    init() {
//        // 建立一個路徑儲存資料庫檔案
//        let db = try Connection("path/to/db.sqlite3")
//    }
//
//
//
//    // 建立表結構
//    let users = Table("M100")
//    let permission = Expression<String?>("password")
//    let password = Expression<String?>("password")
//    let peripheral = Expression<String?>("peripheral")
//
//    //建立資料庫插入對應的列
//    try db.run(users.create { t in
//        t.column(id, primaryKey: true)
//        t.column(name)
//        t.column(email, unique: true)
//    })
//    
//}

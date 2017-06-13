/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData

extension InitFeed {

    @NSManaged var type: String?
    @NSManaged var date: NSDate?
    @NSManaged var objectDate: NSDate?
    @NSManaged var id: String?
    @NSManaged var textBody: String?
    @NSManaged var isRead: NSNumber?
    @NSManaged var idUsrVincles: String?
    @NSManaged var vincleName: String?
    @NSManaged var vincleLastName: String?

}

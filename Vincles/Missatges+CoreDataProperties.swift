/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData

extension Missatges {

    @NSManaged var id: String?
    @NSManaged var idUserFrom: String?
    @NSManaged var idUserTo: String?
    @NSManaged var metadataTipus: String?
    @NSManaged var sendTime: NSDate?
    @NSManaged var text: String?
    @NSManaged var watched: NSNumber?
    @NSManaged var idAdjuntContents: NSData?

}

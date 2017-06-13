/***************************************************************************************************************
 
 Copyright (c) 2016-2017 i2CAT Foundation. All rights reserved.
 Use of this source code is governed by the LICENSE file in the root of the source tree.
 
 ****************************************************************************************************************/

import Foundation
import CoreData

extension Cita {

    @NSManaged var id: String?
    @NSManaged var state: String?
    @NSManaged var date: NSDate?
    @NSManaged var duration: String?
    @NSManaged var calendarId: String?
    @NSManaged var userCreator: String?
    @NSManaged var descript: String?
}

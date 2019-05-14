//
//  CKCache.h
//  MBCalendarKit
//
//  Created by Moshe Berman on 9/5/17.
//  Copyright © 2017 Moshe Berman. All rights reserved.
//

@import Foundation;

@interface CKCache : NSObject

// MARK: - Accessing the Shared Cache

/**
 A shared cache for storing things the framework needs to display correctly.
 
 @return The shared cache.
 */
+ (nonnull instancetype)sharedCache;

// MARK: - NSDateFormatter Caching

/**
 A date formatter.
 */
@property (strong, nonatomic, nonnull, readonly) NSDateFormatter *dateFormatter;

@end

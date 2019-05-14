//
//  CKCalendarModelObserver.h
//  MBCalendarKit
//
//  Created by Moshe Berman on 8/11/17.
//  Copyright © 2017 Moshe Berman. All rights reserved.
//

@import Foundation;

@class CKCalendarModel;

/**
 This protocol defines an interface for the calendar view to internally monitor the `CKCalendarModel`.
 */
NS_SWIFT_NAME(CalendarModelObserver)
@protocol CKCalendarModelObserver <NSObject>

// MARK: - Handling Date Changes
/**
 Called before the calendar model will change the its date.

 @param model The model object that will change.
 @param fromDate The old date.
 @param toDate The new date.
 */
- (void)calendarModel:(CKCalendarModel *)model willChangeFromDate:(NSDate *)fromDate toNewDate:(NSDate *)toDate;

/**
 Called before the calendar model will change the its date.
 
 @param model The model object that did change.
 @param fromDate The old date.
 @param toDate The new date.
 */
- (void)calendarModel:(CKCalendarModel *)model didChangeFromDate:(NSDate *)fromDate toNewDate:(NSDate *)toDate;


// MARK: - Handling Mode Changes

/**
 Called after the calendar model updates its `displayMode`, `calendar` or `locale` properties.
 
 @param model The model that did change.
 */
- (void)calendarModelDidInvalidate:(CKCalendarModel *)model;

@end

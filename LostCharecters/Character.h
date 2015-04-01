//
//  Character.h
//  LostCharecters
//
//  Created by Rockstar. on 3/31/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Character : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *actorName;
@property (nonatomic, retain) NSString *seatNumber;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSData *imageData;

@end

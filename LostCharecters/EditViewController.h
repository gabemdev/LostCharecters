//
//  EditViewController.h
//  LostCharecters
//
//  Created by Rockstar. on 3/31/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface EditViewController : UIViewController
@property NSManagedObjectContext *moc;
@property NSManagedObject *selectedCharacter;

@end

//
//  AddNewLostViewController.m
//  LostCharecters
//
//  Created by Rockstar. on 3/31/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import "AddNewLostViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface AddNewLostViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) UIImage *selectedImage;

@property NSManagedObjectContext *moc;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *actorTextField;
@property (weak, nonatomic) IBOutlet UITextField *seatTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;

@end

@implementation AddNewLostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.image.layer.cornerRadius = self.image.frame.size.width/2;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPic:)];
    [singleTap setNumberOfTapsRequired:1];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.moc = delegate.managedObjectContext;

    [self.nameTextField becomeFirstResponder];
}


#pragma mark - UIImagePickerController
- (void)promptForCamera {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)promptForPhotoRoll {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.image setImage:image];
    self.selectedImage = image;
    self.image.layer.cornerRadius = self.image.frame.size.width/2;
    [self.view layoutSubviews];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Actions
- (IBAction)doneWasPressed:(id)sender {
    if ([self.nameTextField.text isEqualToString:@""] && [self.actorTextField.text isEqualToString:@""] && [self.genderTextField.text isEqualToString:@""] && [self.seatTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing information" message:@"Please enter all missing information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        NSManagedObject *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.moc];
        [character setValue:self.nameTextField.text forKey:@"name"];
        [character setValue:self.actorTextField.text forKey:@"actor"];
        [character setValue:self.genderTextField.text forKey:@"gender"];

        NSString *seatString = self.seatTextField.text;
        NSNumber *seat = [NSNumber numberWithInteger:[seatString integerValue]];
        [character setValue:seat forKey:@"seat"];

        NSData *imageData = UIImagePNGRepresentation(self.selectedImage);
        [character setValue:imageData forKey:@"image"];
        [self.moc save:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)selectPic:(UITapGestureRecognizer *)sender {
    UIActionSheet *actionSheet = nil;
         actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                  delegate:self cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];

        // only add avaliable source to actionsheet
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            [actionSheet addButtonWithTitle:@"Photo Library"];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [actionSheet addButtonWithTitle:@"Camera Roll"];
        }

        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];

    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex != actionSheet.firstOtherButtonIndex) {
            [self promptForPhotoRoll];
        } else {
            [self promptForCamera];
        }
    }
}


@end

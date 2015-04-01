//
//  EditViewController.m
//  LostCharecters
//
//  Created by Rockstar. on 3/31/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *actorTextField;
@property (weak, nonatomic) IBOutlet UITextField *seatTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;

@property (weak, nonatomic) IBOutlet UIImageView *characterImageView;
@property (nonatomic) UIImage *selectedImage;

@property BOOL isEditSelected;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isEditSelected = NO;
    self.nameTextField.enabled = self.isEditSelected;
    self.actorTextField.enabled = self.isEditSelected;
    self.seatTextField.enabled = self.isEditSelected;
    self.genderTextField.enabled = self.isEditSelected;
    [self loadFields];


    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPic:)];
    [singleTap setNumberOfTapsRequired:1];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    // Do any additional setup after loading the view.
}


- (void)loadFields {
    self.nameTextField.text = [self.selectedCharacter valueForKey:@"name"];
    self.actorTextField.text = [self.selectedCharacter valueForKey:@"actor"];
    self.seatTextField.text = [NSString stringWithFormat:@"%@",[self.selectedCharacter valueForKey:@"seat"]];
    self.genderTextField.text = [self.selectedCharacter valueForKey:@"gender"];
    self.characterImageView.image = [UIImage imageWithData:[self.selectedCharacter valueForKey:@"image"]];
}

#pragma mark - UItextField

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)sender {
    if (!self.isEditSelected) {
        sender.title = @"Done";
        [self.selectedCharacter setValue:self.nameTextField.text forKey:@"name"];
        [self.selectedCharacter setValue:self.actorTextField.text forKey:@"actor"];
        [self.selectedCharacter setValue:self.genderTextField.text forKey:@"gender"];

        NSNumber *seat = [NSNumber numberWithInt:(int)self.seatTextField.text.integerValue];
        [self.selectedCharacter setValue:seat forKey:@"seat"];

        [self.moc save:nil];
    } else {
        sender.title = @"Edit";
    }

    self.nameTextField.enabled = !self.isEditSelected;
    self.actorTextField.enabled = !self.isEditSelected;
    self.seatTextField.enabled = !self.isEditSelected;
    self.genderTextField.enabled = !self.isEditSelected;
    self.isEditSelected = !self.isEditSelected;

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.nameTextField)
    {
        [self.selectedCharacter setValue:self.nameTextField.text forKey:@"name"];
    }
    if (textField == self.actorTextField) {
        [self.selectedCharacter setValue:self.actorTextField.text forKey:@"actor"];
    }
    if (textField == self.seatTextField) {

        NSNumber *seat = [NSNumber numberWithInt:(int)self.seatTextField.text.integerValue];
        [self.selectedCharacter setValue:seat forKey:@"seat"];
    }
    if (textField == self.genderTextField) {
        [self.selectedCharacter setValue:self.genderTextField.text forKey:@"gender"];
    }

    [self.moc save:nil];
}

#pragma mark - UIImagePickerDelegate
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
    [self.characterImageView setImage:image];
    self.selectedImage = image;
    self.characterImageView.layer.cornerRadius = self.characterImageView.frame.size.width/2;
    [self.view layoutSubviews];

    NSData *imageData = UIImagePNGRepresentation(image);
    [self.selectedCharacter setValue:imageData forKey:@"image"];
    [self.moc save:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end

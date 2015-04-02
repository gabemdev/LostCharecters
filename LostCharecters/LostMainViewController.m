//
//  ViewController.m
//  LostCharecters
//
//  Created by Rockstar. on 3/31/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import "LostMainViewController.h"
#import "AppDelegate.h"
#import "LostTableViewCell.h"
#import "EditViewController.h"

@interface LostMainViewController ()<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *addButton;
@property NSManagedObjectContext *moc;
@property NSArray *plistCharacthers;
@property NSMutableArray *lostCharacters;
@property BOOL isToggled;
@property BOOL allRowsSelected;

@end

@implementation LostMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.moc = delegate.managedObjectContext;
    [self loadPlist];
    [self updateButtonsToMatchTableState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchNewData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lostCharacters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *character = self.lostCharacters[indexPath.row];
    LostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.nameLabel.text = [character valueForKey:@"name"];
    cell.actorLabel.text = [character valueForKey:@"actor"];
    cell.seatLabel.text = [NSString stringWithFormat:@"Seat#: %@",[character valueForKey:@"seat"]];
    cell.genderLabel.text = [character valueForKey:@"gender"];

    if (cell.characterImage.image == nil) {
        cell.characterImage.image = [UIImage imageNamed:@"no-user"];
    } else {
    NSData *imageData = [character valueForKey:@"image"];
    cell.characterImage.image = [UIImage imageWithData:imageData];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *character = self.lostCharacters[indexPath.row];
        [self.moc deleteObject:character];
        [self.moc save:nil];

        [self fetchNewData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"SMOKE MONSTER";
}

//https://developer.apple.com/library/ios/samplecode/TableMultiSelect/Listings/MultiSelectTableView_APLMasterViewController_m.html

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateButtonsToMatchTableState];
}


#pragma mark - CoreData
- (void)loadPlist {
    [self fetchNewData];
    if (self.lostCharacters.count == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"lost" ofType:@"plist"];
        self.plistCharacthers = [[NSArray alloc] initWithContentsOfFile:path];

        for (NSDictionary *lost in self.plistCharacthers) {
            NSManagedObject *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.moc];
            [character setValue:lost[@"passenger"] forKey:@"name"];
            [character setValue:lost[@"actor"] forKey:@"actor"];
            [self.moc save:nil];
        }
    }
    [self.tableView reloadData];
}

- (void)fetchNewData {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];
    self.lostCharacters = [[self.moc executeFetchRequest:request error:nil] mutableCopy];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortTwo = [[NSSortDescriptor alloc] initWithKey:@"gender" ascending:YES];

    if (self.segmentControl.selectedSegmentIndex == 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"A"];
    } else if (self.segmentControl.selectedSegmentIndex == 1) {
        request.predicate = [NSPredicate predicateWithFormat:@"gender == 'Male'"];
    }

    request.sortDescriptors = @[sort, sortTwo];
    [self.tableView reloadData];
}


#pragma mark - Actions
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

- (IBAction)lostToggle:(UISegmentedControl *)sender {
    self.isToggled = !self.isToggled;
    [self fetchNewData];
}


//https://developer.apple.com/library/ios/samplecode/TableMultiSelect/Listings/MultiSelectTableView_APLMasterViewController_m.html
- (IBAction)editAction:(id)sender
{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // The user tapped one of the OK/Cancel buttons.
    if (buttonIndex == 0)
    {
        // Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

        for (NSIndexPath *indexPath in selectedRows)
        {
            NSManagedObject *characterToDelete = self.lostCharacters[indexPath.row];
            [self.moc deleteObject:characterToDelete];
            [self.moc save:nil];
        }

        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            // Delete the objects from our data model.
            [self.lostCharacters removeObjectsAtIndexes:indicesOfItemsToDelete];

            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        else
        {
            // Delete everything, delete the objects from our data model.
            for (int i = 0; i < self.lostCharacters.count; i++)
            {
                NSManagedObject *characterToDelete = self.lostCharacters[i];
                [self.moc deleteObject:characterToDelete];
                [self.moc save:nil];
            }
            [self.lostCharacters removeAllObjects];

            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }
}

- (IBAction)deleteAction:(id)sender
{
    // Open a dialog with just an OK button.
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }

    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];

    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;

    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.leftBarButtonItem = self.cancelButton;

        [self updateDeleteButtonTitle];

        self.navigationItem.rightBarButtonItem = self.deleteButton;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = self.addButton;
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.lostCharacters.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.leftBarButtonItem = self.editButton;
    }
}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

    BOOL allItemsAreSelected = selectedRows.count == self.lostCharacters.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;

    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.tableView.editing == YES)
    {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    if ([segue.identifier isEqualToString:@"edit"]) {
        EditViewController *vc = segue.destinationViewController;
        vc.moc = self.moc;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSManagedObject *selected = self.lostCharacters[indexPath.row];
        vc.selectedCharacter = selected;
    }
}

- (IBAction)onSegmentSelected:(UISegmentedControl *)sender {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Character"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortTwo = [[NSSortDescriptor alloc] initWithKey:@"gender" ascending:YES];

    if (self.segmentControl.selectedSegmentIndex == 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH %@", @"A"];
    } else if (self.segmentControl.selectedSegmentIndex == 1) {
        request.predicate = [NSPredicate predicateWithFormat:@"gender == 'Male'"];
    }

    request.sortDescriptors = @[sort, sortTwo];


}
@end

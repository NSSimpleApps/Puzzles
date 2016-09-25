//
//  CollectionViewController.m
//  Puzzles
//
//  Created by NSSimpleApps on 23.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "CollectionViewController.h"
#import "NSMutableArray+Shuffle.h"
#import "PuzzleCell.h"


@implementation UICollectionView (AdditionalMethod)

- (void)exchangeIndexPath:(NSIndexPath*)oldIndexPath withIndexPath:(NSIndexPath*)newIndexPath {
    
    [self moveItemAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
    [self moveItemAtIndexPath:newIndexPath toIndexPath:oldIndexPath];
}

@end

static const NSInteger kNumberOfCells = 4;

@interface CollectionViewController ()

@property (strong, nonatomic) NSIndexPath* voidIndexPath;

@property (strong, nonatomic) NSMutableArray<NSNumber *> * labels;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.voidIndexPath = [NSIndexPath indexPathForRow:arc4random_uniform(kNumberOfCells)
                                            inSection:arc4random_uniform(kNumberOfCells)];
    
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = self.collectionView.frame.size.height;
    CGFloat sizeOfBoard = 4*(50 + 15);
    
    self.collectionView.contentInset = UIEdgeInsetsMake((height - sizeOfBoard)/2, (width - sizeOfBoard)/2, (height - sizeOfBoard)/2, (width - sizeOfBoard)/2);
    
    self.labels = [NSMutableArray arrayWithCapacity:16];
    
    [self initializeArrayOfLabels];
}

- (void)initializeArrayOfLabels {
    
    [self.labels removeAllObjects];
    
    for (NSInteger i = 0; i < kNumberOfCells*kNumberOfCells - 1; i++) {
        
        self.labels[i] = @(i + 1);
    }
    
    [self.labels shuffle];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return kNumberOfCells;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return kNumberOfCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:self.voidIndexPath]) {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VoidCell" forIndexPath:indexPath];
        return cell;
    } else {
        
        PuzzleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PuzzleCell" forIndexPath:indexPath];
        [cell setLabel:[self.labels lastObject]];
        [self.labels removeLastObject];
        
        return cell;
    }
}

- (IBAction)startAgain:(UIBarButtonItem *)sender {
    
    self.voidIndexPath = [NSIndexPath indexPathForRow:arc4random_uniform(kNumberOfCells)
                                            inSection:arc4random_uniform(kNumberOfCells)];
    
    [self initializeArrayOfLabels];
    
    [self.collectionView reloadData];
}

- (IBAction)handleUpSwipe:(UISwipeGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.row == self.voidIndexPath.row) && (indexPath.section > self.voidIndexPath.section)) {
        
        NSInteger row = indexPath.row;
        
        for (NSInteger section = self.voidIndexPath.section; section < indexPath.section; section++) {
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:row inSection:(section + 1)]];
            } completion:nil];
        }
        self.voidIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (IBAction)handleDownSwipe:(UISwipeGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.row == self.voidIndexPath.row) && (self.voidIndexPath.section > indexPath.section)) {
        
        NSInteger row = indexPath.row;
        
        for (NSInteger section = self.voidIndexPath.section; section > indexPath.section; section--) {
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:row inSection:(section - 1)]];
            } completion:nil];
        }
        self.voidIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (IBAction)handleLeftSwipe:(UISwipeGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.section == self.voidIndexPath.section) && (indexPath.row > self.voidIndexPath.row)) {
        
        NSInteger section = indexPath.section;
        for (NSInteger row = self.voidIndexPath.row; row < indexPath.row; row++) {
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:(row + 1) inSection:section]];
            } completion:nil];
        }
        self.voidIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (IBAction)handleRightSwipe:(UISwipeGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.section == self.voidIndexPath.section) && (self.voidIndexPath.row > indexPath.row)) {
        
        NSInteger section = indexPath.section;
        for (NSInteger row = self.voidIndexPath.row; row > indexPath.row; row--) {
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:(row - 1) inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            } completion:nil];
        }
        self.voidIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (void)movementCellDidEnd {
    
    if ((self.voidIndexPath.section != kNumberOfCells - 1) || (self.voidIndexPath.row != kNumberOfCells - 1)) {
        
        return;
    }
    
    for (NSInteger index = 0; index < kNumberOfCells*kNumberOfCells - 1; index++) {
        
        NSInteger section = index/kNumberOfCells, row = index - section*kNumberOfCells;
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        PuzzleCell* puzzleCell = (PuzzleCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        if ([puzzleCell label] != index + 1) {
            
            return;
        }
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"WIN!" message:@"All cells are in the right order" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Again"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                                          
                                                          [self startAgain:nil];
                                                      }];
    [alertController addAction:closeAction];
    [alertController addAction:addAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

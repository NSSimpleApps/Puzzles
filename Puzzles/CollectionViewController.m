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

@property (strong, nonatomic) NSIndexPath* emptyIndexPath;
@property (strong, nonatomic) NSMutableArray<NSNumber *> * labels;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emptyIndexPath = [NSIndexPath indexPathForRow:arc4random_uniform(kNumberOfCells)
                                             inSection:arc4random_uniform(kNumberOfCells)];
    
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = self.collectionView.frame.size.height;
    CGFloat sizeOfBoard = 4*(50 + 15);
    
    self.collectionView.contentInset = UIEdgeInsetsMake((height - sizeOfBoard)/2, (width - sizeOfBoard)/2, (height - sizeOfBoard)/2, (width - sizeOfBoard)/2);
    self.labels = [NSMutableArray arrayWithCapacity:kNumberOfCells * kNumberOfCells];
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
    if ([indexPath isEqual:self.emptyIndexPath]) {
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
    self.emptyIndexPath = [NSIndexPath indexPathForRow:arc4random_uniform(kNumberOfCells)
                                             inSection:arc4random_uniform(kNumberOfCells)];
    [self initializeArrayOfLabels];
    [self.collectionView reloadData];
}

- (IBAction)handleUpSwipe:(UISwipeGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.row == self.emptyIndexPath.row) && (indexPath.section > self.emptyIndexPath.section)) {
        NSInteger row = indexPath.row;
        
        for (NSInteger section = self.emptyIndexPath.section; section < indexPath.section; section++) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:row inSection:(section + 1)]];
            } completion:nil];
        }
        self.emptyIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (IBAction)handleDownSwipe:(UISwipeGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.row == self.emptyIndexPath.row) && (self.emptyIndexPath.section > indexPath.section)) {
        NSInteger row = indexPath.row;
        
        for (NSInteger section = self.emptyIndexPath.section; section > indexPath.section; section--) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:row inSection:(section - 1)]];
            } completion:nil];
        }
        self.emptyIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (IBAction)handleLeftSwipe:(UISwipeGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.section == self.emptyIndexPath.section) && (indexPath.row > self.emptyIndexPath.row)) {
        NSInteger section = indexPath.section;
        
        for (NSInteger row = self.emptyIndexPath.row; row < indexPath.row; row++) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:(row + 1) inSection:section]];
            } completion:nil];
        }
        self.emptyIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (IBAction)handleRightSwipe:(UISwipeGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if ((indexPath.section == self.emptyIndexPath.section) && (self.emptyIndexPath.row > indexPath.row)) {
        NSInteger section = indexPath.section;
        
        for (NSInteger row = self.emptyIndexPath.row; row > indexPath.row; row--) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView exchangeIndexPath:[NSIndexPath indexPathForRow:(row - 1) inSection:section]
                                         withIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            } completion:nil];
        }
        self.emptyIndexPath = indexPath;
        [self movementCellDidEnd];
    }
}

- (void)movementCellDidEnd {
    if ((self.emptyIndexPath.section != kNumberOfCells - 1) || (self.emptyIndexPath.row != kNumberOfCells - 1)) {
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
                                                          [self startAgain:nil];
                                                      }];
    [alertController addAction:closeAction];
    [alertController addAction:addAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

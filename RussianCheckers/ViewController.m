//
//  ViewController.m
//  RussianCheckers
//
//  Created by Admin on 10.10.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];
    UIImage* imageTableView = [UIImage imageNamed:@"wood.jpg"];
    NSInteger widthSuper = self.view.bounds.size.width;
    NSInteger heightSuper = self.view.bounds.size.height;
    UIImageView* tableView = [[UIImageView alloc] initWithFrame:CGRectMake(
                                                                           widthSuper*0.1f,
                                                                           heightSuper*0.1f,
                                                                           heightSuper*0.6f,
                                                                           heightSuper*0.6f)];
    tableView.image = imageTableView;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:tableView];
    
    NSInteger widthTable = tableView.bounds.size.width;
    NSInteger heightTable = tableView.bounds.size.height;
    UIView* battlefieldView = [[UIView alloc] initWithFrame:CGRectMake(
                                                                      widthTable*0.1f,
                                                                      heightTable*0.1f,
                                                                      heightTable*0.8f,
                                                                      heightTable*0.8f)];
    battlefieldView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
    [tableView addSubview:battlefieldView];
    
    //Create chessboard
    NSInteger widthBox = battlefieldView.bounds.size.width/8;
    NSInteger heightBox = battlefieldView.bounds.size.height/8;
    for (int i = 0; i<64; i++) {
        NSArray* arrayXY = [self calculateCoordinateForIndex:i];
        int x = [arrayXY[0] intValue];
        int y = [arrayXY[1] intValue];
        NSLog(@"x: %d, y: %d. For index: %d. Color box: %@", x, y, i,
              [self insertOrNotToBoxInCoordinateX:x Y:y] ? @"Black" : @"White");
        if ([self insertOrNotToBoxInCoordinateX:x Y:y]) {
            NSArray* arrayCoordinate = [self calculatePlaceForX:x Y:y Size:widthBox];
            int xCoordinate = [arrayCoordinate[0] intValue];
            int yCoordinate = [arrayCoordinate[1] intValue];
            UIView* chessBox = [[UIView alloc] initWithFrame:CGRectMake(xCoordinate, yCoordinate, widthBox, heightBox)];
            chessBox.backgroundColor = [UIColor blackColor];
            [battlefieldView addSubview:chessBox];
        }
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Support method
- (NSArray*) calculateCoordinateForIndex:(NSInteger) index {
    int y = 0;
    int x = (int)index;
    while (YES) {
        if (x < 8) {
            break;
        }
        x -= 8;
        y += 1;
    }
    return [NSArray arrayWithObjects: [NSNumber numberWithInt:x+1],[NSNumber numberWithInt:y+1], nil];
}

- (BOOL) insertOrNotToBoxInCoordinateX:(NSInteger) x Y:(NSInteger) y {
    if ((x%2 != 0 || y%2 != 0) && (x%2 == 0 || y%2 == 0)) {
        return true;
    } else {
        return false;
    }
}

- (NSArray*) calculatePlaceForX:(NSInteger) x Y:(NSInteger) y Size:(NSInteger) size {
    int xCoordinate = 0;
    int yCoordinate = 0;
    while (YES) {
        if (x == 1) {
            break;
        }
        xCoordinate += size;
        x--;
    }
    while (YES) {
        if (y == 1) {
            break;
        }
        yCoordinate += size;
        y--;
    }
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:xCoordinate], [NSNumber numberWithInt:yCoordinate], nil];
}

@end

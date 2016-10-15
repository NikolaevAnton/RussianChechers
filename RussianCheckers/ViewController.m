//
//  ViewController.m
//  RussianCheckers
//
//  Created by Admin on 10.10.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIView* viewTable;
@property (strong, nonatomic) UIView* viewBattelfield;
@property (strong, nonatomic) NSMutableArray* collectionBlackBox;
@property (strong, nonatomic) NSMutableArray* collectionCheckers;
@property (strong, nonatomic) NSMutableDictionary* dictionaryBox;
@property (strong, nonatomic) NSMutableArray* findPlace;

@property (weak, nonatomic) UIView* movedView;
@property (assign, nonatomic) CGPoint deltaRect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];
    self.collectionBlackBox = [[NSMutableArray alloc] init];
    self.collectionCheckers = [[NSMutableArray alloc] init];
    self.dictionaryBox = [[NSMutableDictionary alloc] init];
    self.findPlace = [[NSMutableArray alloc] init];
    
    //Создание "деревянной" подложки и поля боя. Ссылки на вью поля боя и подложки записаны в проперти
    [self createWoodTableAndBattelfield];
    
    //Делаем черные и белые поля
    [self createChessboardForView:self.viewBattelfield];
    
    //Расставляем шашки по полям
    [self createBlackAndWhiteChecker];
    
    //Создание словаря - номер черный клетки(ключ) и номер шашки(значение).
    //В касестве значения для пустых мест выбрано число -1
    //запись в проперти dictionaryBox
    [self createDicrionaryBox];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITouch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    UIView* view = [self.view hitTest:point withEvent:event];
    if (![view isEqual:self.view] && ![view isEqual:self.viewTable] && ![view isEqual:self.viewBattelfield]) {
        self.movedView = view;
        [self findInArr:view];
        [self.viewBattelfield bringSubviewToFront:self.movedView];
        self.deltaRect = CGPointMake(CGRectGetMidX(view.frame) - point.x, CGRectGetMidY(view.frame) - point.y);
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.movedView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                             self.movedView.alpha = 0.5f;
                         }];
        for (NSNumber* number in self.findPlace) {
            int key = [number intValue];
            UIView* boxFindView = _collectionBlackBox[key];
            boxFindView.backgroundColor = [UIColor lightGrayColor];
        }
    } else {
        self.movedView = nil;
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (self.movedView) {
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        self.movedView.center = CGPointMake(self.deltaRect.x + point.x, self.deltaRect.y + point.y);
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    //место где задается постановка шашки на вакантное место либо ее возврат на исходную позицию
    [self onTouchesEnded];
}
- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    [self onTouchesEnded];
}

- (void) onTouchesEnded {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.movedView.transform = CGAffineTransformIdentity;
                         self.movedView.alpha = 1.f;
                     }];
    self.movedView = nil;
    for (NSNumber* number in self.findPlace) {
        int key = [number intValue];
        UIView* boxFindView = _collectionBlackBox[key];
        boxFindView.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark - Support method for find place for chess
- (void) findInArr:(UIView*) findView {
    int chess = 0;
    int pointer = 0;
    for (UIView* view in self.collectionCheckers) {
        if ([findView isEqual:view]) {
            pointer = (int)[self indexBoxForIndexChecker:chess];
            //NSLog(@"Find! Number chess:%d, number field:%d", chess, pointer);
        }
        chess++;
    }
    [self chekPlaceForBusy:pointer];
}

- (NSInteger) indexBoxForIndexChecker:(NSInteger) index {
    if (index > 11 && index <= 19) {
        return -1;
    } else if (index > 19) {
        int x = 20 - (int)index;
        return 23 + x;
    } else {
        return index;
    }
}

- (void) createDicrionaryBox {
    
    for (int i = 0; i<32; i++) {
        NSNumber* key = [NSNumber numberWithInt:i];
        NSNumber* value = [NSNumber numberWithInt:(int)[self indexBoxForIndexChecker:i]];
        [self.dictionaryBox setObject:value forKey:key];
    }
    
}

#pragma mark - Calculate vacant place

- (NSArray*) seachVakantPlaceForPoint:(NSInteger) point {
    NSArray* rightBranch = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:-1], [NSNumber numberWithInt:28], [NSNumber numberWithInt:-1],
                            [NSNumber numberWithInt:20], [NSNumber numberWithInt:24], [NSNumber numberWithInt:29],
                            [NSNumber numberWithInt:-1], [NSNumber numberWithInt:12], [NSNumber numberWithInt:16],
                            [NSNumber numberWithInt:21], [NSNumber numberWithInt:25], [NSNumber numberWithInt:30],
                            [NSNumber numberWithInt:-1], [NSNumber numberWithInt:4], [NSNumber numberWithInt:8],
                            [NSNumber numberWithInt:13], [NSNumber numberWithInt:17], [NSNumber numberWithInt:22],
                            [NSNumber numberWithInt:26], [NSNumber numberWithInt:31], [NSNumber numberWithInt:-1],
                            [NSNumber numberWithInt:0], [NSNumber numberWithInt:5], [NSNumber numberWithInt:9],
                            [NSNumber numberWithInt:14], [NSNumber numberWithInt:18], [NSNumber numberWithInt:23],
                            [NSNumber numberWithInt:27], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:1],
                            [NSNumber numberWithInt:6], [NSNumber numberWithInt:10], [NSNumber numberWithInt:15],
                            [NSNumber numberWithInt:19], [NSNumber numberWithInt:-1], [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:7], [NSNumber numberWithInt:11], [NSNumber numberWithInt:-1],
                            [NSNumber numberWithInt:3], [NSNumber numberWithInt:-1], nil];
    NSArray* leftBranch = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:-1], [NSNumber numberWithInt:4], [NSNumber numberWithInt:0],
                           [NSNumber numberWithInt:-1], [NSNumber numberWithInt:12], [NSNumber numberWithInt:8],
                           [NSNumber numberWithInt:5], [NSNumber numberWithInt:1], [NSNumber numberWithInt:-1],
                           [NSNumber numberWithInt:20], [NSNumber numberWithInt:16], [NSNumber numberWithInt:13],
                           [NSNumber numberWithInt:9], [NSNumber numberWithInt:6], [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:-1], [NSNumber numberWithInt:28], [NSNumber numberWithInt:24],
                           [NSNumber numberWithInt:21],
                           [NSNumber numberWithInt:17], [NSNumber numberWithInt:14], [NSNumber numberWithInt:10],
                           [NSNumber numberWithInt:7], [NSNumber numberWithInt:3], [NSNumber numberWithInt:-1],
                           [NSNumber numberWithInt:29], [NSNumber numberWithInt:25], [NSNumber numberWithInt:22],
                           [NSNumber numberWithInt:18], [NSNumber numberWithInt:15], [NSNumber numberWithInt:11],
                           [NSNumber numberWithInt:-1],
                           [NSNumber numberWithInt:30], [NSNumber numberWithInt:26], [NSNumber numberWithInt:23],
                           [NSNumber numberWithInt:19], [NSNumber numberWithInt:-1],
                           [NSNumber numberWithInt:31], [NSNumber numberWithInt:27],
                           [NSNumber numberWithInt:-1], nil];
    
    int indexForRightBranch = 0;
    int indexForLeftBranch = 0;
    
    for (int i = 0; i < rightBranch.count; i++) {
        NSNumber* temp = rightBranch[i];
        int tempValue = [temp intValue];
        if (point == tempValue) {
            indexForRightBranch = i;
        }
    }
    
    for (int i = 0; i < leftBranch.count; i++) {
        NSNumber* temp = leftBranch[i];
        int tempValue = [temp intValue];
        if (point == tempValue) {
            indexForLeftBranch = i;
        }
    }
    
    
    NSArray* vacantPlaces = [NSArray arrayWithObjects:
                             rightBranch[indexForRightBranch - 1], rightBranch[indexForRightBranch + 1],
                             leftBranch[indexForLeftBranch - 1], leftBranch[indexForLeftBranch + 1], nil];
    return vacantPlaces;
}

- (void) chekPlaceForBusy:(NSInteger) pointer {
    NSArray* arrVacancy = [self seachVakantPlaceForPoint:pointer];
    self.findPlace = nil;
    self.findPlace = [[NSMutableArray alloc] init];
    for(NSNumber* number in arrVacancy) {
        int num = [number intValue];
        if (num != -1) {
            NSNumber* boxNumber = self.dictionaryBox[number];
            if ([boxNumber intValue] == -1) {
                [self.findPlace addObject:number];
            }
        }
    }
    //NSLog(@"For pointer %ld you find vacant place:\n%@", (long)pointer, self.findPlace);
}



#pragma mark - Suport method for create chessBoard

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

- (NSArray*) calculatePlaceForX:(NSInteger) x Y:(NSInteger) y Size:(CGFloat) size {
    float xCoordinate = 0.f;
    float yCoordinate = 0.f;
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
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:xCoordinate], [NSNumber numberWithFloat:yCoordinate], nil];
}



- (void) createChessboardForView:(UIView*) battlefieldView {
    CGFloat widthBox = battlefieldView.bounds.size.width/8;
    CGFloat heightBox = battlefieldView.bounds.size.height/8;
    for (int i = 0; i<64; i++) {
        NSArray* arrayXY = [self calculateCoordinateForIndex:i];
        int x = [arrayXY[0] intValue];
        int y = [arrayXY[1] intValue];
        if ([self insertOrNotToBoxInCoordinateX:x Y:y]) {
            NSArray* arrayCoordinate = [self calculatePlaceForX:x Y:y Size:widthBox];
            CGFloat xCoordinate = [arrayCoordinate[0] floatValue];
            CGFloat yCoordinate = [arrayCoordinate[1] floatValue];
            UIView* chessBox = [[UIView alloc] initWithFrame:CGRectMake(xCoordinate, yCoordinate, widthBox, heightBox)];
            chessBox.backgroundColor = [UIColor blackColor];
            [battlefieldView addSubview:chessBox];
            [self.collectionBlackBox addObject:chessBox];
        }
    }
}


- (void) insertCheckerInBattlefieldForIndex:(NSUInteger) i Image:(UIImage*) image {
    UIView* cell = _collectionBlackBox[i];
    CGRect parentRect = cell.frame;
    CGRect curentRect = CGRectMake(CGRectGetMinX(parentRect), CGRectGetMinY(parentRect),
                                   CGRectGetWidth(parentRect), CGRectGetHeight(parentRect));
    UIView* box = [[UIView alloc] initWithFrame:curentRect];
    box.backgroundColor = [UIColor colorWithWhite:1 alpha:0.001f];
    
    [self.viewBattelfield addSubview:box];
    CGRect curentRectForImage = box.bounds;
    UIImageView* imageChecker = [[UIImageView alloc] initWithFrame:curentRectForImage];
    imageChecker.image = image;
    [box addSubview:imageChecker];
    [self.collectionCheckers addObject:box];
    
}

- (void) createBlackAndWhiteChecker {
    UIImage* blackChecker = [UIImage imageNamed:@"BlackChecker.png"];
    UIImage* whiteChecker = [UIImage imageNamed:@"WhiteChecker.png"];
    
    for (int i = 0; i<12; i++) {
        [self insertCheckerInBattlefieldForIndex:i Image:blackChecker];
    }
    
    int maxCountElement = (int)self.collectionBlackBox.count;
    for (int i = maxCountElement - 1; i >= maxCountElement - 12; i--) {
        [self insertCheckerInBattlefieldForIndex:i Image:whiteChecker];
    }
}

- (void) createWoodTableAndBattelfield {
    CGFloat size = self.view.bounds.size.width*0.8f;
    CGRect rectTable = CGRectMake(CGRectGetMidX(self.view.bounds) - size/2,
                                  CGRectGetMidY(self.view.bounds) - size*0.7f,
                                  size,
                                  size);
    self.viewTable = [[UIView alloc] initWithFrame:rectTable];
    //self.viewTable.backgroundColor = [UIColor whiteColor];
    self.viewTable.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.viewTable];
    
    CGFloat sizeBattelfield = rectTable.size.width*0.8f;
    CGRect rectBattelfield = CGRectMake(CGRectGetMidX(self.view.bounds) - sizeBattelfield/2,
                                        CGRectGetMidY(self.view.bounds) - sizeBattelfield*0.75f,
                                        sizeBattelfield,
                                        sizeBattelfield);
    self.viewBattelfield = [[UIView alloc] initWithFrame:rectBattelfield];
    self.viewBattelfield.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9f];
    self.viewBattelfield.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.viewBattelfield];
    
    //Делаем деревянный фон
    UIImage* woodImage = [UIImage imageNamed:@"wood.jpg"];
    CGRect woodRect = CGRectMake(0, 0, CGRectGetWidth(rectTable), CGRectGetHeight(rectTable));
    UIImageView* woodView = [[UIImageView alloc] initWithFrame:woodRect];
    woodView.image = woodImage;
    [self.viewTable addSubview:woodView];
}



- (void) printDicrionaryBox {
    for(int i = 0; i<32; i++) {
        NSNumber* vl = [self.dictionaryBox objectForKey:[NSNumber numberWithInt:i]];
        int vlInt = [vl intValue];
        NSLog(@"Key: %d. Value: %d",i,vlInt);
    }
}


@end
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
@property (strong, nonatomic) NSMutableArray* collectionBoxBusyForCheck;

//проперти для поиска возможных ходов для шашки
@property (strong, nonatomic) NSArray* rightBranch;
@property (strong, nonatomic) NSArray* leftBranch;
@property (strong, nonatomic) NSMutableArray* findPlace;

//Шашка, которую захватили мышкой и двигаем
@property (weak, nonatomic) UIView* movedView;
@property (assign, nonatomic) CGPoint deltaRect;

//Центр, с которому шашка оказалось на близком расстоянии
@property (assign, nonatomic) CGPoint findCenter;

//Номер клетки из которой начали движение
@property (assign, nonatomic) NSInteger find;
//Номер клетки, в которую будет устанвлена шашка
@property (assign, nonatomic) NSInteger findBox;

//Номер шашки, которую двигаем
@property (assign, nonatomic) NSInteger checker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Инициация массивов и настройка фона
    self.view.backgroundColor = [UIColor grayColor];
    self.collectionBlackBox = [[NSMutableArray alloc] init];
    self.collectionCheckers = [[NSMutableArray alloc] init];
    
    //Создание "деревянной" подложки и поля боя. Ссылки на вью поля боя и подложки записаны в проперти
    [self createWoodTableAndBattelfield];
    
    //Делаем черные и белые поля и заносим ссылки на вьюшки черных квадратов в проперти collectionBlackBox
    [self createChessboardForView:self.viewBattelfield];
    
    //Расставляем шашки по полям и заносим ссылки на вьюшки шашек в проперти collectionCheckers
    [self createBlackAndWhiteChecker];
    
    //Создание массива - номер черный клетки(индекс) и номер шашки(значение).
    //В касестве значения для пустых мест выбрано число -1
    //запись в проперти collectionBoxBusyForCheck
    [self createCollectionBoxBusyForCheck];
    
    //создание для шашки возможных ходов по диагонали и запись их проперти rightBranch, leftBranch
    [self createBranch];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIResponder method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    UIView* view = [self.view hitTest:point withEvent:event];
    if (![view isEqual:self.view] && ![view isEqual:self.viewTable] && ![view isEqual:self.viewBattelfield]) {
        self.movedView = view;
        [self seachVacantPlaceForCheker:view];//метод, который по вьюшке создает массив findPlace
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

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (self.movedView) {
        //NSLog(@"%@",NSStringFromCGPoint(self.movedView.center));
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        self.movedView.center = CGPointMake(self.deltaRect.x + point.x, self.deltaRect.y + point.y);
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    if ([self isItVacantPlaceForCurentChess]) {
        self.movedView.center = self.findCenter;
        //        NSLog(@"position start: %d position finish: %d", (int)self.find, (int)self.findBox);
        //        NSLog(@"coll box busy for check:\n%@", self.collectionBoxBusyForCheck);
        [self.collectionBoxBusyForCheck replaceObjectAtIndex:self.find withObject:[NSNumber numberWithInt:
                                                                                   -1]];
        [self.collectionBoxBusyForCheck replaceObjectAtIndex:self.findBox withObject:[NSNumber numberWithInteger:
                                                                                      self.checker]];
        //        NSLog(@"coll box busy for check after replace:\n%@", self.collectionBoxBusyForCheck);
    } else {
        UIView* startView = self.collectionBlackBox[self.find];
        self.movedView.center = startView.center;
        
    }
    
    [self onTouchesEnded];
}
- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
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


#pragma mark - Create playground
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

- (void) createCollectionBoxBusyForCheck {
    self.collectionBoxBusyForCheck = [[NSMutableArray alloc] init];
    for (int i = 0; i<32; i++) {
        NSNumber* value = [NSNumber numberWithInt:(int)[self indexBoxForIndexChecker:i]];
        [self.collectionBoxBusyForCheck addObject:value];
    }
    
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

- (void) createBranch {
    self.rightBranch = [NSArray arrayWithObjects:
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
    self.leftBranch = [NSArray arrayWithObjects:
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
}

#pragma mark - Method for find place for view

- (NSArray*) seachVakantPlaceForPoint:(NSInteger) point {
    int indexForRightBranch = 0;
    int indexForLeftBranch = 0;
    for (int i = 0; i < self.rightBranch.count; i++) {
        NSNumber* temp = self.rightBranch[i];
        int tempValue = [temp intValue];
        if (point == tempValue) {
            indexForRightBranch = i;
        }
    }
    
    for (int i = 0; i < self.leftBranch.count; i++) {
        NSNumber* temp = self.leftBranch[i];
        int tempValue = [temp intValue];
        if (point == tempValue) {
            indexForLeftBranch = i;
        }
    }
    
    
    NSArray* vacantPlaces = [NSArray arrayWithObjects:
                             self.rightBranch[indexForRightBranch - 1], self.rightBranch[indexForRightBranch + 1],
                             self.leftBranch[indexForLeftBranch - 1], self.leftBranch[indexForLeftBranch + 1], nil];
    return vacantPlaces;
    
}

- (void) chekPlaceForNotBusy:(NSInteger) pointer {
    NSArray* arrVacancy = [self seachVakantPlaceForPoint:pointer];
    self.findPlace = nil;
    self.findPlace = [[NSMutableArray alloc] init];
    for(NSNumber* number in arrVacancy) {
        int num = [number intValue];
        if (num != -1) {
            NSNumber* boxNumber = self.collectionBoxBusyForCheck[num];
            if ([boxNumber intValue] == -1) {
                [self.findPlace addObject:number];
            }
        }
    }
    //NSLog(@"For pointer %ld you find vacant place:\n%@", (long)pointer, self.findPlace);
}

- (void) seachVacantPlaceForCheker:(UIView*) view {
    int indexChecker = 0;
    
    for (UIView* checker in self.collectionCheckers) {
        if ([checker isEqual:view]) {
            break;
        }
        indexChecker++;
    }
    self.checker = indexChecker;
    
    //нумерация шашек не совпадает с нумерацией клеток, поэтому надо вычислить соответствующий номер клетки
    int indexBox = 0;
    
    for (NSNumber* num in self.collectionBoxBusyForCheck) {
        int numCheckInCollectionBox = [num intValue];
        if (indexChecker == numCheckInCollectionBox) {
            break;
        }
        indexBox++;
    }
    self.find = indexBox;
    
    //NSLog(@"checker #%d, numer box: %d",indexChecker, indexBox);
    [self chekPlaceForNotBusy:indexBox];
    //NSLog(@"Find place: %@", self.findPlace);
}

- (BOOL) isItVacantPlaceForCurentChess {
    //Проходим по найденному массиву вакантных мест и если расстояние до центра вакантного места и центра
    //перетаскиваемой вью меньше половины длины клетки, то делаем соответствующие изменения в массиве collectionCheckers,
    //возвращаем тру. Центрование будет проведено в методе touchesEnded в блоке if ([self isItVacantPlaceForCurentChess])
    CGFloat deltaX;
    CGFloat deltaY;
    CGFloat sizeView = self.movedView.frame.size.width;
    
    for(NSNumber* placeNumber in self.findPlace) {
        int place = [placeNumber intValue];
        UIView* viewPlace = [self.collectionBlackBox objectAtIndex:place];
        deltaX = viewPlace.center.x - self.movedView.center.x;
        deltaY = viewPlace.center.y - self.movedView.center.y;
        if (deltaX < 0) {
            deltaX = deltaX * (-1);
        }
        if (deltaY < 0) {
            deltaY = deltaY * (-1);
        }
        if (sizeView/2 > deltaX && sizeView/2 > deltaY) {
            self.findCenter = viewPlace.center;
            self.findBox = place;
            return YES;
        }
    }
    
    return NO;
}


@end
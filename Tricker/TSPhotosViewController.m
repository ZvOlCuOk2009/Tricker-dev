//
//  TSPhotosViewController.m
//  Tricker
//
//  Created by Mac on 01.12.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSPhotosViewController.h"
#import "TSCollectionViewCell.h"
#import "TSFireUser.h"
#import "TSFireImage.h"
#import "TSPhotoZoomViewController.h"
#import "UIAlertController+TSAlertController.h"
#import "TSReachability.h"
#import "TSAlertController.h"
#import "TSSVProgressHUD.h"
#import "TSTrickerPrefixHeader.pch"

@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface TSPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImagePickerController *picker;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) TSFireUser *fireUser;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray *urlPhotos;
@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) NSMutableArray *addPhotos;

@property (assign, nonatomic) CGSize collViewCellSize;
@property (assign, nonatomic) NSInteger progressHUD;
@property (assign, nonatomic) BOOL recognizer;

@end

@implementation TSPhotosViewController

static NSString * const reuseIdntifier = @"cell";
static NSString * const reuseIdntifierButton = @"cellButton";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Мои фото";
    
    self.ref = [[FIRDatabase database] reference];
    self.storageRef = [[FIRStorage storage] reference];
    
    self.photos = [NSMutableArray array];
    self.addPhotos = [NSMutableArray array];
    self.selectedPhotos = [NSMutableArray array];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_4) {
            self.collViewCellSize = kTSCollViewPhotoCell;
        } else if (IS_IPHONE_5) {
            self.collViewCellSize = kTSCollViewPhotoCell;
        } else if (IS_IPHONE_6) {
            self.collViewCellSize = kTSCollViewPhotoCell6;
        } else if (IS_IPHONE_6_PLUS) {
            self.collViewCellSize = kTSCollViewPhotoCell6plus;
        }
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (IS_IPAD_2) {
            self.collViewCellSize = kTSCollCellPhotosSizeIpad;
        } else if (IS_IPAD_PRO) {
            self.collViewCellSize = kTSCollCellPhotosSizeIpadPro;
        }
    }

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setImage:[UIImage imageNamed:@"back"]];
    [leftItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [leftItem setTarget:self];
    [leftItem setAction:@selector(cancelInteraction)];
    
    self.progressHUD = 0;
    self.recognizer = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[TSReachability sharedReachability] verificationInternetConnection]) {
        if (self.recognizerController == NO) {
            [self loadPhotos];
        }
        NSMutableArray *tempArray = nil;
        for (UIImage *firstImage in self.photos) {
            if ([firstImage isKindOfClass:[UIImage class]]) {
                if (!(firstImage.size.width == 40) && !(firstImage.size.height == 40)) {
                    UIImage *capImage = [UIImage imageNamed:@"photo-camera1"];
                    tempArray = [NSMutableArray array];
                    [tempArray insertObject:capImage atIndex:0];
                } else {
                    break;
                }
            }
        }
        
        if (tempArray) {
            [self.photos insertObject:[tempArray firstObject] atIndex:0];
        }
        
        for (id obj in self.photos) {
            if ([obj isKindOfClass:[NSString class]]) {
                [self.photos removeObject:obj];
                break;
            }
        }
        [self.collectionView reloadData];
    } else {
        TSAlertController *alertController =
        [TSAlertController noInternetConnection:@"Проверьте интернет соединение..."];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)loadPhotos
{
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        if (self.progressHUD == 0) {
            [TSSVProgressHUD showProgressHud];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (self.fireUser.photos) {
                    self.urlPhotos = self.fireUser.photos;
                } else {
                    self.urlPhotos = [NSMutableArray array];
                    NSString *cap = @"a";
                    [self.urlPhotos addObject:cap];
                    [self.photos addObject:cap];
                }
                if (self.fireUser.photos && [self.photos count] == 0) {
                    for (int i = 0; i < [self.fireUser.photos count]; i++) {
                        NSString *url = [self.fireUser.photos objectAtIndex:i];
                        if ([url isEqual:[NSNull null]]) {
                        } else {
                            if ([url length] > 1) {
                                UIImage *convertPhoto = [self photoWithPhoto:url];
                                [self.photos addObject:convertPhoto];
                            } else {
                                UIImage *capImage = [UIImage imageNamed:@"photo-camera1"];
                                [self.photos addObject:capImage];
                            }
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [TSSVProgressHUD dissmisProgressHud];
                });
            });
        }
    }];
}

- (void)cancelInteraction
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0]
                                          animated:YES];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (!parent) {
        if (self.recognizer == YES) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (NSDictionary *selectPhoto in self.selectedPhotos) {
                    NSData *currentData = [selectPhoto objectForKey:@"currentData"];
                    NSString *currentPath = [selectPhoto objectForKey:@"currentPath"];
                    
                    TSFireImage *fireImage = [[TSFireImage alloc] init];
                    [fireImage savePhotos:currentData byPath:currentPath photos:self.urlPhotos];
                    self.progressHUD = 1;
                }
            });
        }
    }
}

#pragma mark - compression photo

- (UIImage *)photoWithPhoto:(NSString *)url
{
    UIImage *photo = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    return photo;
}

#pragma mark - Action

- (IBAction)addPhotoActionButton:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Выберите фото"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self makePhoto];
                                                       }];
        
        UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self selectPhoto];
                                                       }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                       }];
        
        [alertController customizationAlertView:@"Выберите фото" byFont:20.f];
        
        [alertController addAction:camera];
        [alertController addAction:galery];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Выберите фото"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        NSInteger value = self.view.frame.size.width / 2;
        CGRect recr = CGRectMake(value / 2, self.view.frame.size.height / 4, value, value);
        UIView *view = [[UIView alloc] initWithFrame:recr];
        alertController.popoverPresentationController.sourceView = view;
        alertController.popoverPresentationController.sourceRect = view.frame;
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Камера"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self makePhoto];
                                                       }];
        
        UIAlertAction *galery = [UIAlertAction actionWithTitle:@"Галерея"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self selectPhoto];
                                                       }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Отменить"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        
        UIView *subview = alertController.view.subviews.firstObject;
        UIView *alertContentView = subview.subviews.firstObject;
        alertContentView.backgroundColor = YELLOW_COLOR;
        alertContentView.layer.cornerRadius = 10;
        alertController.view.tintColor = DARK_GRAY_COLOR;
        
        NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"Выберите фото"];
        [mutableAttrString addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:20.0]
                                  range:NSMakeRange(0, 13)];
        [alertController setValue:mutableAttrString forKey:@"attributedTitle"];
        
        [alertController addAction:camera];
        [alertController addAction:galery];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }    
}


- (void)makePhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)selectPhoto {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.progressHUD = 1;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photos/%lld.jpg", [FIRAuth auth].currentUser.uid,
                           (long long)([NSDate date].timeIntervalSince1970 * 1000.0)];
    
    NSDictionary *paramsSelectedPhoto = @{@"currentData":imageData, @"currentPath":imagePath};
    [self.selectedPhotos addObject:paramsSelectedPhoto];
    
    if ([self.addPhotos count] > 0) {
        [self.addPhotos removeAllObjects];
    }
    
    [self.addPhotos addObject:image];
    [self.photos addObjectsFromArray:self.addPhotos];
    [self.collectionView reloadData];
    
    //установка определителя для распознавания добавлены ли новые фото для сохранения в базу
    
    self.recognizer = YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdntifier
                                                                           forIndexPath:indexPath];
    NSInteger myIndexPaht = indexPath.item;
    UIImage *photo = [self.photos objectAtIndex:myIndexPaht];
    
    if (indexPath.row == 0) {
        TSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdntifierButton
                                                                               forIndexPath:indexPath];
        return cell;
    } else {
        cell.imageView.image = photo;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collViewCellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *capImage = [self.photos firstObject];
    if (capImage.size.width == 40 && capImage.size.height == 40) {
        [self.photos removeObjectAtIndex:0];
    }
    
    UIStoryboard *stotyboard = [UIStoryboard storyboardWithName:@"CardsStoryboard" bundle:[NSBundle mainBundle]];
    TSPhotoZoomViewController *controller =
    [stotyboard instantiateViewControllerWithIdentifier:@"TSPhotoZoomViewController"];
    controller.photos = self.photos;
    controller.hiddenDeleteButton = NO;
    controller.currentPage = indexPath.item - 1;
    controller.fireUser = self.fireUser;
    controller.addPhotos = self.addPhotos;
    self.recognizerController = YES;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end

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
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

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

@property (assign, nonatomic) NSInteger regognizerMark;
@property (assign, nonatomic) NSInteger progressHUD;
@property (assign, nonatomic) NSInteger counterDeleteCap;
@property (assign, nonatomic) BOOL regognizer;

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

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setImage:[UIImage imageNamed:@"back"]];
    [leftItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [leftItem setTarget:self];
    [leftItem setAction:@selector(cancelInteraction)];
    
    self.progressHUD = 0;
    self.regognizerMark = 0;
    self.counterDeleteCap = 0;
    self.regognizer = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPhotos];
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
            [self showProgressHud];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if (self.fireUser.photos) {
                    self.urlPhotos = self.fireUser.photos;
                } else {
                    self.urlPhotos = [NSMutableArray array];
                    
                    NSString *cap = @"a";
                    [self.urlPhotos addObject:cap];
                    [self.photos addObject:cap];
                }
                
                if (self.fireUser.photos) {
                    
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
                    [self dissmisProgressHud];
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
        if (self.regognizer == YES) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                dispatch_sync(dispatch_get_main_queue(), ^{
            
                    for (NSDictionary *selectPhoto in self.selectedPhotos) {
                        NSData *currentData = [selectPhoto objectForKey:@"currentData"];
                        NSString *currentPath = [selectPhoto objectForKey:@"currentPath"];
                        
                        [TSFireImage savePhotos:currentData byPath:currentPath photos:self.urlPhotos];
                        self.progressHUD = 1;
                    }
                });
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
    
    [alertController customizationAlertView:@"Выберите фото" byLength:13 byFont:20.f];
    
    [alertController addAction:camera];
    [alertController addAction:galery];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
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
    
    self.regognizer = YES;
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
    return CGSizeMake(79, 79);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.counterDeleteCap == 0) {
        
        [self.photos removeObjectAtIndex:0];
        ++self.counterDeleteCap;
    }
    
    UIStoryboard *stotyboard = [UIStoryboard storyboardWithName:@"CardsStoryboard" bundle:[NSBundle mainBundle]];
    TSPhotoZoomViewController *controller =
    [stotyboard instantiateViewControllerWithIdentifier:@"TSPhotoZoomViewController"];
    
    controller.photos = self.photos;
    controller.hiddenDeleteButton = NO;
    controller.currentPage = indexPath.item;
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


#pragma mark - ProgressHUD


- (void)showProgressHud
{
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
    [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
}


- (void)dissmisProgressHud
{
    [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end

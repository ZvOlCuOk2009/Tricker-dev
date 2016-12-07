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
#import "TSTrickerPrefixHeader.pch"

@import Firebase;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImagePickerController *picker;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) UIImageView *chackMark;

@property (assign, nonatomic) NSInteger regognizerMark;
@property (assign, nonatomic) BOOL regognizer;
@property (assign, nonatomic) BOOL mark;

@end

@implementation TSPhotosViewController

static NSString * const reuseIdntifier = @"cell";
static NSString * const reuseIdntifierButton = @"cellButton";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Мои фото";
    
    self.ref = [[FIRDatabase database] reference];
    
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        
        if (self.fireUser.photos) {
            self.photos = self.fireUser.photos;
        } else {
            self.photos = [NSMutableArray array];
            
            NSString *cap = @"";
            [self.photos addObject:cap];
        }
        [self.collectionView reloadData];
    }];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setImage:[UIImage imageNamed:@"back"]];
    [leftItem setTintColor:DARK_GRAY_COLOR];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [leftItem setTarget:self];
    [leftItem setAction:@selector(cancelInteraction)];
    
    UIImage *chackMarkImage = [UIImage imageNamed:@"check-mark"];
    self.chackMark = [[UIImageView alloc] initWithImage:chackMarkImage];
    self.chackMark.frame = CGRectMake(50, 50, 25, 25);
    
    self.regognizerMark = 0;
    self.regognizer = NO;
    self.mark = NO;
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
            [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid] child:@"photos"] setValue:self.photos];
        }
    }
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
    
    UIView *subview = alertController.view.subviews.firstObject;
    UIView *alertContentView = subview.subviews.firstObject;
    alertContentView.backgroundColor = YELLOW_COLOR;
    alertContentView.layer.cornerRadius = 10;
    alertController.view.tintColor = DARK_GRAY_COLOR;
    
    
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] initWithString:@"Выберите фото"];
    [mutableAttrString addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.f]
                  range:NSMakeRange(0, 13)];
    [alertController setValue:mutableAttrString forKey:@"attributedTitle"];
    
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
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    //сжатие и добавление в массив фото
    
    CGSize newSize = CGSizeMake(300, 300);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *dataImage = UIImagePNGRepresentation(newImage);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    [self.photos addObject:stringImage];
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
    NSString *photo = [self.photos objectAtIndex:indexPath.item];
    
    if (indexPath.row == 0) {
        TSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdntifierButton
                                                                               forIndexPath:indexPath];
        return cell;

    } else {
        
        //раскодирование изображение перед отображением
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:photo
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *convertImage = [UIImage imageWithData:data];
        cell.imageView.image = convertImage;
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
    
    TSCollectionViewCell *cell = (TSCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSArray *object = [cell subviews];
    
    UIImageView *photo = [object firstObject];
    
    if (self.mark == NO) {
        
        [photo addSubview:self.chackMark];
        self.mark = YES;
        
    } else {
        
        self.chackMark = nil;
        self.mark = NO;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end

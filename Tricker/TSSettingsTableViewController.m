//
//  TSSettingsTableViewController.m
//  Tricker
//
//  Created by Mac on 15.11.16.
//  Copyright © 2016 Mac. All rights reserved.
//

#import "TSSettingsTableViewController.h"
#import "TSSocialNetworkLoginViewController.h"
#import "TSFacebookManager.h"
#import "TSFireUser.h"
#import "TSTrickerPrefixHeader.pch"

#import <SVProgressHUD.h>

NSString * const UpdateParametersNotification = @"UpdateParametersNotification";

@import Firebase;
@import FirebaseAuth;
@import FirebaseDatabase;

@interface TSSettingsTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *manButton;
@property (strong, nonatomic) IBOutlet UIButton *womanButton;

@property (strong, nonatomic) IBOutlet UILabel *minAgeUnknownPeopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxAgeUnknownPeopleLabel;
@property (strong, nonatomic) IBOutlet UILabel *growthLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightLabel;
@property (strong, nonatomic) IBOutlet UILabel *targetLabel;
@property (strong, nonatomic) IBOutlet UILabel *figureLabel;
@property (strong, nonatomic) IBOutlet UILabel *eyesLabel;
@property (strong, nonatomic) IBOutlet UILabel *hairLabel;
@property (strong, nonatomic) IBOutlet UILabel *relationsLabel;
@property (strong, nonatomic) IBOutlet UILabel *childsLabel;
@property (strong, nonatomic) IBOutlet UILabel *earningsLabel;
@property (strong, nonatomic) IBOutlet UILabel *educationLabel;
@property (strong, nonatomic) IBOutlet UILabel *housingLabel;
@property (strong, nonatomic) IBOutlet UILabel *automobileLabel;
@property (strong, nonatomic) IBOutlet UILabel *smokingLabel;
@property (strong, nonatomic) IBOutlet UILabel *alcoholeLabel;

@property (strong, nonatomic) UIImage *checkbox;
@property (strong, nonatomic) UIImage *checked;

@property (strong, nonatomic) NSArray *labels;

@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) TSFireUser *fireUser;

@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (strong, nonatomic) NSMutableArray *dataSourseAge;
@property (strong, nonatomic) NSMutableArray *dataSourseGrowth;
@property (strong, nonatomic) NSMutableArray *dataSourseWeight;
@property (strong, nonatomic) NSArray *dataSourseTarget;
@property (strong, nonatomic) NSArray *dataSourseFigure;
@property (strong, nonatomic) NSArray *dataSourseEyes;
@property (strong, nonatomic) NSArray *dataSourseHair;
@property (strong, nonatomic) NSArray *dataSourseRelations;
@property (strong, nonatomic) NSArray *dataSourseChilds;
@property (strong, nonatomic) NSArray *dataSourseEarnings;
@property (strong, nonatomic) NSArray *dataSourseEducation;
@property (strong, nonatomic) NSArray *dataSourseHousing;
@property (strong, nonatomic) NSArray *dataSourseAutomobile;
@property (strong, nonatomic) NSArray *dataSourseSmoking;
@property (strong, nonatomic) NSArray *dataSourseAlcohole;

@property (strong, nonatomic) NSMutableDictionary *characteristicsUser;
@property (strong, nonatomic) NSArray *allKeysParameters;
@property (strong, nonatomic) NSString *selectPosition;
@property (strong, nonatomic) NSString *curentGender;

@property (assign, nonatomic) NSInteger selectedRowInComponent;
@property (assign, nonatomic) NSInteger tagSelectCell;

@property (assign, nonatomic) BOOL statePickerView;
@property (assign, nonatomic) BOOL stateButtonBoy;
@property (assign, nonatomic) BOOL stateButtonGirl;

@end

@implementation TSSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    self.tableView.backgroundView = imageView;
    
    [self.tableView setSeparatorColor:DARK_GRAY_COLOR];
    
    self.ref = [[FIRDatabase database] reference];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        self.fireUser = [TSFireUser initWithSnapshot:snapshot];
        [self configureController];
        [self setDataUser];
    }];
    
}


#pragma mark - configure the controller


- (void)configureController
{

    [self setDataUser];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain
                                                      target:self action:@selector(doneAction:)];
    
    self.statePickerView = NO;
    
    //создание массивов с источниками данных для UIPickerView
    self.dataSourseAge = [NSMutableArray array];
    self.dataSourseGrowth = [NSMutableArray array];
    self.dataSourseWeight = [NSMutableArray array];
    
    self.characteristicsUser = [NSMutableDictionary dictionary];
    
    for (int i = 18; i < 71; i++) {
        NSString *row = [NSString stringWithFormat:@"%d", i];
        [self.dataSourseAge addObject:row];
    }
    
    
    for (int i = 140; i < 221; i++) {
        NSString *row = [NSString stringWithFormat:@"%d", i];
        [self.dataSourseGrowth addObject:row];
    }
    
    for (int i = 40; i < 151; i++) {
        NSString *row = [NSString stringWithFormat:@"%d", i];
        [self.dataSourseWeight addObject:row];
    }
    
    self.dataSourseTarget = @[@"Дружба и переписка", @"Флирт", @"Секс", @"Романтические отношения", @"Создание семьи", @"Отменить"];
    self.dataSourseFigure = @[@"Спортивная", @"Стройная", @"Пара лишних кило", @"Полная", @"Отменить"];
    self.dataSourseEyes = @[@"Карие", @"Серые", @"Голубые", @"Зеленые", @"Отменить"];
    self.dataSourseHair = @[@"Блонд", @"Руссые", @"Шатен", @"Брюнет", @"Черные", @"Седые", @"Cбриты", @"Отменить"];
    self.dataSourseRelations = @[@"Свободен", @"Занят", @"Ничего серьйозного", @"Отменить"];
    self.dataSourseChilds = @[@"Есть", @"Есть хочу ещё", @"Нет, когда нибудь", @"Нет и не хочу", @"Отменить"];
    self.dataSourseEarnings = @[@"Обеспечен", @"Средний", @"Не большой стабильный", @"Отменить"];
    self.dataSourseEducation = @[@"Несколько высших", @"Высшее",@"Не полное высшее", @"Среднее - техническое",@"Студент", @"Отменить"];
    self.dataSourseHousing = @[@"Свой дом", @"Своя квартира", @"Снимаю квартиру", @"Снимаю комнату", @"Живу с родителями", @"Отменить"];
    self.dataSourseAutomobile = @[@"Есть", @"Нет", @"Отменить"];
    self.dataSourseSmoking = @[@"Курю каждый день", @"Курю редко", @"Не курю", @"Не курю и не терплю курящих", @"Отменить"];
    self.dataSourseAlcohole = @[ @"Иногда выпиваю в компании", @"Не употребляю", @"Всегда готов!", @"Отменить"];

    self.navigationController.navigationBar.tintColor = DARK_GRAY_COLOR;
    
    //создание массива лейблов
    
    self.labels = @[self.minAgeUnknownPeopleLabel, self.maxAgeUnknownPeopleLabel, self.growthLabel, self.weightLabel, self.targetLabel, self.figureLabel, self.eyesLabel, self.hairLabel, self.relationsLabel, self.childsLabel, self.earningsLabel, self.educationLabel, self.housingLabel, self.automobileLabel, self.smokingLabel, self.alcoholeLabel];
        
    self.checked = [UIImage imageNamed:@"checked"];
    self.checkbox = [UIImage imageNamed:@"check-box-empty"];
    
}


- (void)setDataUser
{
    
    //получение модели пользователя из базы
    
    [SVProgressHUD show];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:YELLOW_COLOR];
    [SVProgressHUD setForegroundColor:DARK_GRAY_COLOR];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSURL *urlPhoto = [NSURL URLWithString:self.fireUser.photoURL];
        
        UIImage *imagePhoto = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlPhoto]];
        
        //проверка является ли изображение url или оно кодировано
        if (urlPhoto && urlPhoto.scheme && urlPhoto.host) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.avatarImageView.image = imagePhoto;
                [self setParametrUser:self.fireUser];
                
                [SVProgressHUD dismiss];
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSData *data = [[NSData alloc] initWithBase64EncodedString:self.fireUser.photoURL options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *convertImage = [UIImage imageWithData:data];
                self.avatarImageView.image = convertImage;
                [self setParametrUser:self.fireUser];
                
                [SVProgressHUD dismiss];
            });
            
        }
        
        self.avatarImageView.layer.cornerRadius = 40;
        self.avatarImageView.clipsToBounds = YES;
        
    });
    
}


- (void)setParametrUser:(TSFireUser *)fireUser
{
    //очистка всех лейблов перед загрузкой новых данных
    for (UILabel *label in self.self.labels) {
        label.text = @"";
    }
    
    //установка возраста
    if (fireUser.age) {
        
        self.ageLabel.text = fireUser.age;
    }
    
    self.nameLabel.text = fireUser.displayName;
    
    
    //установка параметров из базы если уже есть данные
    if (fireUser.parameters) {
        

        self.allKeysParameters = [fireUser.parameters allKeys];
        
        for (NSString *key in self.allKeysParameters) {
            for (UILabel *label in self.labels) {
                NSString *tag = [NSString stringWithFormat:@"%ld", (long)label.tag];
                NSString *shortKey = [key substringFromIndex:3];
                if ([shortKey isEqualToString:tag]) {
                    label.text = [fireUser.parameters objectForKey:key];
                }
            }
            
            //установка изображения кнопок если выбранна позиция
            
            NSString *shortKey = [key substringFromIndex:3];
            
            if ([shortKey isEqualToString:@"1"]) {

                NSString *searchGender = [fireUser.parameters objectForKey:key];
                NSArray *components = [searchGender componentsSeparatedByString:@" "];
                
                if ([components count] > 1) {
                    self.stateButtonBoy = YES;
                    self.stateButtonGirl = YES;
                    [self.manButton setImage:self.checked forState:UIControlStateNormal];
                    [self.womanButton setImage:self.checked forState:UIControlStateNormal];
                    
                } else {
                    
                    if ([[components objectAtIndex:0] isEqualToString:@"man"]) {
                        self.stateButtonBoy = YES;
                        [self.manButton setImage:self.checked forState:UIControlStateNormal];
                        [self.womanButton setImage:self.checkbox forState:UIControlStateNormal];
                    } else if ([[components objectAtIndex:0] isEqualToString:@"woman"]) {
                        self.stateButtonGirl = YES;
                        [self.womanButton setImage:self.checked forState:UIControlStateNormal];
                        [self.manButton setImage:self.checkbox forState:UIControlStateNormal];
                    }
                }
            }
            //установка даты для поиска пользователей
            
            if ([shortKey isEqualToString:@"2"]) {
                NSString *ageRange = [fireUser.parameters objectForKey:key];
                NSArray *components = [ageRange componentsSeparatedByString:@" "];
                if ([components count] > 1) {
                    self.minAgeUnknownPeopleLabel.text = [components objectAtIndex:0];
                    self.maxAgeUnknownPeopleLabel.text = [components objectAtIndex:1];
                }
            }
        }
    }
}


#pragma mark - Action


- (IBAction)actionBoyButton:(id)sender
{
    
    [self updateCharacteristicUser];
    
    if (self.stateButtonBoy == NO) {
        [sender setImage:self.checked forState:UIControlStateNormal];
        self.stateButtonBoy = YES;
    } else {
        [sender setImage:self.checkbox forState:UIControlStateNormal];
        self.stateButtonBoy = NO;
        [self.characteristicsUser removeObjectForKey:@"key1"];
    }
    
}


- (IBAction)actionGirlButton:(id)sender
{
    
    [self updateCharacteristicUser];
    
    if (self.stateButtonGirl == NO) {
        [sender setImage:self.checked forState:UIControlStateNormal];
        self.stateButtonGirl = YES;
    } else {
        [sender setImage:self.checkbox forState:UIControlStateNormal];
        self.stateButtonGirl = NO;
        [self.characteristicsUser removeObjectForKey:@"key1"];
    }

}


- (void)updateCharacteristicUser
{
    if (self.fireUser.parameters) {
        self.characteristicsUser = self.fireUser.parameters;
    }
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        return 100;
    }
    
    if (indexPath.row == 20)
    {
        return kHeightCellButtonSaveAndOut;
    }
    
    return kHeightCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3 && self.statePickerView == NO)
    {
        self.selectedRowInComponent = 2;
        self.tagSelectCell = 1;
        [self createdUipickerView:1];
    } else if (indexPath.row == 4 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 3;
        [self createdUipickerView:2];
    } else if (indexPath.row == 6 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 4;
        [self createdUipickerView:3];
    } else if (indexPath.row == 7 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 5;
        [self createdUipickerView:4];
    } else if (indexPath.row == 8 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 6;
        [self createdUipickerView:5];
    } else if (indexPath.row == 9 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 7;
        [self createdUipickerView:6];
    } else if (indexPath.row == 10 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 8;
        [self createdUipickerView:7];
    } else if (indexPath.row == 12 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 9;
        [self createdUipickerView:8];
    } else if (indexPath.row == 13 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 10;
        [self createdUipickerView:9];
    } else if (indexPath.row == 14 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 11;
        [self createdUipickerView:10];
    } else if (indexPath.row == 15 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 12;
        [self createdUipickerView:11];
    } else if (indexPath.row == 16 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 13;
        [self createdUipickerView:12];
    } else if (indexPath.row == 17 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 14;
        [self createdUipickerView:13];
    } else if (indexPath.row == 18 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 15;
        [self createdUipickerView:14];
    } else if (indexPath.row == 19 && self.statePickerView == NO) {
        self.selectedRowInComponent = 1;
        self.tagSelectCell = 16;
        [self createdUipickerView:15];
    }
    
}


- (void)createdUipickerView:(NSInteger)tag
{
    //создание UIPickerView
    self.pickerView = [[UIPickerView alloc] init];
    [self.pickerView setValue:DARK_GRAY_COLOR forKey:@"textColor"];
    self.pickerView.backgroundColor = LIGHT_YELLOW_COLOR;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.tag = tag;
    
    if (self.pickerView.superview == nil)
    {
        [self.view.window addSubview:self.pickerView];
        self.view.window.backgroundColor = [UIColor whiteColor];
        
        //изменение фрейма экрана и всплыте UIPickerView
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        
        self.pickerView.frame = startRect;
        
        CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height - 49,
                                       self.view.frame.size.width, self.pickerView.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        [UIView setAnimationDelegate:self];
        
        self.pickerView.frame = pickerRect;
        
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.pickerView.frame.size.height;
        self.tableView.frame = newFrame;
        [UIView commitAnimations];
        
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
    }
    
    self.statePickerView = YES;
}


- (void)doneAction:(UIBarButtonItem *)doneButton
{
    
    //скрытие UIPickerView
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect endFrame = self.pickerView.frame;
    endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    
    self.pickerView.frame = endFrame;
    [UIView commitAnimations];
    
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height += self.pickerView.frame.size.height;
    self.tableView.frame = newFrame;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationItem setRightBarButtonItems:nil animated:YES];

    self.statePickerView = NO;
    
    if (self.fireUser.parameters) {
        self.characteristicsUser = self.fireUser.parameters;
    } else {
        self.characteristicsUser = [NSMutableDictionary dictionary];
    }
    
    //добавление параметров в словарь для последующего сохранения в базу
    //определение количества компонентов в UIPickerView
    
    if (self.selectedRowInComponent == 1) {
        
        self.selectPosition = [self pickerView:self.pickerView
                                   titleForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
        
        for (UILabel *label in self.labels) {
            
            if (label.tag == self.tagSelectCell && ![self.selectPosition isEqualToString:@"Отменить"]) {
                
                if (self.tagSelectCell == 4) {
                    [self setTextLabelTag:label selectPosition:self.selectPosition];
                } else if (self.tagSelectCell == 5) {
                    [self setTextLabelTag:label selectPosition:self.selectPosition];
                } else {
                    [self setTextLabelTag:label selectPosition:self.selectPosition];
                }
            }
        }
        
    } else if (self.selectedRowInComponent == 2) {
        
        
        NSString *minAge = [self pickerView:self.pickerView
                                         titleForRow:[self.pickerView selectedRowInComponent:0] forComponent:0];
        NSString *maxAge = [self pickerView:self.pickerView
                                          titleForRow:[self.pickerView selectedRowInComponent:1] forComponent:0];
        
        NSString *selectAge = [NSString stringWithFormat:@"%@ %@", minAge, maxAge];
        
        self.minAgeUnknownPeopleLabel.text = minAge;
        self.maxAgeUnknownPeopleLabel.text = maxAge;
        
        NSString *key = @"key2";
        
        [self.characteristicsUser setObject:selectAge forKey:key];

    }

    //обновление словаря с данными
    if (self.fireUser.parameters) {
        
        NSString *key = [NSString stringWithFormat:@"key%ld", (long)self.tagSelectCell];
        
        if (![self.selectPosition isEqualToString:@"Отменить"]) {
            
            if (self.tagSelectCell == 4) {
                [self updateDictionaryValue:self.selectPosition byKey:key];
            } else if (self.tagSelectCell == 5) {
                [self updateDictionaryValue:self.selectPosition byKey:key];
            } else {
                [self updateDictionaryValue:self.selectPosition byKey:key];
            }
        } else {
            
            [self.characteristicsUser removeObjectForKey:key];
        }
    }
}


- (void)slideDownDidStop
{
    //удаление UIPickerView
    [self.pickerView removeFromSuperview];
}


//метод для добавления префиксов см и кг


- (void)setTextLabelTag:(UILabel *)label selectPosition:(NSString *)string
{
    
    NSString *valueText = nil;
    
    if (label.tag == 4) {
        valueText = [NSString stringWithFormat:@"%@ см", string];
    } else if (label.tag == 5) {
        valueText = [NSString stringWithFormat:@"%@ кг", string];
    } else {
        valueText = string;
    }
    
    label.text = valueText;
    NSString *key = [NSString stringWithFormat:@"key%ld", (long)self.tagSelectCell];
    [self.characteristicsUser setObject:valueText forKey:key];
    
}


//методы обновления словаря данных


- (void)updateDictionaryValue:(NSString *)string byKey:(NSString *)key
{
 
    NSString *text = nil;
    
    if (self.tagSelectCell == 4) {
        text = [NSString stringWithFormat:@"%@ см", string];
    } else if (self.tagSelectCell == 5) {
        text = [NSString stringWithFormat:@"%@ кг", string];
    } else {
        text = string;
    }
    
    NSMutableDictionary *updateCharacteristicsUser = (NSMutableDictionary *)self.fireUser.parameters;
    [updateCharacteristicsUser setValue:text forKey:key];
    self.characteristicsUser = [NSMutableDictionary dictionaryWithDictionary:updateCharacteristicsUser];
    
}


#pragma mark - UIPickerViewDataSource


- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    
    switch (thePickerView.tag) {
        case 1:
            return self.dataSourseAge.count;
            break;
        case 2:
            return self.dataSourseTarget.count;
            break;
        case 3:
            return self.dataSourseGrowth.count;
            break;
        case 4:
            return self.dataSourseWeight.count;
            break;
        case 5:
            return self.dataSourseFigure.count;
            break;
        case 6:
            return self.dataSourseEyes.count;
            break;
        case 7:
            return self.dataSourseHair.count;
            break;
        case 8:
            return self.dataSourseRelations.count;
            break;
        case 9:
            return self.dataSourseChilds.count;
            break;
        case 10:
            return self.dataSourseEarnings.count;
            break;
        case 11:
            return self.dataSourseEducation.count;
            break;
        case 12:
            return self.dataSourseHousing.count;
            break;
        case 13:
            return self.dataSourseAutomobile.count;
            break;
        case 14:
            return self.dataSourseSmoking.count;
            break;
        case 15:
            return self.dataSourseAlcohole.count;
            break;
        default:
            return 0;
            break;
    }
    
}


- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    switch (thePickerView.tag) {
        case 1:
            return [self.dataSourseAge objectAtIndex:row];
            break;
        case 2:
            return [self.dataSourseTarget objectAtIndex:row];
            break;
        case 3:
            return [self.dataSourseGrowth objectAtIndex:row];
            break;
        case 4:
            return [self.dataSourseWeight objectAtIndex:row];
            break;
        case 5:
            return [self.dataSourseFigure objectAtIndex:row];
            break;
        case 6:
            return [self.dataSourseEyes objectAtIndex:row];
            break;
        case 7:
            return [self.dataSourseHair objectAtIndex:row];
            break;
        case 8:
            return [self.dataSourseRelations objectAtIndex:row];
            break;
        case 9:
            return [self.dataSourseChilds objectAtIndex:row];
            break;
        case 10:
            return [self.dataSourseEarnings objectAtIndex:row];
            break;
        case 11:
            return [self.dataSourseEducation objectAtIndex:row];
            break;
        case 12:
            return [self.dataSourseHousing objectAtIndex:row];
            break;
        case 13:
            return [self.dataSourseAutomobile objectAtIndex:row];
            break;
        case 14:
            return [self.dataSourseSmoking objectAtIndex:row];
            break;
        case 15:
            return [self.dataSourseAlcohole objectAtIndex:row];
            break;
        default:
            return 0;
            break;
    }
    
}


#pragma mark - UIPickerViewDelegate


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.selectedRowInComponent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark - update parameters


- (IBAction)logOutAtionButton:(id)sender
{
    //добавление параметра поиска пола
    
    NSMutableString *searchForGender = nil;
    
    [self updateCharacteristicUser];
    
    if (self.stateButtonBoy == YES) {
        searchForGender = [NSMutableString stringWithString:@"man"];
        [self.characteristicsUser setObject:searchForGender forKey:@"key1"];
    }
    
    if (self.stateButtonGirl == YES) {
        if (!searchForGender) {
            searchForGender = [NSMutableString stringWithString:@"woman"];
        } else {
            [searchForGender appendString:@" woman"];
        }
        
        [self.characteristicsUser setObject:searchForGender forKey:@"key1"];
    }
    
    if (self.stateButtonBoy == YES && self.stateButtonGirl == YES) {
        searchForGender = [NSMutableString stringWithString:@"man woman"];
        [self.characteristicsUser setObject:searchForGender forKey:@"key1"];
    }
    
    
    [[[[[self.ref child:@"dataBase"] child:@"users"] child:self.fireUser.uid]
      child:@"parameters"] setValue:self.characteristicsUser];
    
    //перезагрузка интерфейса в момент сохранения новых данных
    [self setDataUser];
    
}

@end

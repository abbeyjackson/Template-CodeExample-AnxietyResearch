//
//  ViewController.m
//  AnxietyResearch
//
//  Created by Abegael Jackson on 2015-07-10.
//  Copyright (c) 2015 Abbey Jackson. All rights reserved.
//

#import "ViewController.h"
#import <ResearchKit/ResearchKit.h>

@interface ViewController ()<ORKTaskViewControllerDelegate>
@property (strong, nonatomic) ORKOrderedTask *consentTask;
@property (strong, nonatomic) ORKOrderedTask *surveyTask;
@property (strong, nonatomic) ORKOrderedTask *spatialMemoryTask;
@property (strong, nonatomic) ORKOrderedTask *fingerTappingTask;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showConsent];
    [self showSurvey];
    [self showSpatialSpanMemoryTask];
    [self showFingerTappingTask];
}



-(void)showConsent{
    NSString *resource = [[NSBundle mainBundle] pathForResource:@"ConsentText" ofType:@"json"];
    NSData *consentData = [NSData dataWithContentsOfFile:resource];
    NSDictionary *parsedConsentData = [NSJSONSerialization JSONObjectWithData:consentData options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *sectionDataParsedFromInputFile = [parsedConsentData objectForKey:@"sections"];
    
    NSMutableArray *consentSections = [NSMutableArray new];
    for (NSDictionary *sectionDictionary in sectionDataParsedFromInputFile) {
        
        ORKConsentSectionType sectionType = [[sectionDictionary objectForKey:@"sectionType"] integerValue];
        NSString *title = [sectionDictionary objectForKey:@"sectionTitle"];
        NSString *summary = [sectionDictionary objectForKey:@"sectionSummary"];
        NSString *detail = [sectionDictionary objectForKey:@"sectionDetail"];
        
        ORKConsentSection *section = [[ORKConsentSection alloc] initWithType:sectionType];
        section.title = title;
        section.summary = summary;
        section.htmlContent = detail;
        
        ORKConsentSection *consentSection = section;
        [consentSections addObject:consentSection];
    }
    
    ORKConsentSection *introSection = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOnlyInDocument];
    introSection.title = @"Intro Language";
    introSection.htmlContent = @"This will only be shown in the consent document because this sectionType is map to ORKConsentSectionTypeOnlyInDocument. A consent document can include many sections with type ORKConsentSectionTypeOnlyInDocument. In this document there is a ORKConsentSectionTypeOnlyInDocument section as an intro and one as a closing section";
    
    [consentSections insertObject:introSection atIndex:0];
    
    
    ORKConsentSection *closingSection = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOnlyInDocument];
    closingSection.title = @"Additional Terms";
    closingSection.htmlContent = @"Adding a ORKConsentSectionTypeOnlyInDocument at the end of a consent can be helpful to include any additional legal or related information.";
    [consentSections addObject:closingSection];
    
    
    ORKConsentDocument *consentDocument = [ORKConsentDocument new];
    consentDocument.title = @"Demo Consent";
    consentDocument.sections = consentSections;
    
    ORKConsentSignature *signature = [ORKConsentSignature new];
    consentDocument.signatures = [NSArray arrayWithObject:signature];
    
    
    ORKVisualConsentStep *visualConsentStep = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visualConsentStep" document:consentDocument];
    
    
    ORKConsentReviewStep *consentReviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consentReviewStep" signature:consentDocument.signatures.firstObject inDocument:consentDocument];
    consentReviewStep.text = @"Review Consent!";
    consentReviewStep.reasonForConsent = @"I confirm that I consent to join this study";
    
    
    self.consentTask =  [[ORKOrderedTask alloc] initWithIdentifier:@"consent" steps:@[visualConsentStep, consentReviewStep]];

}


-(void)showSurvey{
    ORKInstructionStep *instructionStep = [[ORKInstructionStep alloc]initWithIdentifier:@"IntroStep"];
    instructionStep.title = @"Selection Survey";
    instructionStep.text = @"This survey helps us understand your eligibility for the anxiety study";
    
    
    ORKFormStep *personalInfoStep = [[ORKFormStep alloc]initWithIdentifier:@"PersonalInfoStep" title:@"Your Information" text:@"Here we will collect basic personal information"];
    NSMutableArray *basicItems = [NSMutableArray new];
    
    ORKTextAnswerFormat *nameAnswerFormat = [[ORKTextAnswerFormat alloc]initWithMaximumLength:20];
    nameAnswerFormat.multipleLines = NO;
    ORKFormItem *nameItem = [[ORKFormItem alloc]initWithIdentifier:@"QuestionItem" text:@"What is your name?" answerFormat:nameAnswerFormat];
    //    ORKQuestionStep *nameQuestionStep = [ORKQuestionStep questionStepWithIdentifier:@"QuestionStep" title:@"What is your name?" answer:nameAnswerFormat];
    [basicItems addObject:nameItem];
    
    HKCharacteristicType *genderAnswerHKType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    ORKAnswerFormat *genderFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:genderAnswerHKType];
    ORKFormItem *genderItem = [[ORKFormItem alloc]initWithIdentifier:@"GenderItem" text:@"Gender" answerFormat:genderFormat];
    [basicItems addObject:genderItem];
    
    ORKNumericAnswerFormat *ageAnswerFormat = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years old"];
    ageAnswerFormat.minimum = @(18);
    ageAnswerFormat.maximum = @(100);
    ORKFormItem *ageItem = [[ORKFormItem alloc]initWithIdentifier:@"AgeItem" text:@"How old are you?" answerFormat:ageAnswerFormat];
    //    ORKQuestionStep *birthYearQuestionStep = [ORKQuestionStep questionStepWithIdentifier:@"BirthYear" title:@"What year were you born in?" answer:birthYearAnswerFormat];
    [basicItems addObject:ageItem];
    
    ORKFormItem *basicInfoSeparator = [[ORKFormItem alloc]initWithSectionTitle:@"Basic Information"];
    [basicItems addObject:basicInfoSeparator];
    
    HKCharacteristicType *bloodTypeHKType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
    ORKAnswerFormat *bloodTypeFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:bloodTypeHKType];
    ORKFormItem *bloodTypeItem = [[ORKFormItem alloc]initWithIdentifier:@"BloodType" text:@"What is your blood type?" answerFormat:bloodTypeFormat];
    [basicItems addObject:bloodTypeItem];
    
    HKCharacteristicType *dateOfBirthType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    ORKAnswerFormat *dateOfBirthFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:dateOfBirthType];
    ORKFormItem *dateOfBirthItem = [[ORKFormItem alloc]initWithIdentifier:@"DateOfBirth" text:@"What is your date of birth?" answerFormat:dateOfBirthFormat];
    [basicItems addObject:dateOfBirthItem];
    
    personalInfoStep.formItems = basicItems;
    
    
    ORKFormStep *anxietyInfoStep = [[ORKFormStep alloc]initWithIdentifier:@"AnxietyInfoStep" title:@"Anxiety Survey" text:@"Here we will collect basic information about your anxiety"];
    NSMutableArray *anxietyItems = [NSMutableArray new];
    
    ORKAnswerFormat *hasAnxietyFormat = [ORKAnswerFormat booleanAnswerFormat];
    ORKFormItem *hasAnxietyItem = [[ORKFormItem alloc]initWithIdentifier:@"HasAnxiety" text:@"Do you have anxiety?" answerFormat:hasAnxietyFormat];
    [anxietyItems addObject:hasAnxietyItem];
    
    ORKAnswerFormat *anxietyScaleFormat = [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10 minimumValue:0 defaultValue:5 step:1 vertical:NO maximumValueDescription:@"Unbearable" minimumValueDescription:@"No Anxiety"];
    ORKFormItem *anxietyScaleItem = [[ORKFormItem alloc]initWithIdentifier:@"AnxietyScale" text:@"On a scale of 0 to 10, how do you rate your anxiety on a normal day?" answerFormat:anxietyScaleFormat];
    [anxietyItems addObject:anxietyScaleItem];
    
    anxietyInfoStep.formItems = anxietyItems;
    
    
    ORKFormStep *sleepInfoStep = [[ORKFormStep alloc]initWithIdentifier:@"SleepInfoStep" title:@"Sleep Survey" text:@"Here we will collect basic information about your sleep"];
    NSMutableArray *sleepItems = [NSMutableArray new];
    
    ORKImageChoice *badChoice = [ORKImageChoice choiceWithNormalImage:[UIImage imageNamed:@"Sad.png"] selectedImage:[UIImage imageNamed:@"Sad.png"] text:@"Bad" value:@"Bad"];
    ORKImageChoice *neutralChoice = [ORKImageChoice choiceWithNormalImage:[UIImage imageNamed:@"Neutral.png"] selectedImage:[UIImage imageNamed:@"Neutral.png"] text:@"Okay" value:@"Okay"];
    ORKImageChoice *goodChoice = [ORKImageChoice choiceWithNormalImage:[UIImage imageNamed:@"Happy.png"] selectedImage:[UIImage imageNamed:@"Happy.png"] text:@"Good" value:@"Good"];
    NSArray *emoticonArray = @[badChoice, neutralChoice, goodChoice];
    ORKAnswerFormat *sleepQualityFormat = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:emoticonArray];
    ORKFormItem *sleepQualityItem = [[ORKFormItem alloc]initWithIdentifier:@"SleepQuality" text:@"How would you rate your sleep overall?" answerFormat:sleepQualityFormat];
    [sleepItems addObject:sleepQualityItem];
    
    ORKTextChoice *choiceOne = [ORKTextChoice choiceWithText:@"No Effect" detailText:@"I do not think anxiety affects my sleep" value:@"noEffect" exclusive:YES];
    ORKTextChoice *choiceTwo = [ORKTextChoice choiceWithText:@"Falling Asleep" detailText:@"I have trouble falling asleep because of anxiety" value:@"fallingAsleep" exclusive:NO];
    ORKTextChoice *choiceThree = [ORKTextChoice choiceWithText:@"Staying Asleep" detailText:@"I have trouble staying asleep because of anxiety" value:@"stayingAsleep" exclusive:NO];
    ORKTextChoice *choiceFour = [ORKTextChoice choiceWithText:@"On Waking" detailText:@"I have trouble falling back asleep when I wake becaues of anxiety" value:@"onWaking" exclusive:NO];
    ORKTextChoice *choiceFive = [ORKTextChoice choiceWithText:@"Taking Naps" detailText:@"When I am anxious I nap to escape the anxiety" value:@"takingNaps" exclusive:NO];
    ORKTextChoice *choiceSix = [ORKTextChoice choiceWithText:@"Sleeping More" detailText:@"When I am having many anxious days I tend to sleep a lot more than normal" value:@"sleepingMore" exclusive:NO];
    ORKTextChoice *choiceSeven = [ORKTextChoice choiceWithText:@"Sleeping Less" detailText:@"When I am having many anxious days I tend to sleep a lot less than normal" value:@"sleepingLess" exclusive:NO];
    NSArray *sleepEffectsTextChoices = @[choiceOne, choiceTwo, choiceThree, choiceFour, choiceFive, choiceSix, choiceSeven];
    ORKAnswerFormat *sleepEffectsFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:sleepEffectsTextChoices];
    ORKFormItem *sleepEffectsItem = [[ORKFormItem alloc]initWithIdentifier:@"SleepEffects" text:@"What effect does anxiety have on your sleep? (select all that apply)" answerFormat:sleepEffectsFormat];
    [sleepItems addObject:sleepEffectsItem];
    
    sleepInfoStep.formItems = sleepItems;
    
    
    self.surveyTask =  [[ORKOrderedTask alloc] initWithIdentifier:@"survey" steps:@[personalInfoStep, anxietyInfoStep, sleepInfoStep]];
}


-(void)showSpatialSpanMemoryTask{
    
    self.spatialMemoryTask = [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:@"SpatialMemory" intendedUseDescription:nil initialSpan:3 minimumSpan:2 maximumSpan:15 playSpeed:1 maxTests:5 maxConsecutiveFailures:3 customTargetImage:[UIImage imageNamed:@"UBClogo.png"] customTargetPluralName:@"logos" requireReversal:NO options:ORKPredefinedTaskOptionNone];
    
}


-(void)showFingerTappingTask{
    
    self.fingerTappingTask = [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:@"FingerTapping" intendedUseDescription:nil duration:30 options:ORKPredefinedTaskOptionNone];
    
}

- (IBAction)consentTapped:(id)sender {
    
    ORKTaskViewController *consentTaskViewController = [[ORKTaskViewController alloc] init];
    consentTaskViewController.task = self.consentTask;
    consentTaskViewController.delegate = self;
    [self presentViewController:consentTaskViewController animated:YES completion:nil];
}

- (IBAction)surveyTapped:(id)sender {
    
    ORKTaskViewController *surveyTaskViewController = [[ORKTaskViewController alloc] init];
    surveyTaskViewController.task = self.surveyTask;
    surveyTaskViewController.delegate = self;
    [self presentViewController:surveyTaskViewController animated:YES completion:nil];
    
}

- (IBAction)spatialMemoryTapped:(id)sender {
    
    ORKTaskViewController *spatialMemoryTaskViewController = [[ORKTaskViewController alloc] init];
    spatialMemoryTaskViewController.task = self.spatialMemoryTask;
    spatialMemoryTaskViewController.delegate = self;
    [self presentViewController:spatialMemoryTaskViewController animated:YES completion:nil];

}
- (IBAction)fingerTappingTapped:(id)sender {
    
    ORKTaskViewController *fingerTappingTaskViewController = [[ORKTaskViewController alloc] init];
    fingerTappingTaskViewController.task = self.fingerTappingTask;
    fingerTappingTaskViewController.delegate = self;
    [self presentViewController:fingerTappingTaskViewController animated:YES completion:nil];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {
    
    switch (reason) {
        case ORKTaskViewControllerFinishReasonCompleted:{
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:taskViewController.result];
            break;
        }
        case ORKTaskViewControllerFinishReasonFailed:{
        }
        case ORKTaskViewControllerFinishReasonDiscarded:{
            break;
        }
        case ORKTaskViewControllerFinishReasonSaved:{
            NSData *data = [taskViewController restorationData];
            break;
        }
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

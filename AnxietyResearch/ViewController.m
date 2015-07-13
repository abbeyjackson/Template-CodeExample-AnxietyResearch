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

@property (strong, nonatomic) ORKConsentDocument *consentDocument;
@property (strong, nonatomic) ORKOrderedTask *consentTask;
@property (strong, nonatomic) ORKStep *step;
@property (strong, nonatomic) ORKOrderedTask *stepTask;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showConsent];
    [self showSurvey];

}


-(void)showSurvey{
    ORKInstructionStep *instructionStep = [[ORKInstructionStep alloc]initWithIdentifier:@"IntroStep"];
    instructionStep.title = @"The Questions Three";
    instructionStep.text = @"What came first? The chicken or the egg?";
    
    
    
    // add instructions step
    
    
    // add name question
    
    
    // add "what is your quest" question
    
    
    // add color question step
    
    
    // add summary step
    
    
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
    
    
    self.consentDocument = [ORKConsentDocument new];
    self.consentDocument.title = @"Demo Consent";
    self.consentDocument.sections = consentSections;
    
    ORKConsentSignature *signature = [ORKConsentSignature new];
    self.consentDocument.signatures = [NSArray arrayWithObject:signature];
    
    
    ORKVisualConsentStep *visualConsentStep = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visualConsentStep" document:self.consentDocument];
    
    
    ORKConsentReviewStep *consentReviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consentReviewStep" signature:self.consentDocument.signatures.firstObject inDocument:self.consentDocument];
    consentReviewStep.text = @"Review Consent!";
    consentReviewStep.reasonForConsent = @"I confirm that I consent to join this study";
    
    
    self.consentTask =  [[ORKOrderedTask alloc] initWithIdentifier:@"consent" steps:@[visualConsentStep, consentReviewStep]];

}

- (IBAction)consentTapped:(id)sender {
    
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] init];
    taskViewController.task = self.consentTask;
    taskViewController.delegate = self;
    [self presentViewController:taskViewController animated:YES completion:nil];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

//
//  RTViewController.m
//  RTViewAttachment
//
//  Created by Ricky Tan on 06/17/2016.
//  Copyright (c) 2016 Ricky Tan. All rights reserved.
//

#import <RTViewAttachment/RTViewAttachment.h>
#import <RTViewAttachment/RTViewAttachmentTextView.h>

#import "RTViewController.h"

@interface RTViewController () <UITextViewDelegate>
@property (nonatomic, strong) RTViewAttachmentTextView *textView;
@property (nonatomic, strong) IBOutlet UIView *inputAccessoryView;

@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextStorage *storage;
@end

@implementation RTViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.layoutManager = [[RTViewAttachmentLayoutManager alloc] init];
    self.storage = [[NSTextStorage alloc] initWithString:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."];
    NSTextContainer *container = [[NSTextContainer alloc] init];
    container.widthTracksTextView = YES;
    
    [self.storage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:container];
    
    self.textView = [[RTViewAttachmentTextView alloc] initWithFrame:self.view.bounds
                                                      textContainer:container];
    self.textView.inputAccessoryView = self.inputAccessoryView;
    self.textView.font = [UIFont systemFontOfSize:18.f];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.textContainerInset = UIEdgeInsetsMake(8, 16, 8, 16);
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.textView
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.textView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.textView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomLayoutGuide
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.textView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.topLayoutGuide
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)onKeyboardShow:(NSNotification *)notification
{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    frame = [self.textView convertRect:frame
                              fromView:nil];
    UIEdgeInsets inset = self.textView.contentInset;
    inset.bottom = self.textView.frame.size.height - frame.origin.y;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:curve << 16
                     animations:^{
                         self.textView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)onKeyboardHide:(NSNotification *)notification
{
    //    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    UIEdgeInsets inset = self.textView.contentInset;
    inset.bottom = 0;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:curve << 16
                     animations:^{
                         self.textView.contentInset = inset;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)onInsertSearchBar:(id)sender {
    [self.textView insertViewAttachment:[[RTViewAttachment alloc] initWithView:[[UISearchBar alloc] init]
                                                               placeholderText:@"[searchbar]"
                                                                     fullWidth:YES]];
}

- (IBAction)onInsertImage:(id)sender {
    [self.textView insertViewAttachment:[[RTViewAttachment alloc] initWithView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dog"]]
                                                               placeholderText:@"[image name='dog']"]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end

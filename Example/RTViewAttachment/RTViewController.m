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
@property (nonatomic, assign) IBOutlet RTViewAttachmentTextView *textView;
@property (nonatomic, assign) IBOutlet UIView *inputAccessoryView;
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

    self.textView.textContainerInset = UIEdgeInsetsMake(6, 16, 6, 16);
    self.textView.font = [UIFont systemFontOfSize:24.f];
    [self.textView becomeFirstResponder];
}

- (IBAction)onPrepend:(id)sender {
    [self.textView insertViewAttachment:[[RTViewAttachment alloc] initWithView:[[UISwitch alloc] init]
                                                               placeholderText:@"[switch]"]
                                atIndex:0];
}

- (IBAction)onAppend:(id)sender {
    [self.textView insertViewAttachment:[[RTViewAttachment alloc] initWithView:[[UISwitch alloc] init]
                                                               placeholderText:@"[switch]"]
                                atIndex:self.textView.length];
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

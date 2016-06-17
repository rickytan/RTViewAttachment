//
//  UITextView+ViewAttachment.m
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import "RTViewAttachmentTextView.h"
#import "RTViewAttachment.h"

@interface RTViewAttachmentTextView () <NSTextStorageDelegate>
@end

@implementation RTViewAttachmentTextView
@dynamic delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onWillProcessEdit:)
                                                     name:NSTextStorageWillProcessEditingNotification
                                                   object:self.textStorage];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onWillProcessEdit:)
                                                     name:NSTextStorageWillProcessEditingNotification
                                                   object:self.textStorage];
    }
    return self;
}

- (void)onWillProcessEdit:(NSNotification *)notification
{
    
}

- (void)copy:(id)sender
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textStorage attributedSubstringFromRange:self.selectedRange]];
    [attrString enumerateAttribute:NSAttachmentAttributeName
                           inRange:NSMakeRange(0, attrString.length)
                           options:NSAttributedStringEnumerationReverse
                        usingBlock:^(id value, NSRange range, BOOL * stop) {
                            if ([value isKindOfClass:[RTViewAttachment class]]) {
                                RTViewAttachment *attach = (RTViewAttachment *)value;
                                [attrString replaceCharactersInRange:range
                                                          withString:attach.placeholderText ?: @""];
                            }
                        }];
    [UIPasteboard generalPasteboard].string = attrString.string;
}

- (void)insertViewAttachment:(RTViewAttachment *)attachment
{
    attachment.attachedView.hidden = YES;
    [self addSubview:attachment.attachedView];
    
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:self.selectedRange
                          withAttributedString:attachment.attributedString];
    self.selectedRange = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
}


- (void)insertViewAttachment:(RTViewAttachment *)attachment
                     atIndex:(NSUInteger)index
{
    attachment.attachedView.hidden = YES;
    [self addSubview:attachment.attachedView];
    
    [self.textStorage beginEditing];
    [self.textStorage insertAttributedString:attachment.attributedString
                                     atIndex:index];
    self.selectedRange = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
}

- (void)removeViewAttachment:(RTViewAttachment *)attachment
{
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, self.textStorage.length)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired | NSAttributedStringEnumerationReverse
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                                  if (value == attachment) {
                                      [self.textStorage removeAttribute:NSAttachmentAttributeName
                                                                  range:range];
                                      [self.textStorage replaceCharactersInRange:range
                                                                      withString:@""];
                                      [attachment.attachedView removeFromSuperview];
                                      *stop = YES;
                                  }
                              }];
}

- (void)deleteBackward
{
    if (self.selectedRange.length) {
        
    }
    else {
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:NSMakeRange(self.textStorage.editedRange.location, 1)
                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                                      if ([value isKindOfClass:[RTViewAttachment class]]) {
                                          
                                      }
                                  }];
    }
    [super deleteBackward];
}

// http://stackoverflow.com/questions/25354467/detect-backspace-in-uitextfield-in-ios8
- (BOOL)keyboardInputShouldDelete:(UITextView *)textView {
    BOOL shouldDelete = YES;
    
    if ([UITextView instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextView *) = (BOOL (*)(id, SEL, UITextView *))[UITextView instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textView);
        }
    }
    
    if ([textView.text length] && [[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}

#pragma mark - NSTextStorage Delegate

- (void)textStorage:(NSTextStorage *)textStorage
 willProcessEditing:(NSTextStorageEditActions)editedMask
              range:(NSRange)editedRange
     changeInLength:(NSInteger)delta
{
    if (editedMask | NSTextStorageEditedAttributes) {
        if (delta < 0) {
            [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                         inRange:NSMakeRange(editedRange.location + delta, -delta)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(id value, NSRange range, BOOL * stop) {
                                          if ([value isKindOfClass:[RTViewAttachment class]]) {
                                              RTViewAttachment *attachment = (RTViewAttachment *)value;
                                              if (![self.delegate respondsToSelector:@selector(attachmentTextView:shouldDeleteAttachment:)] ||
                                                  [self.delegate attachmentTextView:self shouldDeleteAttachment:attachment]) {
                                                  [attachment.attachedView removeFromSuperview];
                                              }
                                          }
                                      }];
        }
    }
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    __block BOOL shouldChange = YES;
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:range
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id value, NSRange range, BOOL * stop) {
                                  if ([value isKindOfClass:[RTViewAttachment class]]) {
                                      RTViewAttachment *attachment = (RTViewAttachment *)value;
                                      if (![self.delegate respondsToSelector:@selector(attachmentTextView:shouldDeleteAttachment:)] ||
                                          [self.delegate attachmentTextView:self shouldDeleteAttachment:attachment]) {
                                          [attachment.attachedView removeFromSuperview];
                                      }
                                      else {
                                          shouldChange = NO;
                                      }
                                  }
                              }];
    return shouldChange;
}

@end

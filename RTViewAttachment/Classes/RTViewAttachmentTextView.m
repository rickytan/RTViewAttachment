//
//  UITextView+ViewAttachment.m
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import "RTViewAttachmentTextView.h"
#import "RTViewAttachment.h"


static NSString *const RTAttachmentPlaceholderString = @"\uFFFC";

@interface RTTextViewInternal : UITextView
@end

@implementation RTTextViewInternal

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

- (NSString *)text
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textStorage];
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
    return attrString.string;
}

@end

@interface RTViewAttachmentLayoutManagerInternal : NSLayoutManager
@end

@implementation RTViewAttachmentLayoutManagerInternal

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawGlyphsForGlyphRange:glyphsToShow
                           atPoint:origin];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:glyphsToShow
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                                  if ([value isKindOfClass:[RTViewAttachment class]]) {
                                      RTViewAttachment *attach = (RTViewAttachment *)value;
                                      CGRect rect = [self boundingRectForGlyphRange:range
                                                                    inTextContainer:[self textContainerForGlyphAtIndex:range.location
                                                                                                        effectiveRange:NULL]];
                                      rect.origin.x += origin.x;
                                      rect.origin.y += origin.y + (rect.size.height - attach.attachedView.bounds.size.height);
                                      rect.size.height = attach.attachedView.bounds.size.height;
                                      attach.attachedView.frame = rect;
                                      attach.attachedView.hidden = NO;
                                  }
                              }];
}

@end


@interface RTViewAttachmentTextView () <UITextViewDelegate>
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *manager;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation RTViewAttachmentTextView
@synthesize font = _font;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_commonInit
{
    NSTextContainer *container = [[NSTextContainer alloc] init];
    container.widthTracksTextView = YES;

    self.textStorage = [[NSTextStorage alloc] initWithString:@""
                                                  attributes:@{NSFontAttributeName: self.font,
                                                               NSParagraphStyleAttributeName: self.paragraphStyle}];
    self.manager = [[RTViewAttachmentLayoutManagerInternal alloc] init];

    [self.textStorage addLayoutManager:self.manager];
    [self.manager addTextContainer:container];

    self.textView = [[RTTextViewInternal alloc] initWithFrame:self.bounds
                                                textContainer:container];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.delegate = self;
    self.textView.font = self.font;
    [self addSubview:self.textView];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)onKeyboardShow:(NSNotification *)notification
{
    if (!self.textView.isFirstResponder)
        return;

    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    frame = [self convertRect:frame
                     fromView:nil];
    UIEdgeInsets inset = self.textView.contentInset;
    inset.bottom = self.textView.frame.size.height - frame.origin.y + self.textView.frame.origin.y;

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
    if (!self.isFirstResponder)
        return;
    
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

- (BOOL)becomeFirstResponder
{
    return [self.textView becomeFirstResponder];
}

- (void)setFont:(UIFont *)font
{
    if (_font != font) {
        _font = font;

        self.textView.font = _font;
        [self.textStorage addAttributes:@{NSFontAttributeName: _font}
                                  range:self.textView.selectedRange];
    }
}

- (UIFont *)font
{
    if (!_font) {
        _font = [UIFont systemFontOfSize:17.f];
    }
    return _font;
}

- (NSParagraphStyle *)paragraphStyle
{
    if (!_paragraphStyle) {
        _paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
    }
    return _paragraphStyle;
}

- (NSRange)selectedRange
{
    return self.textView.selectedRange;
}

- (void)setSelectedRange:(NSRange)selectedRange
{
    self.textView.selectedRange = selectedRange;
}

- (UIEdgeInsets)textContainerInset
{
    return self.textView.textContainerInset;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    self.textView.textContainerInset = textContainerInset;
}

- (NSUInteger)length
{
    return self.textStorage.length;
}

- (void)insertViewAttachment:(RTViewAttachment *)attachment
{
    attachment.attachedView.hidden = YES;
    [self.textView addSubview:attachment.attachedView];

    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:self.selectedRange
                                    withString:RTAttachmentPlaceholderString];
    [self.textStorage addAttributes:@{NSAttachmentAttributeName: attachment,
                                      NSFontAttributeName: self.font,
                                      NSParagraphStyleAttributeName: self.paragraphStyle}
                              range:self.textStorage.editedRange];
    NSRange range = NSMakeRange(MIN(self.textStorage.editedRange.location + self.textStorage.editedRange.length, self.textStorage.length), 0);
    [self.textStorage endEditing];
    self.selectedRange = range;
}


- (void)insertViewAttachment:(RTViewAttachment *)attachment
                     atIndex:(NSUInteger)index
{
    attachment.attachedView.hidden = YES;
    [self.textView addSubview:attachment.attachedView];

    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:NSMakeRange(index, 0)
                                    withString:RTAttachmentPlaceholderString];
    [self.textStorage addAttributes:@{NSAttachmentAttributeName: attachment,
                                      NSFontAttributeName: self.font,
                                      NSParagraphStyleAttributeName: self.paragraphStyle}
                              range:self.textStorage.editedRange];
    NSRange range = NSMakeRange(self.textStorage.editedRange.location + self.textStorage.editedRange.length, 0);
    [self.textStorage endEditing];
    self.selectedRange = range;
}

- (void)removeViewAttachment:(RTViewAttachment *)attachment
{
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, self.textStorage.length)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired | NSAttributedStringEnumerationReverse
                              usingBlock:^(id value, NSRange range, BOOL * stop) {
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

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    __block BOOL shouldChange = YES;
    NSMutableArray <RTViewAttachment *> *arr = [NSMutableArray array];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:range
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id value, NSRange range, BOOL * stop) {
                                  if ([value isKindOfClass:[RTViewAttachment class]]) {
                                      RTViewAttachment *attachment = (RTViewAttachment *)value;
                                      [arr addObject:attachment];
                                  }
                              }];
    if (arr.count) {
        shouldChange = (![self.delegate respondsToSelector:@selector(attachmentTextView:shouldDeleteAttachments:)] ||
                        [self.delegate attachmentTextView:self
                                  shouldDeleteAttachments:[NSArray arrayWithArray:arr]]);
    }
    if (shouldChange) {
        arr = nil;
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:range
                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                  usingBlock:^(id value, NSRange range, BOOL * stop) {
                                      if ([value isKindOfClass:[RTViewAttachment class]]) {
                                          RTViewAttachment *attachment = (RTViewAttachment *)value;
                                          if ([self.delegate respondsToSelector:@selector(attachmentTextView:willDeleteAttachment:)]) {
                                              [self.delegate attachmentTextView:self
                                                           willDeleteAttachment:attachment];
                                          }

                                          [self.textStorage removeAttribute:NSAttachmentAttributeName range:range];
                                          [attachment.attachedView removeFromSuperview];

                                          if ([self.delegate respondsToSelector:@selector(attachmentTextView:didDeleteAttachment:)]) {
                                              [self.delegate attachmentTextView:self
                                                            didDeleteAttachment:attachment];
                                          }
                                      }
                                  }];
    }
    return shouldChange;
}

@end

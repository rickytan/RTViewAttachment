//
//  RTViewAttachment.m
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import "RTViewAttachment.h"

@implementation RTViewAttachment

- (void)dealloc
{
    [self.attachedView removeFromSuperview];
}

- (instancetype)initWithView:(UIView *)view
             placeholderText:(NSString *)text
                   fullWidth:(BOOL)fullWidth
{
    NSData *data = text ? [NSData dataWithBytes:text.UTF8String
                                         length:strlen(text.UTF8String)] : nil;
    self = [super initWithData:data
                        ofType:@"application/x-view"];
    if (self) {
        self.attachedView = view;
        self.placeholderText = text;
        self.fullWidth = fullWidth;
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view
             placeholderText:(NSString *)text
{
    return [self initWithView:view
              placeholderText:text
                    fullWidth:NO];
}

- (instancetype)initWithView:(UIView *)view
{
    return [self initWithView:view
              placeholderText:nil];
}

- (void)setAttachedView:(UIView *)attachedView
{
    if (_attachedView != attachedView) {
        _attachedView = attachedView;
        self.bounds = _attachedView.bounds;
    }
}

- (NSAttributedString *)attributedString
{
    return [NSAttributedString attributedStringWithAttachment:self];
}

#pragma mark - Overrides

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    return nil;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex
{
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer
                                     proposedLineFragment:lineFrag
                                            glyphPosition:position
                                           characterIndex:charIndex];
    if (self.isFullWidth) {
        rect.size.width = CGRectGetWidth(lineFrag) - textContainer.lineFragmentPadding * 2;
    }
    return rect;
}

@end

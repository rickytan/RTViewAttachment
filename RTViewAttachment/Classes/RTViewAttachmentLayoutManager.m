//
//  RTViewAttachmentLayoutManager.m
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import "RTViewAttachmentLayoutManager.h"
#import "RTViewAttachment.h"

@implementation RTViewAttachmentLayoutManager

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawGlyphsForGlyphRange:glyphsToShow
                           atPoint:origin];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:glyphsToShow
                                 options:0
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                                  if ([value isKindOfClass:[RTViewAttachment class]]) {
                                      RTViewAttachment *attach = (RTViewAttachment *)value;
                                      CGRect rect = [self boundingRectForGlyphRange:range
                                                                    inTextContainer:[self textContainerForGlyphAtIndex:range.location
                                                                                                        effectiveRange:NULL]];
                                      rect.origin.x += origin.x;
                                      rect.origin.y += origin.y;
                                      attach.attachedView.frame = rect;
                                      attach.attachedView.hidden = NO;
                                  }
                              }];
}

@end

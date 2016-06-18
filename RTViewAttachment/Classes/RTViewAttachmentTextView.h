//
//  UITextView+ViewAttachment.h
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import <UIKit/UIKit.h>

@class RTViewAttachment;
@class RTViewAttachmentTextView;

@protocol RTViewAttachmentTextViewDelegate <NSObject>
@optional
- (BOOL)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView shouldDeleteAttachments:(NSArray <RTViewAttachment *> *)attachments;

- (void)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView willDeleteAttachment:(RTViewAttachment *)attachment;
- (void)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView didDeleteAttachment:(RTViewAttachment *)attachment;

@end

IB_DESIGNABLE
@interface RTViewAttachmentTextView : UIView
@property (nonatomic, readonly, strong) UITextView *textView;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, readonly) NSUInteger length;

@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;
@property (nonatomic, strong) IBInspectable UIFont *font;
@property (nonatomic, assign) IBInspectable UIEdgeInsets textContainerInset;

@property (nonatomic, weak) IBOutlet id<RTViewAttachmentTextViewDelegate> delegate;

- (void)insertViewAttachment:(RTViewAttachment *)attachment;
- (void)insertViewAttachment:(RTViewAttachment *)attachment atIndex:(NSUInteger)index;
- (void)removeViewAttachment:(RTViewAttachment *)attachment;

@end

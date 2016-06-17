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

@protocol RTViewAttachmentTextViewDelegate <UITextViewDelegate>
@optional
- (BOOL)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView shouldDeleteAttachment:(RTViewAttachment *)attachment;
- (void)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView willDeleteAttachment:(RTViewAttachment *)attachment;
- (void)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView didDeleteAttachment:(RTViewAttachment *)attachment;

@end

@interface RTViewAttachmentTextView: UITextView
@property (nonatomic, weak) id<RTViewAttachmentTextViewDelegate> delegate;

- (void)insertViewAttachment:(RTViewAttachment *)attachment;
- (void)insertViewAttachment:(RTViewAttachment *)attachment atIndex:(NSUInteger)index;
- (void)removeViewAttachment:(RTViewAttachment *)attachment;

@end

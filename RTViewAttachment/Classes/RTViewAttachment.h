//
//  RTViewAttachment.h
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import <UIKit/UIKit.h>

@interface RTViewAttachment : NSTextAttachment

/**
 *  The view you want to attach to the text editor, please set its size before attaching to a text editor
 */
@property (nonatomic, strong) __kindof UIView *attachedView;

/**
 *  This is the text that will be outputed when use copy from text editor
 */
@property (nonatomic, copy) NSString *placeholderText;

/**
 *  If this property is set to `YES`, the attachedView.bounds.size.width will be the text editor's edit area width
 */
@property (nonatomic, assign, getter=isFullWidth) BOOL fullWidth;

@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) NSInteger tag;


- (instancetype)initWithView:(UIView *)view;
- (instancetype)initWithView:(UIView *)view
             placeholderText:(NSString *)text;
- (instancetype)initWithView:(UIView *)view
             placeholderText:(NSString *)text
                   fullWidth:(BOOL)fullWidth;

@end

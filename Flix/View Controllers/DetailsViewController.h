//
//  DetailsViewController.h
//  Flix
//
//  Created by Marin Hyatt on 6/23/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

//Public property that others will set (this is why it's in header)
@property (nonatomic, strong) NSDictionary *movie;

@end

NS_ASSUME_NONNULL_END

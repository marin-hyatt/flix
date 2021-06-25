//
//  DetailsViewController.m
//  Flix
//
//  Created by Marin Hyatt on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TrailerViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

- (IBAction)trailerGestureRecognizer:(UITapGestureRecognizer *)sender;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak DetailsViewController *weakSelf = self;
    
    //Builds the URL for the movie poster.
    NSString *baseStringSmall = @"https://image.tmdb.org/t/p/w45";
    NSString *baseStringLarge = @"https://image.tmdb.org/t/p/original";
    NSString *posterString = self.movie[@"poster_path"];
    NSString *fullStringSmall = [baseStringSmall stringByAppendingString:posterString];
    NSString *fullStringLarge = [baseStringLarge stringByAppendingString:posterString];
    
    NSURL *posterURLSmall = [NSURL URLWithString:fullStringSmall];
    NSURL *posterURLLarge = [NSURL URLWithString:fullStringLarge];

    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:posterURLSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:posterURLLarge];
    

    [weakSelf.posterView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
        weakSelf.posterView.alpha = 0.0;
        weakSelf.posterView.image = smallImage;
        
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                           weakSelf.posterView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.posterView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                weakSelf.posterView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                weakSelf.posterView.image = smallImage;
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];

    //Builds the backdrop URL and displays it.
    NSString *backdropString = self.movie[@"backdrop_path"];
    NSString *fullBackdropStringSmall = [baseStringSmall stringByAppendingString:backdropString];
    NSString *fullBackdropStringLarge = [baseStringLarge stringByAppendingString:backdropString];
    
    NSURL *backdropURLSmall = [NSURL URLWithString:fullBackdropStringSmall];
    NSURL *backdropURLLarge = [NSURL URLWithString:fullBackdropStringLarge];

    NSURLRequest *backdropRequestSmall = [NSURLRequest requestWithURL:backdropURLSmall];
    NSURLRequest *backdropRequestLarge = [NSURLRequest requestWithURL:backdropURLLarge];
    
    [weakSelf.backdropView setImageWithURLRequest:backdropRequestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
        weakSelf.backdropView.alpha = 0.0;
        weakSelf.backdropView.image = smallImage;
        
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                           weakSelf.backdropView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.backdropView setImageWithURLRequest:backdropRequestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                weakSelf.backdropView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                weakSelf.backdropView.image = smallImage;
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
    
    //Sets title and synopsis labels.
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    
    //Resizes title and synopsis to fit.
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    
    // Instantiate gesture recognizer with action we defined
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trailerGestureRecognizer:)];
    
    // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
    [self.posterView setUserInteractionEnabled:YES];
    [self.posterView addGestureRecognizer:tapGestureRecognizer];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Get movie ID.
    NSString *movieId = self.movie[@"id"];
    
    // Gets the destination view controller.
    TrailerViewController *trailerViewController = [segue destinationViewController];
    trailerViewController.movieID = movieId;
}


- (IBAction)trailerGestureRecognizer:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");
    //Segue to trailer view
    [self performSegueWithIdentifier:@"PresentTrailer" sender:nil];
}
@end

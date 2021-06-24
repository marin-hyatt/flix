//
//  DetailsViewController.m
//  Flix
//
//  Created by Marin Hyatt on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

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
    //Builds the poster URL and displays it.
    NSString *baseString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterString = self.movie[@"poster_path"];
    NSString *fullPosterString = [baseString stringByAppendingString:posterString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterString];
    [self.posterView setImageWithURL:posterURL];

    //Builds the backdrop URL and displays it.
    NSString *backdropString = self.movie[@"backdrop_path"];
    NSString *fullBackdropString = [baseString stringByAppendingString:backdropString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropString];
    [self.backdropView setImageWithURL:backdropURL];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)trailerGestureRecognizer:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");
    //Segue to trailer view
    [self performSegueWithIdentifier:@"PresentTrailer" sender:nil];
}
@end

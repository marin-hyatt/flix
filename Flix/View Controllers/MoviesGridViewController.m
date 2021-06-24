//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Marin Hyatt on 6/23/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchMovies];
    
    //Resizes layout
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    
    CGFloat postersPerLine = 2;
    //Accounting for the spaces in between the movie posters
    CGFloat itemWidth = ((self.collectionView.frame.size.width - (layout.minimumInteritemSpacing))/ postersPerLine);
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)fetchMovies {
    
    //Make networking call once the view loads.
    
    //Makes request for movies that are now playing.
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/399566/similar?api_key=6523b7e495ff548f5a8e3c5f6ed927ef&language=en-US&page=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    //Block that runs after network call is finished. If there's an error then handle it. If not, store the API response in a dictionary.
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               //Creates alert if there is an error
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Lost"
                                                                              message:@"Please restore your Wi-fi connection to view movies."
                                                                       preferredStyle:(UIAlertControllerStyleAlert)];
               // create a cancel action
               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                        // No response, will dismiss view
                                                                 }];
               // add the cancel action to the alertController
               [alert addAction:cancelAction];

               // create an OK action
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                        // handle response here.
                   [self fetchMovies];
                                                                }];
               // add the OK action to the alert controller
               [alert addAction:okAction];
               
               //Presents alert controller
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               
               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
               [self.collectionView reloadData];
           }
       }];
    [task resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //Gets the movie corresponding to the tapped cell
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    // Gets the destination view controller.
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    // Pass the movie to the new view controller.
    detailsViewController.movie = movie;
    
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    //Indexes the movie array for the right movie corresponding to the row.
    NSDictionary *movie = self.movies[indexPath.item];
    
    NSString *baseString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterString = movie[@"poster_path"];
    NSString *fullString = [baseString stringByAppendingString:posterString];
    
    NSURL *posterURL = [NSURL URLWithString:fullString];
    
    //Links the cell title to movie title, cell text to movie overview, etc
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}



@end

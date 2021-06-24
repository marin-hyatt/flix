//
//  MoviesViewController.m
//  Flix
//
//  Created by Marin Hyatt on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkIndicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredMovies;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Assigns self as the data source and delegate for the table view in the movies view controller.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    //Initial loading of movies
    [self fetchMovies];
    
    //Creates and adds refresh control to the table view
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchMovies {
    //Starts animating loading indicator to show that we are waiting for network response.
    [self.networkIndicator startAnimating];
    
    //Make networking call once the view loads.
    
    //Makes request for movies that are now playing.
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=6523b7e495ff548f5a8e3c5f6ed927ef"];
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

               NSLog(@"%@", dataDictionary);
               
               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               self.filteredMovies = self.movies;
               
               for (NSDictionary *movie in self.filteredMovies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
               //Reloads table view once network call finishes to display the results of the network call.
               [self.tableView reloadData];
           }
        //Ends refreshing regardless of whether there was an error with the network or not.
        [self.refreshControl endRefreshing];
        //Stops animating loading indicator.
        [self.networkIndicator stopAnimating];
       }];
    [task resume];
}

//Specifies that the table view has the same number of rows as number of movies retrieved.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

//Creates a new table view with table view cells (like a View but with a few special properties). The text in the cell displays its row and section.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Asks tableView to create cell with templeate MovieCell and return it
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    //Indexes the movie array for the right movie corresponding to the row.
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    //Builds the URL for the movie poster.
    NSString *baseString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterString = movie[@"poster_path"];
    NSString *fullString = [baseString stringByAppendingString:posterString];
    
    NSURL *posterURL = [NSURL URLWithString:fullString];
    
    //Links the cell title to movie title, cell text to movie overview, etc
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:posterURL];
    
    return cell;
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
            // Creates a predicate used for filtering, in this case we use the title
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *movie, NSDictionary *bindings) {
                return [movie[@"title"] containsString:searchText];
            }];
            // Filters the array of movies using the predicate
            self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        }
        else {
            //If no search, don't filter anything
            self.filteredMovies = self.movies;
        }
        //Refresh the data to reflect filtering
        [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //Display cancel button when user beigns typing
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //Takes away cancel button, deletes text, hides keyboard
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    //Removes filter and refreshes data
    self.filteredMovies = self.movies;
    [self.tableView reloadData];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Gets the movie corresponding to the tapped cell/
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    // Gets the destination view controller.
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    // Pass the movie to the new view controller.
    detailsViewController.movie = movie;
}

@end

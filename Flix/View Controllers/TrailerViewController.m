//
//  TrailerViewController.m
//  Flix
//
//  Created by Marin Hyatt on 6/24/21.
//

#import "TrailerViewController.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *trailerView;

@end

@implementation TrailerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Create API call.
    NSString *joinString=[NSString stringWithFormat:@"%@%@%@",@"https://api.themoviedb.org/3/movie/", self.movieID, @"/videos?api_key=6523b7e495ff548f5a8e3c5f6ed927ef&language=en-US"];
    //Make networking call once the view loads.
    
    //Makes request for movie trailer.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",joinString]];
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

               
               // Get video key
               NSArray *trailers = dataDictionary[@"results"];
               NSDictionary *firstTrailer = trailers[0];
               NSString *trailerKey = firstTrailer[@"key"];
               
               NSLog(@"Key: %@", trailerKey);
               
               // Construct the trailer URL.
               NSString *trailerURL = [NSString stringWithFormat:@"%@%@",@"https://www.youtube.com/watch?v=", trailerKey];
               
               NSLog(@"Trailer URL: %@", trailerURL);
               
               // Convert the url String to a NSURL object.
               NSURL *url = [NSURL URLWithString:trailerURL];

               // Place the URL in a URL Request.
               NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                    timeoutInterval:10.0];
               // Load Request into WebView.
               [self.trailerView loadRequest:request];
               
           }
//        //Ends refreshing regardless of whether there was an error with the network or not.
//        [self.refreshControl endRefreshing];
//        //Stops animating loading indicator.
//        [self.networkIndicator stopAnimating];
       }];
    [task resume];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

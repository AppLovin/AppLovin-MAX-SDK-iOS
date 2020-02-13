//
//  ALDemoNativeAdFeedTableViewController.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 9/24/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoNativeAdFeedTableViewController.h"
#import "ALCarouselView.h"
#import "ALDemoRSSFeedRetriever.h"

//
// This view controller demonstrates how to display native ads using our open-source carousel views.
//

@interface ALDemoNativeAdFeedTableViewController()
@property (nonatomic, strong) NSArray<ALDemoArticle *> *articles;
@end

@implementation ALDemoNativeAdFeedTableViewController
static NSString *const kArticleCellIdentifier = @"articleCell";
static NSString *const kAdCellIdentifier      = @"adCell";

static NSUInteger const kCellTagTitleLabel       = 2;
static NSUInteger const kCellTagSubtitleLabel    = 3;
static NSUInteger const kCellTagDescriptionLabel = 4;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ALDemoRSSFeedRetriever sharedRetriever] startParsingWithCompletion:^(NSError * _Nullable error, NSArray<ALDemoArticle *> * _Nonnull articles) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ( error || articles.count == 0 )
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"ERROR" message: error.localizedDescription preferredStyle: UIAlertControllerStyleAlert];
                [alert addAction: [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated: YES];
                }]];
                [self presentViewController: alert animated: YES completion: nil];
            }
            else
            {
                self.articles = articles;
                [self.tableView reloadData];
            }
        });
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.articles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.articles[indexPath.row].isAd ? 360.0f : 280.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    ALDemoArticle *article = self.articles[indexPath.row];

    if ( article.isAd )
    {
        // You can configure carousels in ALCarouselViewSettings.h
        cell = [tableView dequeueReusableCellWithIdentifier: kAdCellIdentifier forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier: kArticleCellIdentifier forIndexPath:indexPath];
        ((UILabel *)[cell viewWithTag: kCellTagTitleLabel]).text       = article.title;
        ((UILabel *)[cell viewWithTag: kCellTagSubtitleLabel]).text    = [NSString stringWithFormat: @"%@ - %@", article.creator, article.pubDate];
        ((UILabel *)[cell viewWithTag: kCellTagDescriptionLabel]).text = article.articleDescription;
    }

    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    ALDemoArticle *article = self.articles[indexPath.row];
    [[UIApplication sharedApplication] openURL: article.link];
}

@end

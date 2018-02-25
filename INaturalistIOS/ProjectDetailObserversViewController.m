//
//  ProjectDetailObserversViewController.m
//  iNaturalist
//
//  Created by Alex Shepard on 2/23/16.
//  Copyright © 2016 iNaturalist. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <UIColor-HTMLColors/UIColor+HTMLColors.h>
#import <RestKit/RestKit.h>

#import "ProjectDetailObserversViewController.h"
#import "ObserverCount.h"
#import "ExploreUser.h"
#import "RankedUserObsSpeciesCell.h"
#import "UIImage+INaturalist.h"
#import "INatReachability.h"

// both the nib name and the reuse identifier
static NSString *rankedUserObsSpeciesName = @"RankedUserObsSpecies";

@interface ProjectDetailObserversViewController ()
@end

@implementation ProjectDetailObserversViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = ({
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;

        label.attributedText = ({
            NSString *emptyTitle;
            if ([[INatReachability sharedClient] isNetworkReachable]) {
                emptyTitle = NSLocalizedString(@"There are no observations for this project yet. Check back soon!", nil);
            } else {
                emptyTitle = NSLocalizedString(@"No network connection. :(", nil);
            }
            NSDictionary *attrs = @{
                                    NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#505050"],
                                    NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
                                    };
            [[NSAttributedString alloc] initWithString:emptyTitle
                                                   attributes:attrs];
        });
        
        label;
    });
    self.totalCount = 0;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:rankedUserObsSpeciesName bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:rankedUserObsSpeciesName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    tableView.backgroundView.hidden = (self.observerCounts.count > 0);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.observerCounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankedUserObsSpeciesCell *cell = [tableView dequeueReusableCellWithIdentifier:rankedUserObsSpeciesName
                                                              forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;    
    ObserverCount *count = self.observerCounts[indexPath.item];
    cell.userNameLabel.text = count.observer.login;
    
    cell.observationsCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count.observationCount];
    cell.speciesCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count.speciesCount];
    cell.rankLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.observerCounts indexOfObject:count] + 1];
    
    if (count.observer.userIcon) {
        [cell.userImageView setImageWithURL:count.observer.userIcon];
    } else {
        cell.userImageView.image = [UIImage inat_defaultUserImage];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 30);
    
    view.backgroundColor = [UIColor colorWithHexString:@"#ebebf1"];
    
    UILabel *rankTitle = [UILabel new];
    rankTitle.translatesAutoresizingMaskIntoConstraints = NO;
    rankTitle.text = [NSLocalizedString(@"Rank", @"Rank in an ordered list") uppercaseString];
    rankTitle.font = [UIFont systemFontOfSize:13];
    [view addSubview:rankTitle];
    
    UILabel *observationsTitle = [UILabel new];
    observationsTitle.translatesAutoresizingMaskIntoConstraints = NO;
    observationsTitle.text = [NSLocalizedString(@"Observations", nil) uppercaseString];
    observationsTitle.font = [UIFont systemFontOfSize:13];
    observationsTitle.textAlignment = NSTextAlignmentRight;
    [view addSubview:observationsTitle];
    
    UILabel *speciesTitle = [UILabel new];
    speciesTitle.translatesAutoresizingMaskIntoConstraints = NO;
    speciesTitle.text = [NSLocalizedString(@"Species", nil) uppercaseString];
    speciesTitle.font = [UIFont systemFontOfSize:13];
    speciesTitle.textAlignment = NSTextAlignmentRight;
    [view addSubview:speciesTitle];
    
    NSDictionary *views = @{
                            @"rank": rankTitle,
                            @"observations": observationsTitle,
                            @"species": speciesTitle,
                            };
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[rank]-[observations]-12-[species]-16-|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rank]-0-|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[observations]-0-|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:views]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[species]-0-|"
                                                                 options:0
                                                                 metrics:0
                                                                   views:views]];

    
    return view;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.containedScrollViewDelegate containedScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.containedScrollViewDelegate containedScrollViewDidStopScrolling:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.containedScrollViewDelegate containedScrollViewDidStopScrolling:scrollView];
    }
}

@end

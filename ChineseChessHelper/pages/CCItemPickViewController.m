//
//  CCItemPickViewController.m
//  ChineseChessHelper
//
//  Created by byte dance on 2020/8/3.
//  Copyright © 2020 sheehangame. All rights reserved.
//

#import "CCItemPickViewController.h"
#import "NSString+PinYin.h"

static NSString *cellIdentifier = @"reuse_identifier";

@interface CCItemPickViewController () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSArray<NSString *> *allItems;
@property (nonatomic, strong) NSArray<NSString *> *specialItems;
@property (nonatomic, strong) NSString *specialTitle;
@property (nonatomic, strong) NSMutableArray<NSString *> *searchResult;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *groups;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *firstLetters;
@property (nonatomic, strong) NSMutableArray<NSString *> *sectionTitles;

@end

@implementation CCItemPickViewController

- (instancetype)initWithItems:(NSArray<NSString *> *)items specialItems:(NSArray<NSString *> *)sitems specialTitle:(NSString *)st
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.allItems = items;
        self.specialItems = sitems;
        self.specialTitle = st;
        self.searchResult = [NSMutableArray array];
        
        self.groups = [NSMutableDictionary dictionary];
        self.firstLetters = [NSMutableDictionary dictionary];
        for (NSString *item in self.allItems) {
            NSString *firstLetter = nil;
            NSMutableArray *letters = [NSMutableArray array];
            for (int i = 0; i < item.length; i++) {
                NSString *letter = [[item substringWithRange:NSMakeRange(i, 1)] getFirstLetter];
                if (letter.length > 0) {
                    if (!firstLetter) {
                        firstLetter = letter;
                    }
                    [letters addObject:letter];
                }
            }
            
            if (firstLetter) {
                NSMutableArray *items = [self.groups objectForKey:firstLetter];
                if (!items || ![items isKindOfClass:[NSMutableArray class]]) {
                    items = [NSMutableArray array];
                    [self.groups setValue:items forKey:firstLetter];
                }
                [items addObject:item];
            }
            
            
            [self.firstLetters setValue:[letters componentsJoinedByString:@""]  forKey:item];
        }
        
        self.sectionTitles = [[self.groups.allKeys sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        if (st.length > 0 && sitems.count > 0) {
            if (self.sectionTitles.count > 0) {
                [self.sectionTitles insertObject:st atIndex:0];
            } else {
                [self.sectionTitles addObject:st];
            }
            
            [self.groups setObject:sitems forKey:st];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.searchController.searchBar setValue:@"取消".localized forKey:@"cancelButtonText"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(enableSearch)];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, AD_HEIGHT + self.view.safeAreaInsets.bottom, 0);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.tableView];
}

- (void)cancelAction:(UIButton *)sender
{
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)enableSearch
{
    [self.tableView scrollRectToVisible:self.tableView.tableHeaderView.frame animated:false];
    [self.searchController setActive:YES];
}

#pragma mark - UITableViewDelegate And Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchController.isActive) {
        return 1;
    }
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.isActive) {
        return self.searchResult.count;
    }
    
    if (section < self.sectionTitles.count) {
        NSString *sectionTitle = self.sectionTitles[section];
        return self.groups[sectionTitle].count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchController.isActive) {
        return 0.0f;
    }
    return 20;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchController.isActive) {
        return nil;
    }
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.searchController.isActive && section < self.sectionTitles.count) {
        return self.sectionTitles[section];
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *content = nil;
    if (self.searchController.isActive) {
        if (indexPath.row < self.searchResult.count) {
            content = self.searchResult[indexPath.row];
        }
    } else if(indexPath.section < self.sectionTitles.count) {
        NSString *sectionTitle = self.sectionTitles[indexPath.section];
        if (sectionTitle) {
            NSArray<NSString *> *groupItems = [self.groups objectForKey:sectionTitle];
            if (indexPath.row < groupItems.count) {
                content = groupItems[indexPath.row];
            }
        }
    }
    cell.textLabel.text = content;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.doneAction) {
        if (self.searchController.isActive) {
            NSString *search = self.searchResult[indexPath.row];
            NSInteger idx = NSNotFound;
            if (self.specialItems.count > 0) {
                idx = [self.specialItems indexOfObject:search];
                if (idx != NSNotFound) {
                    CALL_BLOCK(self.specialDoneAction, idx);
                }
            }
            
            if (idx == NSNotFound) {
                idx = [self.allItems indexOfObject:search];
                if (idx != NSNotFound) {
                    CALL_BLOCK(self.doneAction, idx);
                }
            }
            [self.searchController setActive:NO];
        } else if(indexPath.section < self.sectionTitles.count) {
            NSString *sectionTitle = self.sectionTitles[indexPath.section];
            if (sectionTitle) {
                NSArray<NSString *> *groupItems = [self.groups objectForKey:sectionTitle];
                if (indexPath.row < groupItems.count) {
                    NSString *item = groupItems[indexPath.row];
                    if (self.specialItems.count > 0 && indexPath.section == 0) {
                        CALL_BLOCK(self.specialDoneAction, [self.specialItems indexOfObject:item]);
                    } else {
                        CALL_BLOCK(self.doneAction, [self.allItems indexOfObject:item]);
                    }
                }
            }
        }
    }
    
    [self cancelAction:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.searchController.isActive) {
        [self.searchController.searchBar resignFirstResponder];
    }
}
#pragma mark - UISearchControllerDelegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.searchResult removeAllObjects];
    if (self.searchController.searchBar.text.length > 0) {
        NSString *searchText = self.searchController.searchBar.text;
        NSArray *temp = [self.allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if ([evaluatedObject isKindOfClass:[NSString class]]) {
                if ([evaluatedObject rangeOfString:searchText].location != NSNotFound) {
                    [self.searchResult addObject:evaluatedObject];
                    return false;
                }
                return true;
            }
            return false;
        }]];
        
        NSMutableArray<NSString *> *searchLetters = [NSMutableArray array];
        for (int i = 0; i < searchText.length; i++) {
            NSString *letter = [[searchText substringWithRange:NSMakeRange(i, 1)] getFirstLetter];
            if (letter) {
                [searchLetters addObject:letter];
            }
        }
        NSString *searchLettersString = [searchLetters componentsJoinedByString:@""];
        if (searchLettersString.length > 0) {
            NSMutableArray *tempMatch = [NSMutableArray array];
            temp = [temp filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                if ([evaluatedObject isKindOfClass:[NSString class]]) {
                    NSString *lettersString = [self.firstLetters objectForKey:evaluatedObject];
                    if (lettersString.length > 0 && lettersString.length >= searchLettersString.length) {
                        NSRange range = [lettersString rangeOfString:searchLettersString];
                        if (range.location != NSNotFound) {
                            if (range.location == 0) {
                                [self.searchResult addObject:evaluatedObject];
                            } else {
                                [tempMatch addObject:evaluatedObject];
                            }
                            return false;
                        }
                    }
                    
                    return true;
                }
                return false;
            }]];
            
            if (tempMatch.count > 0) {
                [self.searchResult addObjectsFromArray:tempMatch];
            }
        }
    }
    
    [self.tableView reloadData];
}

@end

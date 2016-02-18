//
//  CYMusicListViewController.m
//  01-距离传感器
//
//  Created by dongzb on 16/2/15.
//  Copyright © 2016年 叫兽. All rights reserved.
//

#import "CYMusicListViewController.h"
#import "ViewController.h"
@interface CYMusicListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *array;
@end

@implementation CYMusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.array = [NSArray arrayWithObjects:@"MC天佑 - 曾经的王者",@"MC韩雅乐 - 为了你",@"MC淡定哥 - 抓住手",@"JYJ - MC",@"罗艺恒 - 青花瓷",@"蓝弟 - 他叫李天佑",nil];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
    
}

#pragma mark - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.array.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 从storyboard创建MainViewController
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *mainViewController = (ViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    mainViewController.title = [self.array objectAtIndex:indexPath.row];
    mainViewController.currentIndex = indexPath.row;
    mainViewController.musicList    = self.array;
    [self.navigationController pushViewController:mainViewController animated:YES];
    
}


@end

//
//  MusicListController.m
//  TuSDKVideoDemo
//
//  Created by 言有理 on 2021/6/9.
//  Copyright © 2021 TuSDK. All rights reserved.
//

#import "MusicListController.h"
#import "TuSDKFramework.h"
#import "MusicItem.h"
@interface MusicListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <MusicItem *>*items;
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation MusicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualView.frame = self.view.bounds;
    [self.view addSubview:visualView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, [UIDevice lsqIsDeviceiPhoneX] ? 44 : 20, lsqScreenWidth, 64);
    [backButton setImage:[UIImage imageNamed:@"music_ic_closed"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    self.items = @[[MusicItem itemWithName:@"无" time:@""],
                   [MusicItem itemWithName:@"city_sunshine" time:@"03:04"],
                   [MusicItem itemWithName:@"eye_of_forgiveness" time:@"01:38"],
                   [MusicItem itemWithName:@"sound_cat" time:@"00:10"]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(backButton.frame), UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - CGRectGetMaxY(backButton.frame))];
    tableView.backgroundColor = UIColor.clearColor;
    tableView.scrollEnabled = NO;
    tableView.rowHeight = 80;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[MusicListCell classForCoder] forCellReuseIdentifier:@"MusicListController"];
    tableView.tableFooterView = [UIView new];
    //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backButtonAction {
    [self dismiss];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicListController" forIndexPath:indexPath];
    cell.item = self.items[indexPath.row];
    __weak __typeof(self)weakSelf = self;
    cell.playerBlock = ^ {
        [weakSelf updateIndex:indexPath.row];
    };
    cell.didSelectedBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(controller:didSelectedAtItem:)]) {
            [weakSelf.delegate controller:weakSelf didSelectedAtItem:weakSelf.items[indexPath.row].name];
        }
    };
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateIndex:indexPath.row];
}
- (void)updateIndex:(NSInteger)index {
    if (index == 0) {
        return;
    }
    MusicItem *item = self.items[index];
    item.isPlaying = !item.isPlaying;
    if (item.isPlaying) {
        for (int i = 0; i<self.items.count; i++) {
            if (i != index && self.items[i].isPlaying) {
                self.items[i].isPlaying = NO;
            }
        }
    }
    
    [self.tableView reloadData];
    if (item.isPlaying) {
        //self.player.currentItem.
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:item.name ofType:@"mp3"]]];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self.player play];
    } else {
        [self.player pause];
    }
}
- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:nil];
    }
    return _player;
}


@end


@interface MusicListCell ()
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *doneButton;
@end
@implementation MusicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.iconButton setImage:[UIImage imageNamed:@"music_ic_record1"] forState:UIControlStateNormal];
        [self.iconButton setImage:[UIImage imageNamed:@"music_ic_record2"] forState:UIControlStateSelected];
        [self.iconButton addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.iconButton];
        [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(25);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(52);
        }];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconButton.mas_right).offset(16);
            make.top.mas_equalTo(21);
            make.height.mas_equalTo(20);
        }];
        
        _subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.textColor = [UIColor whiteColor];
        self.subTitleLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.subTitleLabel];
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_left);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(15);
        }];
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.doneButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.doneButton setTitle:@"使用" forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:255/255.0] forState:UIControlStateNormal];
        self.doneButton.layer.cornerRadius = 14;
        self.doneButton.backgroundColor = UIColor.whiteColor;
        self.doneButton.clipsToBounds = YES;
        [self.doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.doneButton];
        [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.width.mas_equalTo(56);
            make.height.mas_equalTo(28);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}
- (void)iconButtonAction:(UIButton *)sender {
    if (self.playerBlock) {
        self.playerBlock();
    }
}
- (void)doneButtonAction {
    if (self.didSelectedBlock) {
        self.didSelectedBlock();
    }
}
- (void)setItem:(MusicItem *)item {
    _item = item;
    _iconButton.selected = item.isPlaying;
    _titleLabel.text = item.name;
    _subTitleLabel.text = item.time;
}

@end

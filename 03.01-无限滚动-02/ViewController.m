//
//  ViewController.m
//  03.01-无限滚动-02
//
//  Created by 唐萌 on 16/3/1.
//  Copyright © 2016年 唐萌. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>

{
    UIScrollView * _scrollView;
    UIPageControl * _pageControl;
    NSTimer * _timer;
}

//图片源数据
@property(nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation ViewController



#pragma mark - 懒加载 -

//不可以给可变数组添加一个为nil的元素
-(NSMutableArray *)dataArray
{
    if (_dataArray==nil) {
        
        _dataArray = [[NSMutableArray alloc] init];
        
        //添加图片
        for (int i = 0; i<10; i++) {
            
            UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"25_%d.jpg",i+1]];
            
            [_dataArray addObject:image];
        }
        
    }
    
    return _dataArray;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatScrollView];
    
    [self creatPageControl];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(isMoving) userInfo:nil repeats:YES];
    
}


-(void)isMoving
{
    static int i = 0;
    if (i<=self.dataArray.count) {
        
        [_scrollView setContentOffset:CGPointMake((i+1)*_scrollView.frame.size.width, 0)];
        
        //更新点的位置
        
        _pageControl.currentPage = _scrollView.contentOffset.x/_scrollView.frame.size.width-1;
        i++;
        
        
        CGFloat lastX = _scrollView.frame.size.width*(self.dataArray.count+1);
        
        if (_scrollView.contentOffset.x == lastX) {
            //悄悄地切换到显示第一张图片的位置
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
            
            //真正的第一张图片的下标
            _pageControl.currentPage = 0;
            i =0;
            
        }

    }
    
    
}

#pragma mark - 创建界面 -

-(void)creatPageControl
{
    //1.创建pageControl
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,_scrollView.frame.size.height-20, _scrollView.frame.size.width, 20)];
    
    //2.设置总的分页数
    _pageControl.numberOfPages = self.dataArray.count;
    
    //3.添加到滚动视图的父视图上
    [self.view addSubview:_pageControl];
    
    //4.设置分页的颜色
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    
}



-(void)creatScrollView
{
    //1.创建滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    //2.根据图片数组创建imageView
    for (int i = 0; i<self.dataArray.count; i++) {
        
        //取出图片
        UIImage * image = self.dataArray[i];
        
        //创建图片对应的imageView
        //每张图片要往后顺延，留出位置在最前面存放最后一张图片
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i+1)*_scrollView.frame.size.width, 0,_scrollView.frame.size.width, _scrollView.frame.size.height)];
        
        //设置图片
        imageView.image = image;
        
        //将图片添加到滚动视图上
        [_scrollView addSubview:imageView];
        
    }
    
    //3.添加最前面的那张图片(显示的其实是最后一张图片，只是位置在最前面)
    UIImageView * firstImageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    
    //显示最后一张图片
    firstImageView.image = [self.dataArray lastObject];
    [_scrollView addSubview:firstImageView];
    
    //4.添加最后一张图片（显示的其实是第一章图片，只是位置在最后）
    
    CGFloat x = (self.dataArray.count + 1)*_scrollView.frame.size.width;
    UIImageView * lastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
    
    //显示第一张图片
    lastImageView.image = [self.dataArray firstObject];
    [_scrollView addSubview:lastImageView];
    
    //5.设置偏移量，默认显示第一张图片
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    
    //6.
    [self.view addSubview:_scrollView];
    
    //7.设置内容视图大小
    _scrollView.contentSize = CGSizeMake((self.dataArray.count+2)*_scrollView.frame.size.width, _scrollView.frame.size.height);
    
    //8.设置分页
    _scrollView.pagingEnabled = YES;
    
    //9.设置代理
    _scrollView.delegate = self;
}

#pragma mark - UIScrollViewDelegate -
//结束滚动的时候会调用这个方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //拿到当前滚动视图的偏移量
    CGFloat x = scrollView.contentOffset.x;
    
    //============判断是否已经滑动到最后一张=============
    CGFloat lastX = (self.dataArray.count+1)*_scrollView.frame.size.width;
    if (x ==lastX) {
        //悄悄地切换到显示第一张图片的位置
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        
        //真正的第一张图片的下标
        _pageControl.currentPage = 0;
        return;
    }
    //=============判断是否已经滑动到第一张===============
    CGFloat firstX = 0;
    if (x == firstX) {
        
        //悄悄的切换到真正显示最后一张图片的位置
        
        [_scrollView setContentOffset:CGPointMake(self.dataArray.count*_scrollView.frame.size.width, 0)];
        
        //真正的最后一张的下标
        _pageControl.currentPage = self.dataArray.count-1;
        return;
    }
    
    //===============正常显示的图片=================
    
    _pageControl.currentPage = x/_scrollView.frame.size.width - 1;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  MyWebView.m
//  MyWebView
//
//  Created by LOLITA on 2017/7/18.
//  Copyright © 2017年 LOLITA. All rights reserved.
//

#import "MyWebView.h"

@interface MyWebView()<WKNavigationDelegate>

@property (strong ,nonatomic) UIProgressView *progress;

@end

@implementation MyWebView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.webView];
        [self insertSubview:self.progress aboveSubview:self.webView];
    }
    return self;
}

-(WKWebView *)webView{
    if (_webView==nil) {
        _webView = [[WKWebView alloc] initWithFrame:self.bounds];
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        _webView.allowsBackForwardNavigationGestures = YES;
        [_webView goBack];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}


-(UIProgressView *)progress{
    if (_progress==nil) {
        _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progress.trackTintColor = [UIColor clearColor];
        _progress.progressTintColor = [UIColor redColor];
        _progress.frame = CGRectMake(0, 0, self.bounds.size.width, 1.5);
    }
    return _progress;
}



#pragma mark - <************************** 代理 **************************>
/// 开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"url:%@",webView.URL.absoluteString);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didStartWebView:)]) {
        [self.delegate didStartWebView:self];
    }
}
/// 获取到网页内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"获取到内容");
}
/// 加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"加载完成");
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didFinishWebView:)]) {
        [self.delegate didFinishWebView:self];
    }
}
/// 加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"加载失败");
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didFailWebView:)]) {
        [self.delegate didFailWebView:self];
    }
}



#pragma mark - <************************** kvo监听 **************************>
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 监听标题
    if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView){
            if (self.delegate&&[self.delegate respondsToSelector:@selector(didGetTitle:)]) {
                [self.delegate didGetTitle:self.webView.title];
            }
        }
        else
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // 监听进度
    else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webView) {
            NSLog(@"%f",self.webView.estimatedProgress);
            [self.progress setProgress:self.webView.estimatedProgress animated:YES];
            self.progress.hidden = self.progress.progress==1?YES:NO;
            self.progress.progress = self.progress.progress==1?0:self.progress.progress;
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}




#pragma mark - <************************** 私有方法 **************************>
-(void)loadUrlString:(NSString *)urlString{
    NSURL *URL = [NSURL URLWithString:urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}



#pragma mark - <************************** dealloc **************************>
-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}



@end

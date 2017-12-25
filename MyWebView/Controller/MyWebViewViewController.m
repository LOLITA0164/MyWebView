//
//  MyWebViewViewController.m
//  MyWebView
//
//  Created by LOLITA on 2017/7/18.
//  Copyright © 2017年 LOLITA. All rights reserved.
//

#import "MyWebViewViewController.h"
#import "MyWebView.h"

@interface MyWebViewViewController ()<MyWebViewDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (strong ,nonatomic) MyWebView *webView;

@end

@implementation MyWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.webView];
}


-(MyWebView *)webView{
    if (_webView==nil) {
        _webView = [[MyWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
        _webView.delegate = self;
        _webView.webView.UIDelegate = self;
        // 加载本地测试文件
        NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"JSCallOC.html" withExtension:nil];
        NSURLRequest *request = [NSURLRequest requestWithURL:filePath];
        [_webView.webView loadRequest:request];
        
        // 注册监听方法
        [_webView.webView.configuration.userContentController addScriptMessageHandler:self name:@"copyWeiXinHao"];
        [_webView.webView.configuration.userContentController addScriptMessageHandler:self name:@"goToWeiXinApp"];
        [_webView.webView.configuration.userContentController addScriptMessageHandler:self name:@"getCurrentContent"];
    }
    return _webView;
}















// !!!: WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"%s", __FUNCTION__);
}
// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%s", __FUNCTION__);
    NSString *contentString = [NSString stringWithFormat:@"内容:%@",message];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JS调用alert" message:contentString preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}
// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    NSLog(@"%s", __FUNCTION__);
    NSString *contentString = [NSString stringWithFormat:@"内容:%@",message];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JS调用confirm" message:contentString preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES); // 回传用户操作
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);  // 回传用户操作
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}
// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    NSString *contentString = [NSString stringWithFormat:@"内容:%@",prompt];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JS调用输入框" message:contentString preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor darkGrayColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}












// !!!: WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"copyWeiXinHao"]) {
        NSString *wxh = message.body;
        NSLog(@"微信号:%@",wxh);
        [self copyWeiXinHao:wxh];
    }
    else if ([message.name isEqualToString:@"getCurrentContent"]) {
        NSString *content = [self getCurrentContent];
        NSString *promptCode = [NSString stringWithFormat:@"getCurrentWeiXinHao(\"%@\")",content];
        [self.webView.webView evaluateJavaScript:promptCode completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        }];
    }
    else if ([message.name isEqualToString:@"goToWeiXinApp"]) {
        [self goToWeiXinApp];
    }
}
// 复制微信号
-(void)copyWeiXinHao:(NSString *)wxh{
    [[UIPasteboard generalPasteboard] setString:wxh];
}
// 当前剪切板信息
-(NSString*)getCurrentContent{
    return [[UIPasteboard generalPasteboard] string];
}
// 跳转微信应用
-(void)goToWeiXinApp{
    NSURL *url = [NSURL URLWithString:@"weixin://"];
    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    if (canOpen){   //打开微信
        [[UIApplication sharedApplication] openURL:url];
    }else {
        NSLog(@"您的设备尚未安装微信");
    }
}











// !!!: MyWebViewDelegate
-(void)didGetTitle:(NSString *)title{
    self.title = title;
}




-(void)dealloc{
    [self.webView.webView.configuration.userContentController removeAllUserScripts]; // 移除所有
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

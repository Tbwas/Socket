//
//  ViewController.m
//  Socket
//
//  Created by xindong on 16/2/24.
//  Copyright © 2016年 xindong. All rights reserved.
//

#import "ViewController.h"

#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>

static int const port         = 2016;                //端口号
static NSString *const domain = @"192.168.1.165";    //IP地址

typedef struct sockaddr_in SocketAddr_in;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
@property (weak, nonatomic) IBOutlet UILabel *receiveLabel;
@property (nonatomic) int        clientSocket;     //客户端socket
@property (nonatomic) SocketAddr_in serverAddress; //服务端socket地址

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     *  创建客户端socket
     *
     *  @param AF_INET     协议域，AF_INET（IPV4的网络开发）
     *  @param SOCK_STREAM Socket 类型，SOCK_STREAM(TCP)/SOCK_DGRAM(UDP)
     *  @param 0           IPPROTO_TCP，协议，如果输入0，可以根据第二个参数，自动选择协议
     *
     *  @return 返回值大于0表示成功
     */
    _clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    if (_clientSocket > 0) {
        NSLog(@"create socket success %d", _clientSocket);
    }
    else {
        NSLog(@"create socket error");
    }
    
}

// 连接
- (IBAction)connectToServer:(UIButton *)sender
{
    _serverAddress.sin_family = AF_INET; //协议类型
    _serverAddress.sin_addr.s_addr = inet_addr(domain.UTF8String); //inet_addr函数可以把ip地址转换成一个整数
    _serverAddress.sin_port = htons(port); //端口
    
    int connectResult = connect(_clientSocket, (const struct sockaddr *)&_serverAddress, sizeof(_serverAddress));
    
    if (connectResult == 0) {
        NSLog(@"connect success %d", connectResult);
    }
    else {
        NSLog(@"connect error");
    }

}


// 消息的发送与接收
- (IBAction)clickedSendMessageAction:(UIButton *)sender
{
    NSString *receiveMessages = [self sendAndReceiveMessages:self.sendTextField.text];
    self.receiveLabel.text = receiveMessages;
}

- (NSString *)sendAndReceiveMessages:(NSString *)sendMessages
{
    /**
     *  发送消息
     *
     *  @param _clientSocket                 客户端socket
     *  @param sendMessages.UTF8String       发送内容的地址
     *  @param strlensendMessages.UTF8String 发送内容长度
     *  @param 0                             发送方式标志，通常为0
     *
     *  @return 如果成功，则返回发送的字节数；失败，返回SOCKET_ERROR
     */
    ssize_t sendLength = send(_clientSocket, sendMessages.UTF8String, strlen(sendMessages.UTF8String), 0);
    NSLog(@"--%ld", sendLength);
    
    
    /**
     *  接收消息
     *
     *  @param _clientSocket 客户端socket
     *  @param buffer        接收内容地址
     *  @param sizeofbuffer  接收内容长度
     *  @param 0             接收数据的标记，0阻塞式，一直等待服务器的数据。
     *
     *  @return 返回接收到的数据长度
     */
    uint8_t buffer[1024];
    ssize_t receiveLength = recv(_clientSocket, buffer, sizeof(buffer), 0);
    
    NSData *data = [NSData dataWithBytes:buffer length:receiveLength];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received messages: %@", str);
    
    return str;
}


// 关闭socket
- (IBAction)disconnectFromServer:(UIButton *)sender
{
    close(_clientSocket);
}


/* 参考资料：http://www.jianshu.com/p/cc756016243b */




@end

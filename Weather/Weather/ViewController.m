//
//  ViewController.m
//  Weather
//
//  Created by 张铭杰 on 16/2/17.
//  Copyright © 2016年 张铭杰. All rights reserved.
//

#import "ViewController.h"
#import "XMLReader.h"
#import <time.h>
#import "YQL.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <CommonCrypto/CommonDigest.h>

@interface ViewController (){
    NSTimer *mytimer1;
    NSTimer *mytimer2;
    NSString *myip;
    NSString *url;
    NSURL *URL;
    NSURLRequest *request;
    NSData *city;
    NSDictionary *CITY;
    NSData *code;
    NSDictionary *CODE;
    NSArray *subArray;
    NSMutableDictionary *tempDic;
    NSArray *dicArray;
    NSString *citycode;
    Boolean j;
    YQL *yql;
    NSString *queryString;
    NSDictionary *results;
    NSString *chill;
    float temp;
    NSString *speed;
    float wind;
    NSString *date;
    NSString *weather;
    NSString *high;
    NSString *low;
    NSRange range1;
    NSRange range2;
    NSString *Pressure;
    float atmo;
    NSString *Visibility;
    float distance;
    NSString *Humidity;
    NSString *Sunrise;
    NSString *Sunset;
    NSString *From;
    NSString *Time;
    UIImage *image;
    NSData *Image;
    NSArray *DATE;
    NSArray *WEATHER;
    NSArray *HIGH;
    NSArray *LOW;
    UILabel *it;
    NSString *sign;
    NSData *baidu;
    NSDictionary *BAIDU;
    int i;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    j=true;
    mytimer1 =  [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(timerAction1) userInfo:nil repeats:YES];
    [mytimer1 setFireDate:[NSDate distantPast]];
    DATE=[NSArray arrayWithObjects:_Date0,_Date1,_Date2,_Date3,_Date4, nil];
    WEATHER=[NSArray arrayWithObjects:_Weather0,_Weather1,_Weather2,_Weather3,_Weather4, nil];
    HIGH=[NSArray arrayWithObjects:_High0,_High1,_High2,_High3,_High4, nil];
    LOW=[NSArray arrayWithObjects:_Low0,_Low1,_Low2,_Low3,_Low4, nil];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) timerAction1{
    myip=[self Getmyip];
    _Ip.text=[@"IP:" stringByAppendingString:myip];
    
    url=@"http://ip.taobao.com/service/getIpInfo.php?ip=";
    url=[url stringByAppendingString:myip];
    URL = [NSURL URLWithString:url];
    request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    // 创建同步链接
    NSURLResponse *response = nil;
    NSError *error = nil;
    city = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    CITY = [NSJSONSerialization JSONObjectWithData:city options:0 error:&error];
    _City.text=[CITY[@"data"][@"city"] isEqual:@""]? @"杭州市":CITY[@"data"][@"city"];
    
    url=@"http://sugg.us.search.yahoo.net/gossip-gl-location/?appid=weather&output=xml&command=";
    url=[url stringByAppendingString:[CITY[@"data"][@"city"] isEqual:@""]? @"杭州市":CITY[@"data"][@"city"]];
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    URL = [NSURL URLWithString:url];
    request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    // 创建同步链接
    response = nil;
    code = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    CODE = [XMLReader dictionaryForXMLData:code error:&error];
    
    subArray = [CODE[@"m"][@"s"][1][@"d"] componentsSeparatedByString:@"&"];
    //把subArray转换为字典
    //tempDic中存放一个URL中转换的键值对
    tempDic = [NSMutableDictionary dictionaryWithCapacity:4];
    for (int k = 0 ; k < subArray.count; k++)
    {
        //在通过=拆分键和值
        dicArray = [subArray[k] componentsSeparatedByString:@"="];
        [tempDic setObject:dicArray[1] forKey:dicArray[0]];
    }
    citycode=tempDic[@"woeid"]? tempDic[@"woeid"]:@"2132574";
    
    _Cod.text=[@"CODE:" stringByAppendingString:citycode];
    _Engl.text=tempDic[@"n"];
    
    if(j==true)
    {
        mytimer2 =  [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(timerAction2) userInfo:nil repeats:YES];
        [mytimer2 setFireDate:[NSDate distantPast]];
    }
}

-(void) timerAction2{
    yql = [[YQL alloc] init];
    queryString = @"select * from weather.forecast where woeid=";
    queryString =[queryString stringByAppendingString:citycode];
    results = [yql query:queryString];

    url=results[@"query"][@"results"][@"channel"][@"image"][@"url"];
    URL = [NSURL URLWithString:url];
    request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    // 创建同步链接
    NSURLResponse *response = nil;
    NSError *error = nil;
    Image= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    image = [UIImage imageWithData:Image];
    _yahoo.image=image;
    
    url=@"http://l.yimg.com/a/i/us/nws/weather/gr/";
    url=[url stringByAppendingString:results[@"query"][@"results"][@"channel"][@"item"][@"condition"][@"code"]];
    url=[url stringByAppendingString:@"d.png"];
    URL = [NSURL URLWithString:url];
    request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    response = nil;
    error = nil;
    Image= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    image = [UIImage imageWithData:Image];
    _weatherview.image=image;

    chill=results[@"query"][@"results"][@"channel"][@"wind"][@"chill"];
    temp=[chill floatValue];
    temp=(temp-32)/1.8;
    chill=[NSString stringWithFormat:@"%.0f",temp];
    chill=[chill stringByAppendingString:@"°"];
    _Win.text=chill;
    
    speed=results[@"query"][@"results"][@"channel"][@"wind"][@"speed"];
    wind=[speed floatValue];
    wind=wind*1.6;
    speed=[NSString stringWithFormat:@"%.0f",wind];
    speed=[@"风速:" stringByAppendingString:speed];
    speed=[speed stringByAppendingString:@"km/h"];
    _Spee.text=speed;
    
    Visibility =results[@"query"][@"results"][@"channel"][@"atmosphere"][@"visibility"];
    distance=[Visibility  floatValue];
    distance=distance*1.6;
    Visibility=[NSString stringWithFormat:@"%.2f",distance];
    Visibility=[@"可见:" stringByAppendingString:Visibility];
    Visibility=[Visibility stringByAppendingString:@"km"];
    _visibility.text=Visibility;
    
    Pressure =results[@"query"][@"results"][@"channel"][@"atmosphere"][@"pressure"];
    atmo=[Pressure  floatValue];
    atmo=atmo*2.54/76;
    Pressure=[NSString stringWithFormat:@"%.2f",atmo];
    Pressure=[@"气压:" stringByAppendingString:Pressure];
    Pressure=[Pressure stringByAppendingString:@"atm"];
    _pressure.text=Pressure;
    
    Humidity =results[@"query"][@"results"][@"channel"][@"atmosphere"][@"humidity"];
    Humidity=[@"湿度:" stringByAppendingString:Humidity];
    Humidity=[Humidity stringByAppendingString:@"%"];
    _humidity.text=Humidity;
    
    Sunrise=results[@"query"][@"results"][@"channel"][@"astronomy"][@"sunrise"];
    Sunrise=[@"日出:" stringByAppendingString:Sunrise];
    _sunrise.text=Sunrise;
    
    Sunset=results[@"query"][@"results"][@"channel"][@"astronomy"][@"sunset"];
    Sunset=[@"日落:" stringByAppendingString:Sunset];
    _sunset.text=Sunset;
    
    Time=results[@"query"][@"results"][@"channel"][@"item"][@"condition"][@"date"];
    _time.text=Time;
    
    From=results[@"query"][@"results"][@"channel"][@"description"];
    From=[@"From:" stringByAppendingString:From];
    _from.text=From;

    i=0;
    for (it in DATE ){
        date=results[@"query"][@"results"][@"channel"][@"item"][@"forecast"][i][@"date"];
        date= [date stringByReplacingOccurrencesOfString:@" 2016" withString:@""];
        it.text=date;
        i++;
    }i=0;

    for (it in WEATHER){
        weather=results[@"query"][@"results"][@"channel"][@"item"][@"forecast"][i][@"text"];
        it.text=weather;
        i++;
    }i=0;
    
    for (it in HIGH){
        high=results[@"query"][@"results"][@"channel"][@"item"][@"forecast"][i][@"high"];
        temp=[high floatValue];
        temp=(temp-32)/1.8;
        high=[NSString stringWithFormat:@"%.0f",temp];
        high=[high stringByAppendingString:@"°C"];
        it.text=high;
        i++;
    }i=0;
    
    for (it in LOW){
        low=results[@"query"][@"results"][@"channel"][@"item"][@"forecast"][i][@"low"];
        temp=[low floatValue];
        temp=(temp-32)/1.8;
        low=[NSString stringWithFormat:@"%.0f",temp];
        low=[low stringByAppendingString:@"°C"];
        it.text=low;
        i++;
    }
}

- (NSString *) Getmyip
{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.0tz.me"];
    NSString *Ip = [NSString stringWithContentsOfURL:ipURL encoding:1 error:&error];
    return Ip ? Ip : [error localizedDescription];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

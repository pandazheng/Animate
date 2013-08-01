//
//  GameScene.m
//  Animate
//
//  Created by panda zheng on 13-8-1.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

-(id) init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    //加载背景资源
    [self loadBG];
    
    //加载人物
    [self loadActor];
    
    CCLayer *layer = [CCLayer node];
    //背景精灵以bg_0为初始帧
    m_background = [CCSprite spriteWithSpriteFrameName:@"bg_0"];
    [m_background setPosition:CGPointMake(240, 160)];
    //人物精灵以stand为初始帧
    m_kyo = [CCSprite spriteWithSpriteFrameName:@"stand"];
    [m_kyo setPosition:CGPointMake(240, 120)];
    [layer addChild:m_background z:0 tag:1];
    [layer addChild:m_kyo z:1 tag:2];
    [self addChild: layer];
    //生成动画行为
    [self makeAnimation];
    return self;
}

-(void) loadBG
{
    //加载背景资源到内存中，共4帧
    for (int i = 0 ; i < 4 ; i ++)
    {
        //生成文件名bg_0.png~bg_3.png
        NSString *fileName = [NSString stringWithFormat:@"bg_%d.png",i];
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTextureFilename:fileName rect:CGRectMake(0, 0, 450, 330)];
        //将frame加入内存池
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:[fileName stringByDeletingPathExtension]];
    }
}


-(void) loadActor
{
    //加载人物的站立资源到内存中，只有1帧
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTextureFilename:@"stand.png" rect:CGRectMake(0, 0, 292, 221)];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:@"stand"];
    
    //加载人物的出拳资源到内存中，共2帧
    for (int i = 0 ; i < 2 ; i++)
    {
        //虽然是2帧，但这两个资源是存在一张图片中的，因些读取的文件名相同，通过不同的rect剪裁，区分
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTextureFilename:@"punch.png" rect:CGRectMake(i * 292, 0, 292, 221)];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:[NSString stringWithFormat:@"punch_%d",i]];
    }
    
    //加载人物的出拳资源到内存中，共4帧
    for (int i = 0 ; i < 5 ; i++)
    {
        //4个资源在一张图片中
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTextureFilename:@"kick.png" rect:CGRectMake(i * 292, 0, 292, 221)];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:[NSString stringWithFormat:@"kick_%d",i]];
    }
}

-(void) makeAnimation
{
    NSMutableArray *array = [NSMutableArray array];
    
    //生成背景图动画，共4帧
    for (int i = 0 ; i < 4 ; i++)
    {
        NSString *key = [NSString stringWithFormat:@"bg_%d",i];
        //从内存池中取出Frame
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        //添加到序列中
        [array addObject:frame];
    }
    
    //将数组转化为动画序列，换帧间隔0.1秒
    CCAnimation *animBG = [CCAnimation animationWithSpriteFrames:array delay:0.1f];
    //生成动画播放的行为对象
    id actBG = [CCAnimate actionWithAnimation:animBG];
    //清空缓存数组
    [array removeAllObjects];
    
    //生成出拳动画，共3帧
    for (int i = 0 ; i < 2 ; i++)
    {
        NSString *key = [NSString stringWithFormat:@"punch_%d",i];
        //从内存池中取出Frame
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [array addObject:frame];
    }
    
    //添加完punch_0和punch_1后，再重复一次punch_0,因为准备动作和收招的图片是相同的，这里用一帧播放两遍的形式节省内存
    [array addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"punch_0"]];
    //将数组转化为动画序列，换帧间隔0.06秒
    CCAnimation *animPunch = [CCAnimation animationWithSpriteFrames:array delay:0.06f];
    //生成出拳动画的行为对象
    id actPunch = [CCAnimate actionWithAnimation:animPunch];
    [array removeAllObjects];
    
    //生成出拳动画，共6帧
    for (int i = 0 ; i < 4 ; i++)
    {
        NSString *key = [NSString stringWithFormat:@"kick_%d",i];
        //从内存池中取出Frame
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:key];
        [array addObject:frame];
    }
    //重复一次kick_1，原因同上
    [array addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"kick_1"]];
    //添加帧kick_4
    [array addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"kick_4"]];
    //这并不是kick动画的成员，而是作为动画结束后的还原帧而加入队列的，作用是使踢腿动作结束后恢复站立
    [array addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"stand"]];
    //将数组转化为动画序列，换帧间隔为0.05秒
    CCAnimation *animKick = [CCAnimation animationWithSpriteFrames:array delay:0.05f];
    //生成踢腿动画的行为对象
    id actKick = [CCAnimate actionWithAnimation:animKick];
    [array removeAllObjects];
    
    //精灵行为runAction方法激活行为对象
    [m_background runAction:[CCRepeatForever actionWithAction:actBG]];
    id actDelay = [CCDelayTime actionWithDuration:1];
    //因为两次delay是完全无关的两个行为，因些这里用了copy，避免行为进度发生错乱
    id attack = [CCSequence actions:actDelay,actPunch,[actDelay copy],actKick, nil];
    [m_kyo runAction:[CCRepeatForever actionWithAction:attack]];
}

@end

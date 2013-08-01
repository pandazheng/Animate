//
//  GameScene.h
//  Animate
//
//  Created by panda zheng on 13-8-1.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCScene {
    CCSprite *m_background;
    CCSprite *m_kyo;
}

-(void) loadBG;
-(void) loadActor;
-(void) makeAnimation;

@end

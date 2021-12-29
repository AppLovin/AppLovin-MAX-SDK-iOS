//
//  ALMaioMediationAdapter.h
//  MaioAdapter
//
//  Created by Harry Arakkal on 7/1/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import <Maio/Maio.h>
#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALMaioMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedAdapter>
    
@end

NS_ASSUME_NONNULL_END

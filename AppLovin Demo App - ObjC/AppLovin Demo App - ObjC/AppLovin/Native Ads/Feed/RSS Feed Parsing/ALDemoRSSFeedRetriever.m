//
//  ALDemoRSSFeedRetriever.m
//  iOS-SDK-Demo
//
//  Created by Thomas So on 11/12/15.
//  Copyright © 2015 AppLovin. All rights reserved.
//

#import "ALDemoRSSFeedRetriever.h"

@interface ALDemoRSSFeedRetriever()<NSXMLParserDelegate>
@property (nonatomic,   copy, nullable) NSString      *currentElementName;
@property (nonatomic, strong, nullable) ALDemoArticle *currentArticle;

@property (nonatomic, strong) NSMutableArray<ALDemoArticle *> *articles;
@property (nonatomic,   copy) ALDemoRSSFeedRetrieverBlock completionBlock;
@end

@implementation ALDemoRSSFeedRetriever
static NSString *const kRSSFeedURL = @"https://blog.applovin.com/feed/";

+ (ALDemoRSSFeedRetriever *)sharedRetriever
{
    static dispatch_once_t pred;
    static ALDemoRSSFeedRetriever *manager = nil;
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.articles = [NSMutableArray array];
    }
    return self;
}

- (void)startParsingWithCompletion:(ALDemoRSSFeedRetrieverBlock)completion
{
    // Do not retrieve if we already have retrieved some artivcles, just call completion
    if ( self.articles.count > 0 )
    {
        completion( nil, [NSArray arrayWithArray: self.articles] );
    }
    else
    {
        self.completionBlock = completion;
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL: [NSURL URLWithString: kRSSFeedURL]];
        [parser setDelegate: self];
        [parser parse];
    }
}

#pragma mark - Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.currentElementName = elementName;
    if ( [elementName isEqualToString: @"item"] )
    {
        // Start of the parsing of a new article
        
        if ( self.articles.count == 3 )
        {
            // Lets place an ad in the 4th slot
            ALDemoArticle *adFauxArticle = [[ALDemoArticle alloc] init];
            adFauxArticle.isAd = YES;
            [self.articles addObject: adFauxArticle];
        }
        
        self.currentArticle = [[ALDemoArticle alloc] init];
        [self.articles addObject: self.currentArticle];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ( self.currentArticle )
    {
        if ( [self.currentElementName isEqualToString: @"title"] )
        {
            self.currentArticle.title = string;
        }
        else if ( [self.currentElementName isEqualToString: @"link"] )
        {
            self.currentArticle.link = [NSURL URLWithString: string];
        }
        else if ( [self.currentElementName isEqualToString: @"pubDate"] )
        {
            self.currentArticle.pubDate = [string substringToIndex: 11];
        }
        else if ( [self.currentElementName isEqualToString: @"dc:creator"] )
        {
            self.currentArticle.creator = string;
        }
        else if ( [self.currentElementName isEqualToString: @"description"] )
        {
            self.currentArticle.articleDescription = [string stringByReplacingOccurrencesOfString: @"[&#8230;]" withString: @"..."];
        }
        
        // Reset current element name after we finish setting it
        self.currentElementName = @"";
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.completionBlock( nil, [NSArray arrayWithArray: self.articles] );
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.completionBlock( parseError, @[] );
}

@end

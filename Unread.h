#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface CKConversationListController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    UITableView *_table;
}

- (void)_chatUnreadCountDidChange:(id)arg1;
- (void)conversationWillBeMarkedRead:(id)arg1;
- (void)noteUnreadCountsChanged;
- (void)updateConversationList;
@end

@interface CKConversationListCell : UITableViewCell
@property(retain) NSDate * searchMessageDate;
@property(copy) NSString * searchMessageGUID;
@property(copy) NSString * searchSummaryText;
@end

@interface CKConversationList : NSObject
+ (id)sharedConversationList;
- (id)conversations;
@end

@interface IMChat : NSObject
- (void)_setDBUnreadCount:(unsigned int)arg1;
@end

@interface CKConversation : NSObject
@property(retain) IMChat *chat;
@property(readwrite) BOOL hasUnreadMessages;
@property(readwrite) BOOL hasUnreadiMessages;
@property(readwrite) unsigned int unreadCount;
@end
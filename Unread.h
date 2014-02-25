#include <UIKit/UIKit.h>
#include <CoreGraphics/CoreGraphics.h>
#include <objc/runtime.h>

/*********************************** IMCore ************************************/

@interface IMMessage : NSObject
@property(readwrite) BOOL isRead;
@end

@interface IMChat : NSObject
@property(readonly) IMMessage *lastIncomingMessage;

- (void)__clearReadMessageCache;
- (void)_updateUnreadCount;
- (void)_setDBUnreadCount:(unsigned int)arg1;
@end

@interface IMChatRegistry : NSObject
+ (id)sharedInstance;
- (void)_updateUnreadCountForChat:(id)arg1;
@end

@interface IMDChatRegistry : NSObject
+ (id)sharedInstance;
- (BOOL)updateUnreadCountForChat:(id)arg1;
@end

@interface IMDaemonController : NSObject
- (void)listener:(id)arg1 setValue:(id)arg2 ofPersistentProperty:(id)arg3;
- (void)listener:(id)arg1 setValue:(id)arg2 ofProperty:(id)arg3;
@end

/*********************************** ChatKit ***********************************/

@interface CKConversation : NSObject
@property(retain) IMChat *chat;
@property(readwrite) unsigned int unreadCount;
@end

@interface CKConversationList : NSObject
+ (id)sharedConversationList;
- (id)conversations;
@end

@interface CKConversationListCell : UITableViewCell
@end

@interface CKConversationListController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    UITableView *_table;
}

- (void)_chatUnreadCountDidChange:(id)arg1;
@end
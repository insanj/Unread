#import "Unread.h"

@interface CKConversationListController (Unread)
-(void)ur_markUnread:(UILongPressGestureRecognizer *)sender;
@end

%hook CKConversationListController

%new -(void)ur_markUnread:(UILongPressGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
		CKConversationListCell *cell = (CKConversationListCell *) sender.view;
		UITableView *table = MSHookIvar<UITableView *>(self, "_table");
		CKConversation *conversation = [[[%c(CKConversationList) sharedConversationList] conversations] objectAtIndex:[table indexPathForCell:cell].row];

		IMChatRegistry *sharedRegistry = [%c(IMChatRegistry) sharedInstance];
		unsigned int daemonUnread = MSHookIvar<unsigned int>(sharedRegistry, "_daemonUnreadCount");

		if(conversation.unreadCount == 0){
			NSLog(@"[Unread] Detected long-press on %@, marking %@ as unread...", cell, conversation);
			[conversation.chat _setDBUnreadCount:conversation.unreadCount+1];
			[self _chatUnreadCountDidChange:conversation.chat];
			[sharedRegistry unreadCountChanged:(daemonUnread+1)];
			[sharedRegistry _updateUnreadCountForChat:conversation.chat];
		}

		else{
			NSLog(@"[Unread] Detected long-press on %@, marking %@ as read...", cell, conversation);
			[sharedRegistry unreadCountChanged:(daemonUnread-conversation.unreadCount)];
			[conversation.chat _setDBUnreadCount:0];
			[self _chatUnreadCountDidChange:conversation.chat];
			[sharedRegistry _updateUnreadCountForChat:conversation.chat];
		}

	}
}

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2{
    CKConversationListCell *cell = %orig;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(ur_markUnread:)];
	[cell addGestureRecognizer:longPress];
	[longPress release];

    return cell;
}

%end

%hook IMChatRegistry

- (void)_chat:(id)arg1 setValue:(id)arg2 forChatProperty:(id)arg3{
	%log;
	%orig();
}

- (void)_updateUnreadCountForChat:(id)arg1{
	%log;
	%orig();
}

- (void)unreadCountChanged:(int)arg1{
	%log;
	%orig();
}

%end
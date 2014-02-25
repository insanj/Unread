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

		int unreadCount = conversation.unreadCount;
		if(unreadCount == 0){
			NSLog(@"[Unread] Detected long-press on %@, marking %@ as unread...", cell, conversation);
			unreadCount++;
			
			[conversation.chat _setDBUnreadCount:unreadCount];
			[self _chatUnreadCountDidChange:conversation.chat];
			MSHookIvar<unsigned int>(conversation.chat, "_cachedUnreadCount") = unreadCount;
			//[conversation.chat _recalculateCachedUnreadCount];
		}

		else{
			NSLog(@"[Unread] Detected long-press on %@, marking %@ as read...", cell, conversation);
			unreadCount = 0;

			[conversation.chat _setDBUnreadCount:0];
			[self _chatUnreadCountDidChange:conversation.chat];
			MSHookIvar<unsigned int>(conversation.chat, "_cachedUnreadCount") = unreadCount;
			//[conversation.chat _recalculateCachedUnreadCount];
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

%hook IMChat

- (unsigned int)_recalculateCachedUnreadCount{
	%log;
	NSLog(@"----- %i", (int)%orig);
	return %orig();
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
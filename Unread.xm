#import "Unread.h"

@interface CKConversationListController (Unread)
-(void)ur_markUnread:(UILongPressGestureRecognizer *)sender;
@end

static char * kUnreadAmount;

%hook CKConversationListController

%new -(void)ur_markUnread:(UILongPressGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
		CKConversationListCell *cell = (CKConversationListCell *) sender.view;
		UITableView *table = MSHookIvar<UITableView *>(self, "_table");
		CKConversation *conversation = [[[%c(CKConversationList) sharedConversationList] conversations] objectAtIndex:[table indexPathForCell:cell].row];

		int unreadCount = conversation.unreadCount;
		if(unreadCount == 0){
			NSLog(@"[Unread] Detected long-press on %@, marking %@ as unread...", cell, conversation);
			[conversation.chat _setDBUnreadCount:++unreadCount];
		}

		else{
			NSLog(@"[Unread] Detected long-press on %@, marking %@ as read...", cell, conversation);
			[conversation.chat _setDBUnreadCount:((unreadCount = 0))];
		}

		[self _chatUnreadCountDidChange:conversation.chat];
		objc_setAssociatedObject(conversation.chat, &kUnreadAmount, @(unreadCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[conversation.chat _recalculateCachedUnreadCount];
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
	unsigned int recalcValue = [objc_getAssociatedObject(self, &kUnreadAmount) intValue] + %orig();
	objc_setAssociatedObject(self, &kUnreadAmount, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return recalcValue;
}

%end
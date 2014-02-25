#import "Unread.h"

@interface CKConversationListController (Unread)
-(void)ur_gestureRecognized:(UISwipeGestureRecognizer *)sender;
@end

%hook CKConversationListController

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2{
    CKConversationListCell *cell = %orig;

    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(ur_gestureRecognized:)];
	[cell addGestureRecognizer:swipeRecognizer];
	[swipeRecognizer release];

    return cell;
}

%new -(void)ur_gestureRecognized:(UISwipeGestureRecognizer *)sender{
	if(sender.direction == UISwipeGestureRecognizerDirectionRight) {
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
	}
}

%end

/*
%hook IMDaemonController

- (void)listener:(id)arg1 setValue:(id)arg2 ofPersistentProperty:(id)arg3{
	%log;
	%orig();
}

- (void)listener:(id)arg1 setValue:(id)arg2 ofProperty:(id)arg3{
	%log;
	%orig();
}

%end
*/
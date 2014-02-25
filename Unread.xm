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
		IMMessage *lastMessage = [conversation.chat lastMessage];
		[conversation.chat __clearReadMessageCache];

		if(lastMessage.isRead){
			NSLog(@"[Unread] Detected swipe on %@, marking %@ as unread...", cell, conversation);
			lastMessage = [[IMMessage alloc] initWithSender:lastMessage.sender time:lastMessage.time text:lastMessage.text messageSubject:lastMessage.messageSubject fileTransferGUIDs:lastMessage.fileTransferGUIDs flags:lastMessage.flags error:lastMessage.error guid:lastMessage.guid subject:lastMessage.subject];
			//[conversation.chat _setDBUnreadCount:++unreadCount];
		}

		else{
			NSLog(@"[Unread] Detected swipe on %@, marking %@ as read...", cell, conversation);
			[lastMessage _updateTimeRead:[NSDate date]];
			//[conversation.chat _setDBUnreadCount:((unreadCount = 0))];
		}

		[conversation.chat _updateUnreadCount];
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
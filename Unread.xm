#import "Unread.h"
#define URMarkButtonTag (sizeof("UnreadMarkButton") << 8)

@interface CKConversationListController (Unread)
-(void)ur_gestureRecognized:(UISwipeGestureRecognizer *)sender;
-(void)ur_show:(BOOL)should withButton:(UIButton *)button;
-(void)ur_markUnread:(NSArray *)items;
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
	if(sender.direction == UISwipeGestureRecognizerDirectionRight && ![sender.view.superview viewWithTag:URMarkButtonTag]) {
		UIButton *markButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		markButton.backgroundColor = [UIColor colorWithRed:0/255.0f green:116/255.0f blue:217/255.0f alpha:1.0f];
		markButton.layer.masksToBounds = YES;
		markButton.layer.cornerRadius = 35.0 / 2.0;
		markButton.tag = URMarkButtonTag;
		[markButton addTarget:self action:(SEL)[self performSelector:@selector(ur_markUnread:) withObject:@[markButton, sender]] forControlEvents:UIControlEventTouchUpInside];

		CGRect frame = sender.view.frame;
		frame.size.height =	frame.size.width = 35.0;
		frame.origin.x = -frame.size.width;
		markButton.frame = frame;
		
		[sender.view.superview addSubview:markButton];
		[self ur_show:YES withButton:markButton];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			[self ur_show:NO withButton:markButton];
		});
	}
}

%new -(void)ur_show:(BOOL)should withButton:(UIButton *)button{
	CGRect shift = button.frame;
	shift.origin.x = should ? CGRectGetMinX(button.superview.frame) + 5.0 : -CGRectGetWidth(button.frame);
	[UIView animateWithDuration:0.2 animations:^(void){
		button.frame = shift;
	} completion:^(BOOL finished){
		if(!should)
			[button removeFromSuperview];
	}];
}

%new -(void)ur_markUnread:(NSArray *)items{
	[self ur_show:NO withButton:items[0]];

	CKConversationListCell *cell = (CKConversationListCell *) ((UISwipeGestureRecognizer *)items[1]).view;
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
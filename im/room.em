
system.require('imUtil.em');
system.require('friend.em');
system.require('roomGui.em');
system.require('std/http/http.em');

(function()
 {

     /**
      For each chat room, one presence controls chat room and
      coordinates it.  To all other presences, it looks just like a
      friend.  
      */
     

     /**
      @param {String-tainted} name - Self-reported name of room to
      create.

      @param {AppGui} appGui

      @param {unique int} rmID - Room ID.  
      */
     Room = function(name,appGui,rmID)
     {
         this.myName = name;
         this.loggingAddress = null;
         this.friendArray = [];
         this.appGui = appGui;
         this.rmID   = rmID;
         this.roomGui = new RoomGui(IMUtil.getUniqueInt(),this);
         this.roomChatGui = new ConvGUI(this.myName, new DummyConvGuiFriend(this));
     };


     //only must implement msgToFriend.
     function DummyConvGuiFriend(room)
     {
         this.mRoom = room;
     }

     DummyConvGuiFriend.prototype.msgToFriend = function(msg)
     {
         this.mRoom.writeFriend(msg,null,true);
     };
     

     Room.prototype.showManageGui = function()
     {
         this.roomGui.show();  
     };

     Room.prototype.showChatGui = function()
     {
         this.roomChatGui.show();
     };
     
     Room.prototype.setName = function(newName)
     {
         this.myName = newName;
         this.appGui.display();
     };

     Room.prototype.setLoggingAddress = function(newLoggingAddress)
     {
         if (newLoggingAddress == '')
             this.loggingAddress = null;
         else
             this.loggingAddress = newLoggingAddress;
     };

     /**
      @param {Friend} friendToAdd - Should not already exist in
      room.  Prints warning if does.
      */
     Room.prototype.addFriend = function(friendToAdd)
     {
         for (var s in this.friendArray)
         {
             if (this.friendArray[s].imID == friendToAdd.imID)
             {
                 IMUtil.dPrint('\nAlready have a friend with this id '+
                               'in the room.  Doing nothing.\n');
                 return;
             }
         }
         
         var newFriend = new Friend(
             friendToAdd.name,friendToAdd.vis,
             this,IMUtil.getUniqueInt(),this,
             Friend.RoomType.RoomCoordinator,null);

         //actually add to array.
         this.friendArray.push(newFriend);
         //notify appGui of new friend.
         this.appGui.addRoomFriend(newFriend);
     };


     /**
      @param {Friend} friendToRemove - Should already exist in room.
      After calling this, kills friend.
      */
     Room.prototype.removeFriend = function (friendToRemove)
     {
         for (var s in this.friendArray)
         {
             if (this.friendArray[s].imID == friendToRemove.imID)
             {
                 delete this.friendArray[s];
                 removeFriend.kill();
                 break;
             }
         }

         //updates chat list.
         this.display();
     };
     
     
     //appGui functionality used by friend

     /**
      called when a friend has changed status, initially created
      itself,changed its connection status (either open or closed).
      
      Sends a chatList message to all friends that are still enabled.
      */
     Room.prototype.display = function()
     {
         var chatList = [];
         for (var s in this.friendArray)
         {
             if (this.friendArray[s].canSend())
                 chatList.push(this.friendArray[s].vis.toString());
         }

         for (var s in this.friendArray)
         {
             if (this.friendArray[s].canSend())
                 this.friendArray[s].sendChatList(chatList);
         }
         
         IMUtil.dPrint('\nGot a request to display in Room.em\n');
     };

     /**
      @param {String - tainted} message to warn.  Called by friend
      whenever need to display a warning message.  Generally, we can
      ignore these in Room.
      */
     Room.prototype.warn = function(warnMsg)
     {
         IMUtil.dPrint('\nIgnoring warning messages in Room  ');
         IMUtil.dPrint(warnMsg);
         IMUtil.dPrint('\n\n');
     };

     Room.prototype.remove = function(imID)
     {
         IMUtil.dPrint('\n\nFIXME: allow users to be removed from group.\n\n');
     };

     Room.prototype.getIsVisibleTo = function(imID )
     {
         IMUtil.dPrint('\n\nCalled getIsVisibleTo in room.\n\n');
         return true;
     };
     

     //convGUI functionality used by friend

     /**
      Called when user sends a message to a friend.  
      */
     Room.prototype.writeMe = function(toWrite)
     {
         IMUtil.dPrint('\n\nIgnoring writeMe call.  Will need to ' +
                       'display message that I entered separately\n\n');
     };

     
     /**
      Called when receive message from friend.  Run through list of
      all friends.  For all friends that are connected, forward the
      message.

      @param {bool} isMe (optional) -- If true, means that the owner
      of the group is trying to write a message.  In this case, friendMsgFrom is null
      */
     Room.prototype.writeFriend = function(toWrite,friendMsgFrom, isMe)
     {

         if (typeof(isMe) == 'undefined')
             isMe = false;

         var friendFrom = '';
         if (isMe)
             friendFrom = system.self.toString();
         else
             friendFrom = friendMsgFrom.vis.toString();
         

         for (var s in this.friendArray)
         {
             if (this.friendArray[s] == friendMsgFrom)
                 continue;
             
             if (this.friendArray[s].canSend())
             {
                 this.friendArray[s].msgToFriend(
                     toWrite,friendFrom);
             }
         }
         
         //at the end if logging address isn't null, forward the
         //message to a log
         if (this.loggingAddress != null)
         {
             var url = this.loggingAddress;
             // var url = 'http://bmistree.stanford.edu/testLoggingChat.php?messageFrom=';
             url += encodeURI(friendFrom);
             url += '&message=';
             url += encodeURI(toWrite);
             std.http.basicGet(url,function(){});
         }

         //update local gui
         if (isMe)
         {
             this.roomChatGui.writeFriend(
                 IMUtil.htmlEscape(toWrite),null,this.appGui.myName);                 
         }
         else
         {
             this.roomChatGui.writeFriend(
                 IMUtil.htmlEscape(toWrite),friendMsgFrom,friendMsgFrom.name);
         }
     };


     /**
      Should have no effect to start with for our gui.
      */
     Room.prototype.changeFriendName = function(newFriendName)
     {
         IMUtil.dPrint('\n\nChanging friend name\n\n');
     };
     
     
 })();
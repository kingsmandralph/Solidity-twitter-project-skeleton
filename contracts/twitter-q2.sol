// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;
    // ----- END OF DO-NOT-EDIT ----- //

    // ----- START OF QUEST 1 ----- //
    function registerAccount(string calldata _name) external {
        //check for empty string input
        require(bytes(_name).length > 0, "Name cannot be an empty string");

        //Add new user struct to the user mapping
        User storage newUser = users[msg.sender];
        newUser.wallet = msg.sender;
        newUser.name = _name;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
        //Add a new tweet struct to the tweet mapping
        Tweet memory newTweet = Tweet(nextTweetId, msg.sender, _content, block.timestamp);
        tweets[nextTweetId] = newTweet;
        User storage thisUser = users[msg.sender];
        //Push tweet to the tweet struct
        thisUser.userTweets.push(nextTweetId);
        nextTweetId++;
    }

    function readTweets(address _user) view external returns(Tweet[] memory) {
        uint[] storage userTweetIds = users[_user].userTweets;
        Tweet[] memory userTweets = new Tweet[](userTweetIds.length);
        for(uint i = 0; i < userTweetIds.length; i++) {
            userTweets[i] = tweets[userTweetIds[i]];
        }
        return userTweets;
    }

    modifier accountExists(address _user) {
        // checks if a wallet has already signed up for an account
        User storage currUser = users[_user];
        bytes memory currUserBytesStr = bytes(currUser.name);
        require(currUserBytesStr.length != 0, "This wallet does not belong to any account.");
        _;
    }
    // ----- END OF QUEST 1 ----- //

    // ----- START OF QUEST 2 ----- //
    function followUser(address _user) external accountExists(_user) accountExists(msg.sender) {
        User storage functionCaller = users[msg.sender];
        functionCaller.following.push(_user);

        User storage user = users[_user];
        user.followers.push(msg.sender);
    }

    function getFollowing() external view accountExists(msg.sender) returns(address[] memory)  {
        return users[msg.sender].following;
    }

    function getFollowers() external view accountExists(msg.sender) returns(address[] memory) {
        return users[msg.sender].followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory allTweets = new Tweet[](nextTweetId);
        for(uint i = 0; i<nextTweetId; i++){
            allTweets[i] = tweets[i];
        }
        return allTweets;
    }

    function sendMessage(address _recipient, string calldata _content) external accountExists(msg.sender) accountExists(_recipient) {
        Message memory newMessage = Message(nextMessageId, _content, msg.sender, _recipient);
        
        User storage sender = users[msg.sender];
        sender.conversations[_recipient].push(newMessage);

        User storage recipient = users[_recipient];
        recipient.conversations[msg.sender].push(newMessage);

        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        User storage thisUser = users[msg.sender];
        return thisUser.conversations[_user];
    }

    function unfollowUser(address _user) external accountExists(_user) accountExists(msg.sender) {
        // Remove the unfollowed user from the following list of the caller
        User storage functionCaller = users[msg.sender];
        uint indexToRemove = getUserIndex(_user, functionCaller.following);
        if (indexToRemove < functionCaller.following.length) {
            functionCaller.following[indexToRemove] = functionCaller.following[functionCaller.following.length - 1];
            functionCaller.following.pop();
        }

        // Remove the caller from the followers list of the unfollowed user
        User storage user = users[_user];
        indexToRemove = getUserIndex(msg.sender, user.followers);
        if (indexToRemove < user.followers.length) {
            user.followers[indexToRemove] = user.followers[user.followers.length - 1];
            user.followers.pop();
        }
    }

    // Utility function to find the index of an address in an array of addresses
    function getUserIndex(address _user, address[] storage _users) internal view returns (uint) {
        for (uint i = 0; i < _users.length; i++) {
            if (_users[i] == _user) {
                return i;
            }
        }
        return _users.length;
    }
    
    function retweet(uint tweetId) public {
    // Check that the tweet exists
    require(tweets[tweetId].tweetId != 0, "Tweet does not exist");
    // Check that the user is not retweeting their own tweet
    require(tweets[tweetId].author != msg.sender, "Cannot retweet your own tweet");
    // Create a new tweet with the same content and author as the original tweet
    tweets[nextTweetId] = Tweet(nextTweetId, tweets[tweetId].author, tweets[tweetId].content, block.timestamp);
    // Add the new tweet to the user's tweets array
    users[msg.sender].userTweets.push(nextTweetId);
    // Increment the next tweet id
    nextTweetId++;
}

    function likeTweet(uint _tweetId) external accountExists(msg.sender) {
        // Get the tweet being liked
        Tweet storage tweet = tweets[_tweetId];
        require(tweet.author != msg.sender, "You can't like your own tweet");
        
        // Check if the user has already liked this tweet
        User storage user = users[msg.sender];
        for (uint i = 0; i < user.userTweets.length; i++) {
            if (user.userTweets[i] == _tweetId) {
                revert("You have already liked this tweet");
            }
        }

        // Add the tweet ID to the user's liked tweets
        user.userTweets.push(_tweetId);
    }


}
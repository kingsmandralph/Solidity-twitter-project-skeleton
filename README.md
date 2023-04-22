# Solidity-twitter-project

> A solidity smart contract with basic Twitter functionalities.
> 
> The project was built upon Stackup functions with additional functionalities to buttress an understanding of the smart contract.

## Why the functions were chosen
The reason I chose to implement the _retweet_ and _likeTweet_ functions were because first they were availed of us to do; but primarily because they were quite challenging and I wanted to see I could work it out. Twitter won't be what it is if there was no "retweet" or "like" functionality nonetheless. 😁

## Added functionalities
### _unfollowUser_

- This `unfollowUser` function removes the unfollowed user from the following list of the caller and removes the caller from the followers list of the unfollowed user. The function checks if the caller of the function is an existing account. Then it performs two operations: removes the unfollowed user from the following list of the caller, and removes the caller from the followers list of the unfollowed user. It makes use of the helper function called `getUserIndex` to find the index of a user in an array of addresses, then it swaps the user to be removed with the last element of the array and then pops it off.
 
```solidity
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
```
### _retweet_

- The `retweet` function checks that the tweet exists and that the user is not retweeting their own tweet. If these conditions are met, a new tweet with the same content and author as the original tweet is created and added to the user's tweets array.

#### Explanation

The first line checks that the tweet exists by verifying that its `tweetId` is not equal to 0. If it does not exist, it throws an error message.
The second line checks that the user is not retweeting their own tweet by verifying that the author of the original tweet is not equal to `msg.sender`. If they are trying to retweet their own tweet, it throws an error message.
The third line creates a new tweet with the same content and author as the original tweet. It also assigns a new `tweetId` to this new tweet.
The fourth line adds this new tweet to the user’s tweets array.
The fifth line increments the `nextTweetId` variable so that it can be used for the next new tweet.

```solidity
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
```
### _likeTweet_
- The `likeTweet` function checks if the user has already liked the tweet and adds the tweet ID to the user's liked tweets if they haven't already liked it.

#### Explanation
The function takes in a `_tweetId` as an argument.
The first line gets the tweet being liked by using the `_tweetId` to access the tweets mapping.
The second line gets the user who is liking the tweet by using msg.sender to access the users mapping.
The third line checks if the user has already liked this tweet by iterating through their `userTweets` array and checking if it contains `_tweetId`. If it does, it throws an error message.
The fourth line adds the `_tweetId` to the user’s `userTweets` array.

```solidity
function likeTweet(uint _tweetId) external accountExists(msg.sender) { 
    // Get the tweet being liked 
    Tweet storage tweet = tweets[_tweetId]; 
    
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
```

## Thank You 🚀🚀

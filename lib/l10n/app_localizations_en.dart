// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Social Risk';

  @override
  String get login => 'Sign In';

  @override
  String get loginSubtitle => 'Enter your name and start the adventure!';

  @override
  String get enterName => 'Enter name';

  @override
  String get enterButton => 'Enter';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get home => 'Main Menu';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get profile => 'Profile';

  @override
  String get store => 'Store';

  @override
  String get copyright => '© 2026 Social Risk';

  @override
  String get lobby => 'Lobby';

  @override
  String get roomCode => 'Room Code';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get startGame => 'Start Game';

  @override
  String get allPlayersReady => 'All players are ready!';

  @override
  String get waitForPlayers => 'Waiting for all players to be ready...';

  @override
  String get ready => 'Ready!';

  @override
  String get notReady => 'Get Ready';

  @override
  String get playerCapacity => 'Player Capacity';

  @override
  String get player => 'players';

  @override
  String get endCondition => 'End Condition';

  @override
  String get scoreTarget => 'Score Target';

  @override
  String get roundTarget => 'Round Count';

  @override
  String get points => 'points';

  @override
  String get rounds => 'rounds';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get classicWheel => 'Classic Wheel';

  @override
  String get classicDesc =>
      'Luck and chaos — spin the wheel, whatever category comes up!';

  @override
  String get economyMode => 'Economy';

  @override
  String get economyDesc =>
      'In this mode, category points fluctuate based on popularity. Rare picks gain value, while overused ones lose points!';

  @override
  String get visibilityMode => 'Visibility Mode';

  @override
  String get openMode => 'Open Mode';

  @override
  String get closedMode => 'Closed Mode';

  @override
  String get openModeDesc => 'Everyone can see the task content beforehand.';

  @override
  String get closedModeDesc =>
      'Only category and multiplier visible. Content is hidden!';

  @override
  String get difficulty => 'Task Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get mixed => 'Mixed';

  @override
  String get createRoomButton => 'Create Room';

  @override
  String get enterRoomCode => 'Enter 6-digit room code';

  @override
  String get joinButton => 'Join';

  @override
  String get spinWheel => 'Spin the Wheel!';

  @override
  String spinningPlayer(String playerName) {
    return '$playerName is spinning...';
  }

  @override
  String get categoryRandom => 'Category is random!';

  @override
  String get yourTurn => 'Your Turn!';

  @override
  String playerPlaying(String playerName) {
    return '$playerName is playing';
  }

  @override
  String get yourTask => 'Your Task:';

  @override
  String playerTask(String playerName) {
    return '$playerName\'s Task:';
  }

  @override
  String get closedModeLabel => 'Closed Mode';

  @override
  String get revealTask => 'Reveal Task 🔓';

  @override
  String get acceptTask => 'Accept Task';

  @override
  String passTask(int penalty) {
    return 'Pass (Penalty: -$penalty points)';
  }

  @override
  String waitingForDecision(String playerName) {
    return 'Waiting for $playerName to decide...';
  }

  @override
  String get winner => 'WINNER!';

  @override
  String get finalRanking => 'Final Ranking';

  @override
  String get goToStore => 'Go to Store';

  @override
  String get goToRooms => 'Back to Rooms';

  @override
  String walletAdded(int points) {
    return '+$points Points Added to Wallet';
  }

  @override
  String get pickCategory => 'Pick Category';

  @override
  String get yourPick => 'Your turn to pick!';

  @override
  String playerPicking(String playerName) {
    return '$playerName is picking...';
  }

  @override
  String pickProgress(int current, int total) {
    return 'Pick $current/$total';
  }

  @override
  String get marketStatus => 'Market Status';

  @override
  String get categoryLocked => 'This category is locked!';

  @override
  String get premiumCategoryLocked =>
      'This is a premium-only category and can only be selected by members.';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get storeTitle => 'Store & Wallet';

  @override
  String get storeSubtitle => 'Cosmetics and contents';

  @override
  String get cosmetics => 'Cosmetics';

  @override
  String get frames => 'Frames';

  @override
  String get badges => 'Badges & Titles';

  @override
  String get owned => 'Owned';

  @override
  String get you => 'You';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Sound and Language';

  @override
  String get menuMusic => 'Menu Music';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get languageSelection => 'Language';

  @override
  String get newParty => 'New Party';

  @override
  String get joinParty => 'Join Party';

  @override
  String get myContent => 'My Content';

  @override
  String get myContentSubtitle => 'Manage your own contents';

  @override
  String get logOut => 'Log Out';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get attention => 'ATTENTION!';

  @override
  String get logoutWarning =>
      'Are you sure you want to delete your account and log out? This action cannot be undone.';

  @override
  String get no => 'No';

  @override
  String get deleteAndExit => 'Delete and Exit';

  @override
  String get sendEmote => 'Send Emote';

  @override
  String get emoteCooldown => 'Emote Cooldown';

  @override
  String get partyStarting => 'PARTY STARTING!';

  @override
  String get chooseTask => 'Determine Task';

  @override
  String get spinWheelSubtitle => 'Spin the wheel for a random category!';

  @override
  String get taskReveal => 'Reveal Task';

  @override
  String get startTask => 'Start Task';

  @override
  String get waitingForPlayerAction => 'Waiting for player to perform...';

  @override
  String get finishTask => 'Finish Task';

  @override
  String get taskResultTitle => 'TASK DONE';

  @override
  String taskResultSubtitle(String playerName) {
    return '$playerName completed the performance.';
  }

  @override
  String get taskRejectedTitle => 'TASK REJECTED';

  @override
  String taskRejectedSubtitle(String playerName) {
    return '$playerName refused to do the task.';
  }

  @override
  String get audienceScore => 'Audience Score';

  @override
  String get performanceResult => 'Performance Result';

  @override
  String get liked => 'Liked';

  @override
  String get disliked => 'Disliked';

  @override
  String get undecided => 'Undecided';

  @override
  String get difficultyMultiplier => 'Difficulty Multiplier';

  @override
  String get pointsWon => 'Points Won';

  @override
  String get pointsLost => 'Points Lost';

  @override
  String get playerRanking => 'PLAYER RANKING';

  @override
  String get nextTask => 'NEXT TASK';

  @override
  String get waitingForHostNextTurn =>
      'Waiting for host to start the next turn...';

  @override
  String get rateScenario => 'RATE SCENARIO';

  @override
  String get good => 'GOOD';

  @override
  String get bad => 'BAD';

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get riskAndReward => 'RISK AND REWARD';

  @override
  String get chooseDifficultyOneLine =>
      'Determine the difficulty of your performance';

  @override
  String get chooseDifficultyTwoLines =>
      'Determine the difficulty of your performance...';

  @override
  String estimatedGain(int points) {
    return 'Estimated Gain: $points Points';
  }

  @override
  String waitingDifficulty(String playerName) {
    return '$playerName is choosing difficulty level...';
  }

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get homeScreenLoading => 'Loading home screen...';

  @override
  String get menu => 'Menu';

  @override
  String get roomClosedHostLeft => 'Room closed because the host left.';

  @override
  String get preparingGame => 'Preparing Game...';

  @override
  String get wheelModeCapital => 'WHEEL MODE';

  @override
  String get marketModeCapital => 'MARKET MODE';

  @override
  String get chooseAnEmote => 'Choose an Emote';

  @override
  String sendEmoteCooldown(int seconds) {
    return 'Emote Cooldown ${seconds}s';
  }

  @override
  String get everyoneWaitingForYou => 'Come on, everyone is waiting for you!';

  @override
  String get waitForOthersToReady => 'Wait for other players to get ready...';

  @override
  String get youSuffix => ' (You)';

  @override
  String get hostDefaultName => 'Director';

  @override
  String get roomCreating => 'Creating Party...';

  @override
  String get newPartyHostTitle => 'Create New Party';

  @override
  String get endConditionLabel => 'End Condition';

  @override
  String get gameModeLabel => 'Game Mode';

  @override
  String get startPartyButton => 'Start Party';

  @override
  String get roundLabel => 'Round';

  @override
  String get pointLabel => 'Point';

  @override
  String get classicModeTitle => 'Classic Party';

  @override
  String get economyModeTitle => 'Boss Party';

  @override
  String get classicModeDesc =>
      'Spin the wheel and face risky penalties from random categories. Your only chance to collect points is courage!';

  @override
  String get economyModeDesc =>
      'Category points change dynamically based on popularity: less chosen \'hidden gems\' grant higher rewards, while overused categories lose value. Strategize and take the most profitable risks! (Activates with at least 3 categories)';

  @override
  String get singleCategoryEconomyWarn =>
      'When a single category is selected, only the Boss mode can be used.';

  @override
  String get singleCategoryEconomyAutoChange =>
      'A single category was selected. The game mode was automatically changed to Boss mode.';

  @override
  String get minOneCategoryWarn => 'You must select at least 1 category.';

  @override
  String get pleaseEnter6DigitCode => 'Please enter the 6-digit code';

  @override
  String get playerDefaultName => 'Player';

  @override
  String partyNotFound(String error) {
    return 'Party not found: $error';
  }

  @override
  String get connectingToParty => 'Connecting to party...';

  @override
  String get joinPartyTitle => 'Join Party';

  @override
  String get enterPartyCode => 'Enter Party Code';

  @override
  String get enterPartyCodeDesc =>
      'Join the fun by entering the 6-digit party code shared by your friends.';

  @override
  String get determineYourTask => 'Determine Your Task';

  @override
  String get hiddenRound => 'HIDDEN ROUND';

  @override
  String get taskCapital => 'TASK';

  @override
  String get nextTaskHidden => 'Next Task is Hidden';

  @override
  String get yourContentHere => 'Your Content is Here:';

  @override
  String contentForPlayer(String player) {
    return '$player Content:';
  }

  @override
  String get openCardToViewTask => 'Open the card to view the current task...';

  @override
  String get openTask => 'Reveal Task';

  @override
  String get rejectTaskPoint => 'Reject Task (-50 Points)';

  @override
  String get areYouSurePoint => 'ARE YOU SURE? (-50)';

  @override
  String readingContentSubtitle(String player) {
    return '$player is reading the content...';
  }

  @override
  String categoryVariable(String category) {
    return 'Category: $category';
  }

  @override
  String get gameNotFound => 'Game Not Found';

  @override
  String get determineYourDifficulty =>
      'Determine the difficulty of your performance...';

  @override
  String get determineYourDifficultyShort => 'Determine your difficulty';

  @override
  String get waitingCapital => 'WAITING';

  @override
  String playerChoosingDifficulty(String player) {
    return '$player is choosing the difficulty level...';
  }

  @override
  String get easyCapital => 'EASY';

  @override
  String get mediumCapital => 'MEDIUM';

  @override
  String get hardCapital => 'HARD';

  @override
  String estimatedEarningsPoint(int point) {
    return 'Estimated Earnings: $point Points';
  }

  @override
  String get taskStarted => 'TASK STARTED';

  @override
  String get contentLabel => 'CONTENT:';

  @override
  String get displayedContentLabel => 'DISPLAYED CONTENT:';

  @override
  String get hiddenContentLabel => 'HIDDEN CONTENT';

  @override
  String get taskNoRole => 'Role not specified';

  @override
  String get finishTaskInstruction =>
      'If you completed the task, please finish your performance.';

  @override
  String get finishTaskButton => 'Finish Task';

  @override
  String get waitingForPerformance => 'Waiting for the player to perform...';

  @override
  String get waitingForPlayerCapital => 'Waiting for Player...';

  @override
  String get taskRejected => 'TASK REJECTED';

  @override
  String get roundOver => 'ROUND OVER';

  @override
  String playerRefusedRole(String player) {
    return '$player refused to perform the role.';
  }

  @override
  String playerCompletedPerformance(String player) {
    return '$player completed the performance.';
  }

  @override
  String get likedResult => 'Liked';

  @override
  String get dislikedResult => 'Disliked';

  @override
  String get neutralResult => 'Neutral';

  @override
  String get gainedPoints => 'Points Gained';

  @override
  String get lostPoints => 'Points Lost';

  @override
  String get partyOver => 'PARTY OVER';

  @override
  String get waitingForFinal => 'Waiting for the final...';

  @override
  String get waitingForHostNextRound =>
      'Waiting for the host to proceed to the next round...';

  @override
  String get evaluateScenario => 'EVALUATE SCENARIO';

  @override
  String get goodUpper => 'GOOD';

  @override
  String get badUpper => 'BAD';

  @override
  String get winnerCapital => 'WINNER';

  @override
  String get pointsCapital => 'POINTS';

  @override
  String get negativeScoreMessage =>
      'You can\'t go below zero my friend\nYou didn\'t earn any balance!';

  @override
  String pointsAddedToBalance(int point) {
    return '+$point Points added to your balance';
  }

  @override
  String get returnToLobby => 'RETURN TO LOBBY';

  @override
  String get scenarioSelection => 'SCENARIO SELECTION';

  @override
  String get nextPickerIsYou => 'YOU ARE THE NEXT PLAYER!';

  @override
  String playerIsPicking(String player) {
    return '$player IS PICKING...';
  }

  @override
  String pickCount(int current, int total) {
    return 'PICK $current/$total';
  }

  @override
  String get partyExperience => 'PARTY EXPERIENCE';

  @override
  String get hotDeal => 'Hot\nDeal';

  @override
  String get basePoint => 'BASE POINT';

  @override
  String get gameEndedOrHostLeft => 'Game ended or host left.';

  @override
  String get leftPlayer => 'Left Player';

  @override
  String get waitingQueue => 'WAITING QUEUE';

  @override
  String playerIsPerforming(String player) {
    return '$player is performing...';
  }

  @override
  String playerIsDecidingRole(String player) {
    return '$player is deciding role...';
  }

  @override
  String get votingWillStartWhenTurnEnds =>
      'Voting will start when the turn ends';

  @override
  String get preparingParty => 'Preparing Party...';

  @override
  String get info => 'Information';

  @override
  String get about => 'About';

  @override
  String get appAndTeamInfo => 'App and team information';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get legalTermsAndConditions => 'Legal terms and conditions';

  @override
  String get close => 'Close';

  @override
  String get termsOfUseContent =>
      'Last update: 2026\n\n1) Acceptance and Scope\nBy using this application, you agree to these Terms of Use. If you do not agree, do not use the application.\n\n2) Appropriate Use\nUsers are obligated not to use automation tools for cheating, harassment, hate speech, threats, sharing illegal content, violating account security, or disrupting service.\n\n3) Account and Security\nYou are responsible for actions taken with your account. You must report suspicious access or security breaches immediately.\n\n4) Content and Community Rules\nUser-generated content must comply with community rules. Violating content may be removed without notice, and accounts may face temporary or permanent restrictions.\n\n5) Intellectual Property\nApp interface, brand elements, and software components belong to respective owners. Unauthorized copying, distribution, or reverse engineering is prohibited.\n\n6) Service Changes and Interruptions\nService may be modified, restricted, or temporarily suspended for technical maintenance, security, or business requirements.\n\n7) Limitation of Liability\nThe application is provided \"as is\". To the extent permitted by law, liability for indirect or incidental damages is not accepted.\n\n8) Account Termination\nAccess may be suspended or terminated in case of violation of terms of use or community rules.\n\n9) Updating Terms\nTerms of Use may be updated from time to time. Current text is valid from the moment it is published in the app.\n\n10) Contact\nIn-app communication channels should be used for legal notices and support requests.';

  @override
  String get notReadyYet => 'READY UP';

  @override
  String get readyForParty => 'NOT READY';

  @override
  String get lobbyTip1 => 'Let the party begin! Are you ready?';

  @override
  String get lobbyTip2 => 'Your answers will be talked about a lot!';

  @override
  String get lobbyTip3 => 'Other players\' votes will determine your fate.';

  @override
  String get lobbyTip4 => 'Risky tasks and tough choices await you.';

  @override
  String get spinning => 'Spinning...';

  @override
  String pointsLowercase(Object points) {
    return '$points points';
  }

  @override
  String get titlesTab => 'Titles';

  @override
  String get framesTab => 'Frames';

  @override
  String get scenariosTab => 'Scenarios';

  @override
  String get ownedLabel => 'OWNED';

  @override
  String itemPurchased(Object name) {
    return '$name is now in your wardrobe!';
  }

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String buyError(Object message) {
    return 'Error: $message';
  }

  @override
  String get noItems => 'No items to display yet.';

  @override
  String get scenariosComingSoon =>
      'Special Scenarios and Theme Packs are Coming Soon!';

  @override
  String get logoutSuccess => 'Logout Successful';

  @override
  String logoutError(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get loginError => 'Login failed';

  @override
  String get nameEmptyError => 'Please enter your stage name';

  @override
  String get nameTooShortError => 'Name must be at least 3 characters';

  @override
  String get invalidNameError => 'Use only letters and numbers';

  @override
  String get anonymousLoginSuccess => 'Logged in anonymously';

  @override
  String get loggingIn => 'Logging into the party...';

  @override
  String get playerDisplayNameHint => 'Your Player Name...';

  @override
  String get joinPartyButton => 'Join the Party!';

  @override
  String get anonymousHint =>
      '* You will continue anonymously. Your statistics will be saved to this device.';

  @override
  String get orDivider => 'Or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get content => 'Content';

  @override
  String get comingSoon => 'COMING SOON';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get updateDisplayNameTitle => 'Update Player Name';

  @override
  String get newDisplayNameLabel => 'New Player Name';

  @override
  String get cancel => 'CANCEL';

  @override
  String get update => 'UPDATE';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get invalidNameLong =>
      'Please enter a valid name! (Min 3 characters, alphanumeric only)';

  @override
  String get actorTab => 'Profile';

  @override
  String get wardrobeTab => 'Items';

  @override
  String get performanceTab => 'Performance';

  @override
  String get noItemsInWardrobe =>
      'You don\'t have any items yet.\nWant to check out the cool stuff in the store?';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get rankLabel => 'Rank';

  @override
  String get collectionLabel => 'Collection';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get activeLabel => 'Active';

  @override
  String get quickStatsTitle => 'Quick Stats';

  @override
  String get gameLabel => 'Game';

  @override
  String get winLabel => 'Win';

  @override
  String get pointsLabel => 'Points';

  @override
  String get rankLegend => 'Legend';

  @override
  String get rankKing => 'King';

  @override
  String get rankStar => 'Star';

  @override
  String get rankFun => 'Fun';

  @override
  String get rankBeginner => 'Beginner';

  @override
  String get guestName => 'Guest';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get completedLabel => 'COMPLETED ✓';

  @override
  String get achievementPartyMonsterTitle => 'Party Monster';

  @override
  String get achievementPartyMonsterDesc => 'Number of games played';

  @override
  String get achievementVoiceOfPeopleTitle => 'Voice of the People';

  @override
  String get achievementVoiceOfPeopleDesc => 'Number of votes given';

  @override
  String get achievementVipTitle => 'VIP';

  @override
  String get achievementVipDesc => 'Owned balance';

  @override
  String get achievementSocialIconTitle => 'Social Icon';

  @override
  String get achievementSocialIconDesc => 'Number of items owned';

  @override
  String get createContent => 'Create Content';

  @override
  String get editContent => 'Edit Content';

  @override
  String get addContent => 'Add Content';

  @override
  String get contentAdded => 'Content added!';

  @override
  String get contentUpdated => 'Content updated!';

  @override
  String get pleaseWriteContent => 'Please write some content';

  @override
  String get contentText => 'Content Text';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get specialCategory => 'Special';

  @override
  String get myContentsTitle => 'My Contents';

  @override
  String get myContentsDescription =>
      'You can create your own contents in this section.';

  @override
  String get myContentsUsage =>
      'Use these contents in the game to double the fun!';

  @override
  String get editTooltip => 'Edit';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get easyDifficulty => 'Easy';

  @override
  String get mediumDifficulty => 'Medium';

  @override
  String get hardDifficulty => 'Hard';

  @override
  String get votingTitle => 'CRITIQUE & VOTING';

  @override
  String get playerPerformed => 'performed:';

  @override
  String get voteTimeoutPenalty =>
      'Time\'s up! You received a -10 point penalty for not voting.';

  @override
  String get calculatingScore => 'Calculating Score...';

  @override
  String get countingVotes => 'Counting votes...';

  @override
  String get waitingForEvaluation =>
      'Waiting for other players\' evaluation...';

  @override
  String get evaluated => 'EVALUATED';

  @override
  String get waitingTip1 => 'Everyone is waiting for your decision...';

  @override
  String get waitingTip2 => 'Time is running out!';

  @override
  String get waitingTip3 => 'Decide quickly...';

  @override
  String get waitingTip4 => 'Be ruthless!';

  @override
  String get waitingTip5 => 'The tension is rising...';

  @override
  String get howWasPerformance => 'HOW WAS THE PERFORMANCE?';

  @override
  String get evaluatePerformance => 'Evaluate the player\'s performance';

  @override
  String get voteLike => 'LIKE';

  @override
  String get voteNeutral => 'NEUTRAL';

  @override
  String get voteDislike => 'DISLIKE';

  @override
  String get categoryMoral => 'Moral';

  @override
  String get categoryKnowledge => 'Knowledge';

  @override
  String get categoryDigital => 'Digital';

  @override
  String get categoryPhysical => 'Physical';

  @override
  String get categoryVisual => 'Visual';

  @override
  String get categoryConfession => 'Confession';

  @override
  String get categoryIntimate => 'Intimate';

  @override
  String get categoryMental => 'Mental';
}

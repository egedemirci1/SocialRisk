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
  String get notReady => 'Not Ready';

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
      'Strategy — score leader picks first, market contracts!';

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
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get storeTitle => 'Store & Wallet';

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
}

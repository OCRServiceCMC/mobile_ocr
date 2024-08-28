class Question {
  final int messageID;
  final int userID;
  late final String message;
  final String messageTime;
  final List<Answer> answers;

  Question({
    required this.messageID,
    required this.userID,
    required this.message,
    required this.messageTime,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      messageID: json['messageID'],
      userID: json['userID'],
      message: json['message'],
      messageTime: json['messageTime'],
      answers: (json['answers'] as List<dynamic>)
          .map((item) => Answer.fromJson(item))
          .toList(),
    );
  }
}

class Answer {
  final int answerID;
  final String answer;
  final String answerTime;
  final int questionID;

  Answer({
    required this.answerID,
    required this.answer,
    required this.answerTime,
    required this.questionID,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      answerID: json['answerID'],
      answer: json['answer'],
      answerTime: json['answerTime'],
      questionID: json['questionID'],
    );
  }
}

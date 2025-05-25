import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Question> _questions = [];
  List<Answer> _answers = [];
  bool _isLoading = false;
  String? _error;

  List<Question> get questions => _questions;
  List<Answer> get answers => _answers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadQuestions({String? category}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _questions = await _databaseService.getQuestions(category: category);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchQuestions(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      _questions = await _databaseService.searchQuestions(query);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAnswers(String questionId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _answers = await _databaseService.getAnswersByQuestionId(questionId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addQuestion(Question question) async {
    try {
      await _databaseService.insertQuestion(question);
      _questions.insert(0, question);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> addAnswer(Answer answer) async {
    try {
      await _databaseService.insertAnswer(answer);
      _answers.add(answer);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearQuestions() {
    _questions.clear();
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }
} 
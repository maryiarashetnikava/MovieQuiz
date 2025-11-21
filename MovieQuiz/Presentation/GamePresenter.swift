
import UIKit

// MARK: - GamePresenter
final class GamePresenter {
    
    // MARK: - Game State
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol = StatisticService()


    // MARK: - Dependencies
    private weak var view: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol
    
    // MARK: - Init
    init(view: MovieQuizViewControllerProtocol,
         questionFactory: QuestionFactoryProtocol) {
        self.view = view
        self.questionFactory = questionFactory
        
        
        self.questionFactory.delegate = self
        requestNextQuestion()
    }
    
    // MARK: - Public Methods
    func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        let newFactory = QuestionFactory()
            newFactory.delegate = self
            self.questionFactory = newFactory

        requestNextQuestion()
    }
    
    // MARK: - Private Game Logic
    private func requestNextQuestion() {
        questionFactory.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
           
        } else {
            currentQuestionIndex += 1
            requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        view?.highlightImage(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showResults() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        let text = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных игр: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(accuracy)%
        """
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз"
        )
        
        view?.show(quiz: viewModel)
    }

    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}

// MARK: - QuestionFactoryDelegate
extension GamePresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        self.currentQuestion = question

        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.view?.show(quiz: viewModel)
        }
    }
}







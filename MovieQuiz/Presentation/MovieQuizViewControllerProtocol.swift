
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImage(isCorrect: Bool)
    func show(quiz result: QuizResultsViewModel)

}


import UIKit

// MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Dependencies
    private var presenter: GamePresenter!

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let moviesLoader = MoviesLoader()
        let factory = QuestionFactory(moviesLoader: moviesLoader, delegate: nil)
        presenter = GamePresenter(view: self, questionFactory: factory)
        
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.handleAnswer(true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.handleAnswer(false)
    }
}

// MARK: - MovieQuizViewControllerProtocol
extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func highlightImage(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        )
        
        AlertPresenter.show(in: self, model: model)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        
        let model = AlertModel(
            title: presenter.networkErrorTitle,
            message: message,
            buttonText: presenter.retryButtonText
        ) { [weak self] in
            
            self?.presenter.restartLoading()
        }
        AlertPresenter.show(in: self, model: model)
    }
    
}
    



    
    

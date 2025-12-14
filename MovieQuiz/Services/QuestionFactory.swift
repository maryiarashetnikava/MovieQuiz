
import Foundation

class QuestionFactory: QuestionFactoryProtocol  {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if let errorText = mostPopularMovies.errorMessage, !errorText.isEmpty {
                        let error = NSError(domain: "MoviesAPI",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: errorText]
                        )
                        self.delegate?.didFailToLoadData(with: error)
                        return
                    }
                    guard !mostPopularMovies.items.isEmpty else {
                        let error = NSError(
                            domain: "MoviesAPI",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Список фильмов пуст"]
                        )
                        self.delegate?.didFailToLoadData(with: error)
                        return
                    }
                    
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        guard !movies.isEmpty else {
            loadData()
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            guard let imageData = try? Data(contentsOf: movie.resizedImageURL),
                  !imageData.isEmpty else {
                    self.requestNextQuestion()
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

// MARK: - Mock questions:
/*
 private var questions: [QuizQuestion] = [
 QuizQuestion(image: "The Godfather",
 text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
 QuizQuestion(image: "The Dark Knight",
 text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
 QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
 QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
 QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
 QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
 QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
 QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
 QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
 QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
 ]
 */

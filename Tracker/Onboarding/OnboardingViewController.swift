
import UIKit

//MARK: - OnboardingViewController
final class OnboardingViewController: UIViewController {
    
    //MARK: - UIModels
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    //MARK: - Private Properties
    private var slides = [OnboardingView]()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        slides = createSlides()
        setupSlidesScrollView(slides: slides)
        setupViews()
        setConstraints()
        setDelegates()
    }
    
    //MARK: - Private Methods
    private func createSlides() -> [OnboardingView] {
        let firstOnboardingView = OnboardingView()
        firstOnboardingView.setPageLabelText(text: "Отслеживайте только то, что хотите")
        firstOnboardingView.setButton(text: "Вот это технологии!")
        firstOnboardingView.setImageView(for: .firstOnboarding)
        
        let secondOnboardingView = OnboardingView()
        secondOnboardingView.setPageLabelText(text: "Даже если это не литры воды и йога")
        secondOnboardingView.setButton(text: "Вот это технологии!")
        secondOnboardingView.setImageView(for: .secondOnboarding)
        
        return [firstOnboardingView, secondOnboardingView]
    }
    
    private func setupSlidesScrollView(slides: [OnboardingView]) {
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count),
                                        height: view.frame.height)
        
        for i in 0..<slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i),
                                 y: 0,
                                 width: view.frame.width,
                                 height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
}

//MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maxHorizontalOffset = scrollView.contentSize.width - view.frame.width
        let percentHorizontalOffset = scrollView.contentOffset.x / maxHorizontalOffset
        
        if percentHorizontalOffset <= 1 {
            let firstTransForm = CGAffineTransform(scaleX: 1 - percentHorizontalOffset,
                                              y: 1 - percentHorizontalOffset)
            let secondTransform = CGAffineTransform(scaleX: percentHorizontalOffset,
                                                    y: percentHorizontalOffset)
                                                    
            slides[0].set(transform: firstTransForm)
            slides[1].set(transform: secondTransform)
        }
    }
}

//MARK: - AutoLayout
extension OnboardingViewController {
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(pageControl)
    }
    
    private func setDelegates() {
        scrollView.delegate = self
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}


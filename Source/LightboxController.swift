import UIKit

public class LightboxController: UIViewController {

  public lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.frame = UIScreen.mainScreen().bounds
    scrollView.pagingEnabled = true
    scrollView.delegate = self
    scrollView.userInteractionEnabled = true
    scrollView.showsHorizontalScrollIndicator = false

    return scrollView
  }()

  public lazy var closeButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle(LightboxConfig.closeButton, forState: .Normal)
    button.setTitleColor(LightboxConfig.closeButtonColor, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress", forControlEvents: .TouchUpInside)
    button.titleLabel?.font = LightboxConfig.closeButtonFont
    button.sizeToFit()

    return button
  }()

  public lazy var pageControl: UIPageControl = { [unowned self] in
    let pageControl = UIPageControl()
    pageControl.addTarget(self, action: "handlePageControl", forControlEvents: .TouchUpInside)
    pageControl.userInteractionEnabled = true

    return pageControl
  }()

  public var pageViews = [PageView]()

  public lazy var transitionManager: LightboxTransition = LightboxTransition()

  var statusBarHidden = false

  // MARK: - Initializers

  public init(images: [UIImage]) {
    super.init(nibName: nil, bundle: nil)

    [scrollView, closeButton, pageControl].forEach { view.addSubview($0) }
    pageControl.numberOfPages = images.count
    pageControl.sizeToFit()

    setupFrames(images.count)
    setupControllers(images)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.blackColor()
    transitionManager.lightboxController = self
    transitionManager.scrollView = scrollView
    transitioningDelegate = transitionManager
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillDisappear(animated)

    statusBarHidden = UIApplication.sharedApplication().statusBarHidden
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
  }

  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    UIApplication.sharedApplication().setStatusBarHidden(statusBarHidden, withAnimation: .Fade)
  }

  override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    scrollView.frame.size = size
    scrollView.contentSize = CGSize(
      width: size.width * CGFloat(pageControl.numberOfPages),
      height: size.height)
    scrollView.contentOffset = CGPoint(x: CGFloat(pageControl.currentPage) * size.width, y: 0)

    print(scrollView.contentSize)
    configureFrames()
  }

  // MARK: - Main methods

  public func setupFrames(imageCount: Int) {
    scrollView.contentSize.width = UIScreen.mainScreen().bounds.width * CGFloat(imageCount)
    closeButton.frame.origin = CGPoint(x: 12.5, y: 7.5)
    pageControl.frame.origin = CGPoint(
      x: (UIScreen.mainScreen().bounds.width - pageControl.frame.width) / 2,
      y: UIScreen.mainScreen().bounds.height - pageControl.frame.height + 5)

  }

  public func setupControllers(images: [UIImage]) {

    for (index, image) in images.enumerate() {
      let pageView = PageView(image: image)

      if index == 0 {
        pageView.backgroundColor = .redColor()
      }

      scrollView.addSubview(pageView)
      pageViews.append(pageView)
    }

    configureFrames()
  }

  public func configureFrames() {
    for (index, pageView) in pageViews.enumerate() {
      var frame = scrollView.bounds
      frame.origin.x = frame.width * CGFloat(index)
      pageView.configureFrame(frame)
    }
  }

  // MARK: - Action methods

  public func handlePageControl() {
    UIView.animateWithDuration(0.35, animations: {
      self.scrollView.contentOffset.x = UIScreen.mainScreen().bounds.width * CGFloat(self.pageControl.currentPage)
    })
  }

  public func closeButtonDidPress() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - ScrollView delegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let page = scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width

    pageControl.currentPage = Int(page)
  }
}

import UIKit

class OnboardingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> ())?

    unowned let navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let onboarding = OnboardingController()
        onboarding.onFinish = { [weak self] in
            guard let self else { return }
            self.onFinish?()
        }
        navigationController.setViewControllers([onboarding], animated: true)
    }
}

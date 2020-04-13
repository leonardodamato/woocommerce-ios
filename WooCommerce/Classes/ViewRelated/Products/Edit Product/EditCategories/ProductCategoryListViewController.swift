import UIKit
import Yosemite

/// ProductCategoryListViewController: Displays the list of ProductCategories associated to the active Account.
///
final class ProductCategoryListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private let viewModel: ProductCategoryListViewModel

    init(product: Product) {
        self.viewModel = ProductCategoryListViewModel(product: product)
        super.init(nibName: type(of: self).nibName, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        configureTableView()
        configureNavigationBar()
        configureViewModel()
    }
}

// MARK: - View Configuration
//
private extension ProductCategoryListViewController {
    func registerTableViewCells() {
        tableView.register(ProductCategoryTableViewCell.loadNib(), forCellReuseIdentifier: ProductCategoryTableViewCell.reuseIdentifier)
    }

    func configureTableView() {
        view.backgroundColor = .listBackground
        tableView.backgroundColor = .listBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.removeLastCellSeparator()
    }

    func configureNavigationBar() {
        configureTitle()
        configureRightButton()
    }

    func configureTitle() {
        title = NSLocalizedString("Categories", comment: "Edit product categories screen - Screen title")
    }

    func configureRightButton() {
        let applyButtonTitle = NSLocalizedString("Done",
                                               comment: "Edit product categories screen - button title to apply categories selection")
        let rightBarButton = UIBarButtonItem(title: applyButtonTitle,
                                             style: .done,
                                             target: self,
                                             action: #selector(doneButtonTapped))
        navigationItem.setRightBarButton(rightBarButton, animated: false)
    }
}

// MARK: - Synchronize Categories
//
private extension ProductCategoryListViewController {
    func configureViewModel() {
        viewModel.performInitialFetch()
        viewModel.observeCategoryListChanges { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - Actions
//
private extension ProductCategoryListViewController {
    @objc private func doneButtonTapped() {
        // TODO-2020: Submit category changes
    }
}

// MARK: - UITableViewConformace conformance
//
extension ProductCategoryListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCategoryTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? ProductCategoryTableViewCell else {
            fatalError()
        }

        let category = viewModel.item(at: indexPath)
        let isSelected = viewModel.isCategorySelected(category)
        cell.configure(name: category.name, selected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO-2020: Select category and update state
    }
}

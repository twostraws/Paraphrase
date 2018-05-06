//
//  QuotesViewController.swift
//  Paraphrase
//
//  Created by Paul Hudson on 05/05/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import GameplayKit
import UIKit

class QuotesViewController: UITableViewController {
    // all the quotes to be shown in our table
    var quotes = [Quote]()

    // whichever row was selected; used when adjusting the data source after editing
    var selectedRow : Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Paraphrase"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Random", style: .plain, target: self, action: #selector(showRandomQuote))

        // load our quote data
        let defaults = UserDefaults.standard
        let quoteData : Data

        if let savedQuotes = defaults.data(forKey: "SavedQuotes") {
            // we have saved quotes; use them
            SwiftyBeaver.info("Loading saved quotes")
            quoteData = savedQuotes
        } else {
            // no saved quotes; load the default initial quotes
            SwiftyBeaver.info("No saved quotes")
            let path = Bundle.main.url(forResource: "initial-quotes", withExtension: "json")!
            quoteData = try! Data(contentsOf: path)
        }

        let decoder = JSONDecoder()
        quotes = try! decoder.decode([Quote].self, from: quoteData)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // format the quote neatly
        let quote = quotes[indexPath.row]
        let formattedText = quote.text.replacingOccurrences(of: "\n", with: " ")
        let cellText = "\(quote.author): \(formattedText)"

        cell.textLabel?.text = cellText

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show the quote fullscreen
        guard let showQuote = storyboard?.instantiateViewController(withIdentifier: "ShowQuoteViewController") as? ShowQuoteViewController else {
            SwiftyBeaver.error("Unable to load ShowQuoteViewController")
            fatalError("Unable to load ShowQuoteViewController")
        }

        let selectedQuote = quotes[indexPath.row]
        showQuote.quote = selectedQuote

        navigationController?.pushViewController(showQuote, animated: true)
    }

    @objc func addQuote() {
        // add an empty quote and mark it as selected
        let quote = Quote(author: "", text: "")
        quotes.append(quote)
        selectedRow = quotes.count - 1

        // now trigger editing that quote
        guard let editQuote = storyboard?.instantiateViewController(withIdentifier: "EditQuoteViewController") as? EditQuoteViewController else {
            SwiftyBeaver.error("Unable to load EditQuoteViewController")
            fatalError("Unable to load EditQuoteViewController")
        }

        editQuote.quotesViewController = self
        editQuote.editingQuote = quote
        navigationController?.pushViewController(editQuote, animated: true)
    }

    @objc func showRandomQuote() {
        guard !quotes.isEmpty else { return }
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: quotes.count)
        let selectedQuote = quotes[randomNumber]

        guard let showQuote = storyboard?.instantiateViewController(withIdentifier: "ShowQuoteViewController") as? ShowQuoteViewController else {
            SwiftyBeaver.error("Unable to load ShowQuoteViewController")
            fatalError("Unable to load ShowQuoteViewController")
        }

        showQuote.quote = selectedQuote

        navigationController?.pushViewController(showQuote, animated: true)
    }

    func finishedEditing(_ quote: Quote) {
        // make sure we have a selected row
        guard let selected = selectedRow else { return }

        if quote.author.isEmpty && quote.text.isEmpty {
            // if no text was entered just delete the quote
            SwiftyBeaver.info("Removing empty quote")
            quotes.remove(at: selected)
        } else {
            // replace our existing quote with this new one then save
            SwiftyBeaver.info("Replacing quote at index \(selected)")
            quotes[selected] = quote
            self.saveQuotes()
        }

        tableView.reloadData()
        selectedRow = nil
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (action, indexPath) in
            SwiftyBeaver.info("Deleting quote at index \(indexPath.row)")
            self.quotes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveQuotes()
        }

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [unowned self] (action, indexPath) in
            let quote = self.quotes[indexPath.row]
            self.selectedRow = indexPath.row

            guard let editQuote = self.storyboard?.instantiateViewController(withIdentifier: "EditQuoteViewController") as? EditQuoteViewController else {
                SwiftyBeaver.error("Unable to load EditQuoteViewController")
                fatalError("Unable to load EditQuoteViewController")
            }

            editQuote.quotesViewController = self
            editQuote.editingQuote = quote
            self.navigationController?.pushViewController(editQuote, animated: true)
        }

        edit.backgroundColor = UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1)

        return [delete, edit]
    }

    func saveQuotes() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        let data = try! encoder.encode(quotes)
        defaults.set(data, forKey: "SavedQuotes")
        SwiftyBeaver.info("Quotes saved")
    }
}


//
//  EditQuoteViewController.swift
//  Paraphrase
//
//  Created by Paul Hudson on 05/05/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import UIKit

class EditQuoteViewController: UITableViewController, UITextViewDelegate {
    @IBOutlet var quoteAuthor: UITextField!
    @IBOutlet var quoteText: UITextView!

    var quotesViewController : QuotesViewController?
    var editingQuote : Quote?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add quote"
        navigationItem.largeTitleDisplayMode = .never

        quoteAuthor.text = editingQuote?.author ?? ""
        quoteText.text = editingQuote?.text ?? ""

        // make the quote text align neatly with everything else
        quoteText.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        // prompt the user to start editing the author first
        quoteAuthor.becomeFirstResponder()
    }

    func textViewDidChange(_ textView: UITextView) {
        // make the table view resize as the text view grows
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // send back our edited quote
        let author = quoteAuthor.text ?? "Anonymous"
        let text = quoteText.text ?? ""
        let quote = Quote(author: author, text: text)

        quotesViewController?.finishedEditing(quote)
    }
}

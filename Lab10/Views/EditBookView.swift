//
//  EditBookView.swift
//  Lab10
//
//  Created by Іван Джулинський on 09.09.2025.
//

import SwiftUI

struct EditBookView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var db = DatabaseManager.shared
    
    @Binding var book: Book
    @State private var newTitle: String
    @State private var newAuthor: String
    
    init(book: Binding<Book>) {
        self._book = book
        self._newTitle = State(initialValue: book.wrappedValue.title)
        self._newAuthor = State(initialValue: book.wrappedValue.author)
    }
    
    var body: some View {
        VStack {
            Text("Редагувати книгу")
                .font(.title)
                .padding()
            
            Form {
                TextField("Назва книги", text: $newTitle)
                TextField("Автор", text: $newAuthor)
            }
            
            HStack {
                Button("Скасувати") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()
                
                Button("Зберегти") {
                    let updatedBook = Book(id: book.id, title: newTitle, author: newAuthor)
                    db.updateBook(book: updatedBook)
                    dismiss()
                }
                .disabled(newTitle.isEmpty || newAuthor.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding()
    }
}

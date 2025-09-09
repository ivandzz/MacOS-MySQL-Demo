//
//  ContentView.swift
//  Lab10
//
//  Created by Іван Джулинський on 09.09.2025.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var db = DatabaseManager.shared
    
    @State private var newTitle = ""
    @State private var newAuthor = ""
    
    private enum Field: Hashable {
        case title, author
    }
    @FocusState private var focusedField: Field?
    
    @State private var bookToEdit: Book?
    
    @State private var bookToDelete: Book?
    @State private var showingDeleteConfirmation = false
    
    private var isAddBookFormValid: Bool {
        !newTitle.trimmingCharacters(in: .whitespaces).isEmpty && !newAuthor.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Назва книги", text: $newTitle)
                        .focused($focusedField, equals: .title)
                        .onSubmit {
                            focusedField = .author
                        }
                    
                    TextField("Автор", text: $newAuthor)
                        .focused($focusedField, equals: .author)
                        .onSubmit(addBook)

                    Button("Додати") {
                        addBook()
                    }
                    .disabled(!isAddBookFormValid)
                }
                .padding()
                
                List {
                    ForEach(db.books) { book in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title).bold()
                                Text(book.author).font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                bookToDelete = book
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Видалити", systemImage: "trash.fill")
                            }
                            
                            Button {
                                bookToEdit = book
                            } label: {
                                Label("Редагувати", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Бібліотека")
            .onAppear {
                db.fetchBooks()
            }
            .sheet(item: $bookToEdit) { book in
                if let index = db.books.firstIndex(where: { $0.id == book.id }) {
                    EditBookView(book: $db.books[index])
                }
            }
            .confirmationDialog(
                "Ви впевнені, що хочете видалити цю книгу?",
                isPresented: $showingDeleteConfirmation,
                presenting: bookToDelete
            ) { book in
                Button("Видалити \(book.title)", role: .destructive) {
                    db.deleteBook(book: book)
                }
            } message: { book in
                Text("Цю дію неможливо буде скасувати.")
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private func addBook() {
        guard isAddBookFormValid else { return }
        db.addBook(title: newTitle, author: newAuthor)
        newTitle = ""
        newAuthor = ""
        focusedField = nil
    }
}

#Preview {
    ContentView()
}

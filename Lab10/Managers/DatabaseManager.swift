//
//  DatabaseManager.swift
//  Lab10
//
//  Created by Іван Джулинський on 09.09.2025.
//

import Foundation
import NIOPosix
import MySQLNIO

final class DatabaseManager: ObservableObject {
    
    static let shared = DatabaseManager()
    
    private var group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var connection: MySQLConnection?
    
    @Published var books: [Book] = []
    
    private init() {
        connect()
    }
    
    private func connect() {
        let eventLoop = group.next()
        do {
            var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
            tlsConfiguration.certificateVerification = .none

            self.connection = try MySQLConnection.connect(
                to: .init(ipAddress: "127.0.0.1", port: 3306),
                username: "root",
                database: "librarydb",
                tlsConfiguration: tlsConfiguration,
                on: eventLoop
            ).wait()
            createTable()
            fetchBooks()
        } catch {
            print("Connection error: \(error)")
        }
    }
    
    private func createTable() {
        let query = """
        CREATE TABLE IF NOT EXISTS Books (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            author VARCHAR(255) NOT NULL
        )
        """
        do {
            let _ = try connection?.query(query).wait()
        } catch {
            print("Create table error: \(error)")
        }
    }
    
    func fetchBooks() {
        do {
            let rows = try connection?.query("SELECT id, title, author FROM Books").wait() ?? []
            let fetched = rows.compactMap { row -> Book? in
                guard
                    let id = row.column("id")?.int,
                    let title = row.column("title")?.string,
                    let author = row.column("author")?.string
                else { return nil }
                return Book(id: id, title: title, author: author)
            }
            DispatchQueue.main.async {
                self.books = fetched
            }
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    func addBook(title: String, author: String) {
        do {
            let _ = try connection?.query(
                "INSERT INTO Books (title, author) VALUES ('\(title)', '\(author)')"
            ).wait()
            fetchBooks()
        } catch {
            print("Insert error: \(error)")
        }
    }
    
    func updateBook(book: Book) {
        do {
            let _ = try connection?.query(
                "UPDATE Books SET title='\(book.title)', author='\(book.author)' WHERE id=\(book.id)"
            ).wait()
            fetchBooks()
        } catch {
            print("Update error: \(error)")
        }
    }
    
    func deleteBook(book: Book) {
        do {
            let _ = try connection?.query(
                "DELETE FROM Books WHERE id=\(book.id)"
            ).wait()
            fetchBooks()
        } catch {
            print("Delete error: \(error)")
        }
    }
}

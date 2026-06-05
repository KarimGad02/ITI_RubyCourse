
class Book
  attr_accessor :title, :author, :isbn, :count

  def initialize(title, author, isbn, count = 1)
    @title = title
    @author = author
    @isbn = isbn
    @count = count.to_i
  end

  def as_row
    "#{@title},#{@author},#{@isbn},#{@count}\n"
  end
end


class BookInventory
  attr_accessor :books
  DATA_FILE = File.expand_path('books_db.txt', __dir__)

  def initialize
    @books = []
    load_data
  end

  def add_book(title, author, isbn)
    matched_book = @books.find { |book| book.isbn == isbn }

    if matched_book
      matched_book.count += 1
      matched_book.title = title
      matched_book.author = author
      puts "-> Success: Book with ISBN '#{isbn}' already exists. Count is now #{matched_book.count}."
    else
      @books << Book.new(title, author, isbn)
      puts "-> Success: '#{title}' added to inventory!"
    end
    save_data
  end

  def remove_book(isbn)
    before_count = @books.length
    @books.reject! { |book| book.isbn == isbn }

    if @books.length < before_count
      save_data
      puts "-> Success: Book removed!"
    else
      puts "-> Error: No book found with ISBN '#{isbn}'."
    end
  end

  def list_books
    if @books.empty?
      puts "-> The inventory is currently empty."
    else
      puts "\n--- Current Inventory ---"
      @books.each do |book|
        puts "Title: #{book.title} | Author: #{book.author} | ISBN: #{book.isbn} | Count: #{book.count}"
      end
      puts "-------------------------"
    end
  end

  def sort_by_isbn
    if @books.empty?
      puts "-> The inventory is currently empty."
    else
      @books.sort_by! { |b| b.isbn }
      save_data
      puts "-> Success: Books have been sorted by ISBN!"
      list_books 
    end
  end

  def search(query, type)
    matches = case type
    when "1"
      @books.select { |book| book.title.downcase.include?(query.downcase) }
    when "2"
      @books.select { |book| book.author.downcase.include?(query.downcase) }
    when "3"
      @books.select { |book| book.isbn == query }
    else
      []
    end

    if matches.empty?
      puts "-> No books found matching your search."
    else
      puts "\n--- Search Results ---"
      matches.each do |book|
        puts "Title: #{book.title} | Author: #{book.author} | ISBN: #{book.isbn} | Count: #{book.count}"
      end
      puts "----------------------"
    end
  end

  private

  def save_data
    File.open(DATA_FILE, 'w') do |file|
      @books.each do |book|
        file.write(book.as_row)
      end
    end
  end

  def load_data
    return unless File.exist?(DATA_FILE)

    File.readlines(DATA_FILE).each do |line|
      data = line.chomp.split(',')
      next if data.length < 3

      count = data[3] ? data[3].to_i : 1
      @books << Book.new(data[0], data[1], data[2], count)
    end
  end
end


def start_app
  catalog = BookInventory.new
  keep_running = true

  while keep_running
    puts "\n=== Library Inventory System ==="
    puts "1. List all books"
    puts "2. Add a new book"
    puts "3. Remove a book by ISBN"
    puts "4. Sort books by ISBN"
    puts "5. Search books"
    puts "6. Exit"
    print "Select an option (1-6): "

    selected_option = gets.chomp.strip

    case selected_option
    when "1"
      catalog.list_books

    when "2"
      print "Enter Book Title: "
      title = gets.chomp.strip
      print "Enter Book Author: "
      author = gets.chomp.strip
      print "Enter Book ISBN: "
      isbn = gets.chomp.strip

      if title.empty? || author.empty? || isbn.empty?
        puts "-> Error: Input cannot be empty. All fields are required!"
      else
        catalog.add_book(title, author, isbn)
      end

    when "3"
      print "Enter the ISBN of the book to remove: "
      isbn = gets.chomp.strip
      if isbn.empty?
        puts "-> Error: ISBN cannot be empty!"
      else
        catalog.remove_book(isbn)
      end

    when "4"
      catalog.sort_by_isbn

    when "5"
      puts "Search by:"
      puts "1. Title"
      puts "2. Author"
      puts "3. ISBN"
      print "Select search type (1-3): "
      search_type = gets.chomp.strip

      if ["1", "2", "3"].include?(search_type)
        print "Enter search query: "
        query = gets.chomp.strip
        if query.empty?
          puts "-> Error: Search query cannot be empty!"
        else
          catalog.search(query, search_type)
        end
      else
        puts "-> Error: Invalid search type selected."
      end

    when "6"
      puts "Goodbye!"
      keep_running = false

    else
      puts "-> Error: Invalid option. Please choose a number between 1 and 6."
    end
  end
end


start_app
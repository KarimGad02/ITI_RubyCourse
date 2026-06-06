require 'time'
require_relative 'library_inventory_console'

module ActivityLogger
  def log_info(message)
    write_log('info', message)
  end

  def log_warning(message)
    write_log('warning', message)
  end

  def log_error(message)
    write_log('error', message)
  end

  private

  def write_log(level, message)
    timestamp = Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')
    File.open('app.log', 'a') do |file|
      file.puts("#{timestamp} -- #{level} -- #{message}")
    end
  end
end

class AccountHolder
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end
end

class LedgerEntry
  attr_reader :user, :value

  def initialize(user, value)
    @user = user
    @value = value
  end

  def description
    "User #{user.name} transaction with value #{value}"
  end
end

class BankCore
  def process_transactions(_entries)
    raise NotImplementedError, 'You must implement process_transactions'
  end
end

class NileBank < BankCore
  include ActivityLogger

  def initialize(members)
    @members = members
  end

  def process_transactions(entries)
    summary = entries.map(&:description).join(', ')
    log_info("Processing Transactions #{summary}...")

    entries.each do |entry|
      begin
        validate_member!(entry.user)
        validate_balance!(entry)

        entry.user.balance += entry.value
        log_info("#{entry.description} succeeded")

        log_warning("#{entry.user.name} has 0 balance") if entry.user.balance.zero?
        yield(:success, entry, nil) if block_given?
      rescue StandardError => e
        log_error("#{entry.description} failed with message #{e.message}")
        yield(:failure, entry, e.message) if block_given?
      end
    end
  end

  private

  def validate_member!(user)
    raise "#{user.name} not exist in the bank!!" unless @members.include?(user)
  end

  def validate_balance!(entry)
    raise 'Not enough balance' if entry.user.balance + entry.value < 0
  end
end

# Backward-compatible aliases.
User = AccountHolder unless defined?(User)
Transaction = LedgerEntry unless defined?(Transaction)
Bank = BankCore unless defined?(Bank)
CBABank = NileBank unless defined?(CBABank)

def build_sample_entries(main_users, outside_users)
  [
    LedgerEntry.new(main_users[0], -20),
    LedgerEntry.new(main_users[0], -30),
    LedgerEntry.new(main_users[0], -50),
    LedgerEntry.new(main_users[0], -100),
    LedgerEntry.new(main_users[0], -100),
    LedgerEntry.new(outside_users[0], -100)
  ]
end

def run_bank_demo
  puts "Inventory layer loaded with #{BookInventory.new.books.length} stored book records."

  users = [
    AccountHolder.new('Karim', 200),
    AccountHolder.new('Peter', 500),
    AccountHolder.new('Manda', 100)
  ]

  external_users = [
    AccountHolder.new('Menna', 400)
  ]

  entries = build_sample_entries(users, external_users)
  nile_bank = NileBank.new(users)

  nile_bank.process_transactions(entries) do |status, entry, error_message|
    if status == :success
      puts "Call endpoint for success of #{entry.description}"
    else
      puts "Call endpoint for failure of #{entry.description} with reason #{error_message}"
    end
  end
end

run_bank_demo if __FILE__ == $PROGRAM_NAME
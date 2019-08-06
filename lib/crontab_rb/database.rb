require 'sqlite3'
require 'pry'

module CrontabRb
  class Database
    attr_reader :db
    
    CRONTABRB = 'crontab_rb'
    
    @@db = SQLite3::Database.new "#{CRONTABRB}.db"
    @@db.results_as_hash = true
    
    def initialize
      create_table unless exists?
    end
  
    def create(options={})
      options[:updated_at] = options[:updated_at].strftime("%Y-%m-%d %H:%M:%S")
      @@db.execute "INSERT INTO #{CRONTABRB} (name, command, time, updated_at) values (:name, :command, :time, :updated_at)", options
    end
    
    def last
      @@db.execute "SELECT * FROM #{CRONTABRB} ORDER BY id DESC LIMIT 1;";
    end
    
    def all
      @@db.execute "SELECT * FROM #{CRONTABRB} ORDER BY id DESC";
    end
    
    private 
    
    def create_table
      @@db.execute <<-SQL
        create table "#{CRONTABRB}" (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name varchar(30),
          command varchar(50),
          time varchar(50),
          updated_at varchar(50)
        );
      SQL
    end
    
    def exists?
      table = @@db.execute <<-SQL
        SELECT * FROM sqlite_master WHERE type='table' AND name="#{CRONTABRB}";
      SQL
      !table.empty?
    end
  end
end

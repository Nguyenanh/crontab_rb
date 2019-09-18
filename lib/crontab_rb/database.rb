require "pstore"
require 'securerandom'
module CrontabRb
  class Database
    CRONTABRB = 'crontab_rb'

    Dir.mkdir(CrontabRb.configuration.path_storage) unless File.directory?(CrontabRb.configuration.path_storage)

    @@pstore = PStore.new("#{CrontabRb.configuration.path_storage}#{CRONTABRB}.pstore")

    def initialize(options={})
      @options                 = {}
      @options[:id]            = options[:id] || SecureRandom.uuid
      @options[:name]          = options[:name]
      @options[:command]       = options[:command]
      @options[:time]          = options[:time]
      @options[:at]            = options[:at]
      @options[:updated_at]    = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end

    def self.create(options={})
      new(options).save
    end

    def self.all
      @@pstore.transaction(true) do
        @@pstore.roots.map {|root| @@pstore[root]}
      end
    end

    def self.find(name)
      @@pstore.transaction(true) do
        @@pstore[name]
      end
    end

    def self.delete(name)
      @@pstore.transaction do
        @@pstore.delete(name)
      end
    end

    def save
      @@pstore.transaction do
        @@pstore[@options[:id]] = @options
        @options
      end
    end
  end
end

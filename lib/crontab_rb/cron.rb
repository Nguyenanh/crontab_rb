require "crontab_rb/write"
module CrontabRb
  class Cron
    attr_accessor :id
    attr_accessor :name
    attr_accessor :command
    attr_accessor :time
    attr_accessor :updated_at
    
    def initialize(attributes={})
      @id          = attributes[:id]
      @name        = attributes[:name]
      @command     = attributes[:command]
      @time        = attributes[:time]
      @updated_at  = attributes[:updated_at]
    end
    
    def self.create(options={})
      options = convert_to_symbol(options)
      options[:updated_at] = Time.now
      cron = new(options)
      cron.validate
      connection = Database.new
      connection.create(options)
      cron.id = connection.last[0]["id"]
      CrontabRb::Write.write_crontab
      cron
    end
    
    def self.all
      connection = Database.new
      records = connection.all
      records.map {|record| new(record)}
    rescue
      []
    end
    
    def validate
      raise "Time of crontab_rb only accept #{CrontabRb::Template::EVERY.keys.join(",")}" unless CrontabRb::Template::EVERY.keys.include?(time)
    end
    
    def self.convert_to_symbol(hash)
      Hash[hash.map{|k, v| [k.to_sym, v]}]
    end
  end
end
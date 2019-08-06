require "crontab_rb/write"
module CrontabRb
  class Cron
    attr_reader :id
    attr_reader :name
    attr_reader :command
    attr_reader :time
    attr_reader :updated_at
    
    def initialize(attributes={})
      id          = attributes["id"]
      name        = attributes["name"]
      command     = attributes["command"]
      time        = attributes["time"]
      updated_at  = attributes["updated_at"]
    end
    
    def self.create(options={})
      options[:updated_at] = Time.now
      connection = Database.new
      connection.create(options)
      records = connection.last
      CrontabRb::Write.write_crontab
      new(records[0])
    rescue
      new({id: nil, name: "", command: "", time: "", updated_at: Time.now})
    end
    
    def self.all
      connection = Database.new
      records = connection.all
      records.map {|record| new(record)}
    rescue
      []
    end
  end
end
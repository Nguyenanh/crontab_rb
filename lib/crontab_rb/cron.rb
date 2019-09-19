module CrontabRb
  class Cron
    attr_accessor :id
    attr_accessor :name
    attr_accessor :command
    attr_accessor :time
    attr_accessor :at
    attr_accessor :updated_at

    def initialize(attributes={})
      @id          = attributes[:id]
      @name        = attributes[:name]
      @command     = attributes[:command]
      @time        = attributes[:time]
      @at          = attributes[:at]
      @updated_at  = attributes[:updated_at]
    end

    def self.create(options={})
      options = convert_to_symbol(options)
      cron = new(options)
      cron.validate
      record          = Database.create(options)
      cron.id         = record[:id]
      cron.updated_at = record[:updated_at]
      cron.write_crontab
      cron
    end

    def self.all
      records = Database.all
      records.map {|record| new(record)}
    rescue
      []
    end

    def self.find(id)
      record = Database.find(id)
      record.nil? ? nil : new(record)
    end

    def self.update(id, options={})
      record = Database.find(id)
      return nil if record.nil?
      record[:name]    = options[:name]    || record[:name]
      record[:command] = options[:command] || record[:command]
      record[:time]    = options[:time]    || record[:time]
      record[:at]      = options[:at]      || record[:at]
      cron = new(record)
      cron.validate
      Database.new(record).save
      cron.write_crontab
      cron
    end

    def self.destroy(id)
      record = Database.find(id)
      return nil if record.nil?
      cron = new(record)
      Database.delete(id)
      cron.write_crontab
      cron
    end

    def validate
      raise "Time attribute of crontab_rb only accept #{CrontabRb::Template::EVERY.keys.join(",")}" unless CrontabRb::Template::EVERY.keys.include?(time)
    end

    def self.convert_to_symbol(hash)
      Hash[hash.map{|k, v| [k.to_sym, v]}]
    end

    def write_crontab
      Write.write_crontab
    end
  end
end

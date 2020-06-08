require "crontab_rb/version"
require "crontab_rb/configuration"
module CrontabRb
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

require "crontab_rb/database"
require "crontab_rb/write"
require "crontab_rb/cron"

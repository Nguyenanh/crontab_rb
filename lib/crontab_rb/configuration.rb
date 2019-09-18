module CrontabRb
  class Configuration
    attr_accessor :path_storage

    def initialize
      @path_storage = "#{Dir.home}/.crontab_rb/"
    end
  end
end

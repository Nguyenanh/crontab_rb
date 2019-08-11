module CrontabRb
  class Write
    def self.write_crontab
      contents = CrontabRb::Parse.from_database
      command = "crontab -"      
      IO.popen(command, 'r+') do |crontab|
        crontab.write(contents)
        crontab.close_write
      end
      success = $?.exitstatus.zero?
      if success
        puts "[write] crontab file updated"
        exit(0)
      else
        exit(1)
      end
    end
  end
end
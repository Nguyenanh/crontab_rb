module CrontabRb
  class Parse
    def self.from_database
      new.call
    end
    
    def initialize
      @job_template = ":time /bin/bash -l -c 'cd :path && bundle exec :command'"
      @path         = Dir.pwd
    end
    
    def call
      connection = Database.new
      records = connection.all
      return if records.empty?
      contents = []
      records.each do |record|
        options = record
        options["time"] = Template::EVERY[options["time"]]
        options["path"] = @path
        out = process_template(@job_template, options)
        out = out.gsub(/%/, '\%')
        contents << out
      end
      contents.join("\n")
    end
    
    protected

    def process_template(template, options)
      template.gsub(/:\w+/) do |key|
        before_and_after = [$`[-1..-1], $'[0..0]]
        option = options[key.sub(':', '')] || key
        if before_and_after.all? { |c| c == "'" }
          escape_single_quotes(option)
        elsif before_and_after.all? { |c| c == '"' }
          escape_double_quotes(option)
        else
          option
        end
      end.gsub(/\s+/m, " ").strip
    end

    def escape_single_quotes(str)
      str.gsub(/'/) { "'\\''" }
    end

    def escape_double_quotes(str)
      str.gsub(/"/) { '\"' }
    end

  end
end
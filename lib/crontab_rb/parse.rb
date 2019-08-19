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
      records = Database.all
      return "\n" if records.empty?
      contents = []
      records.each do |record|
        options = record
        options[:type] = record[:time]
        options[:time] = Template::EVERY[options[:time]]
        options[:path] = @path
        out = process_template(@job_template, options)
        out = process_template(out, options)
        contents << out + "\n"
      end
      contents.join("\n")
    end
    
    protected

    def process_template(template, options)
      template.gsub(/:\w+/) do |key|
        key_symbol = key.sub(':', '').to_sym
        if key_symbol === :at
          if options[:type].to_i/60 <= 1
            options[:at].to_i
          else
            t = options[:at].to_i*60
            Time.at(t).utc.strftime("%H %M")
          end
        else
          options[key_symbol] || key
        end
      end.gsub(/\s+/m, " ").strip
    end

    # def escape_single_quotes(str)
    #   str.gsub(/'/) { "'\\''" }
    # end
    # 
    # def escape_double_quotes(str)
    #   str.gsub(/"/) { '\"' }
    # end

  end
end
module CrontabRb
  class Parse
    def self.from_database
      new.call
    end

    def initialize
      @template     = "cd :path && bundle exec bin/rails runner -e #{Rails.env} ':command' >/dev/null 2>&1"
      @job_template = "/bin/bash -l -c ':job'"
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
        job   = process_template(@template, options)
        task  = process_template(@job_template, options.merge(:job => job))
        timer = process_timer(options)
        contents << timer + " " + task + "\n"
      end
      contents.join("\n")
    end

    protected

    def process_timer(options)
      options[:time].gsub(/:\w+/) do |key|
        if options[:type].to_i/60 <= 1
          options[:at].to_i
        else
          t = options[:at].to_i*60
          Time.at(t).utc.strftime("%M %H")
        end
      end.gsub(/\s+/m, " ").strip
    end

    def process_template(template, options)
      template.gsub(/:\w+/) do |key|
        before_and_after = [$`[-1..-1], $'[0..0]]
        option = options[key.sub(':', '').to_sym] || key

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

require 'whenever'
module CrontabRb
  class Write
      def self.write_crontab
      command = 'crontab -'
      shortcut_jobs, regular_jobs = [], []
      contents = ''
      records = Database.all
      records.each do |record|
        options = {
          at: record[:at].presence,
          job_template: "/bin/bash -l -c ':job'",
          template: "cd :path/../../current && :bundle_command :runner_command -e :environment ':task' :output",
          environment_variable: 'RAILS_ENV',
          environment: 'staging',
          path: Dir.pwd,
          chronic_options: {},
          runner_command: "bin/rails runner",
          bundle_command: "bundle exec",
          task: record[:command],
          mailto: ''
        }
        job = Whenever::Job.new(options)
        Whenever::Output::Cron.output(record[:time], job, chronic_options: {}) do |cron|
          cron << "\n\n"
          if cron[0,1] == "@"
            shortcut_jobs << cron
          else
            regular_jobs << cron
          end
        end
      end
      contents = shortcut_jobs.join + combine(regular_jobs).join


      IO.popen(command, 'r+') do |crontab|
        crontab.write(contents)
        crontab.close_write
      end
      success = $?.exitstatus.zero?
      if success
        puts "[write] crontab file updated"
      end
    end

    def self.combine(entries)
      entries.map! { |entry| entry.split(/ +/, 6) }
      0.upto(4) do |f|
        (entries.length-1).downto(1) do |i|
          next if entries[i][f] == '*'
          comparison = entries[i][0...f] + entries[i][f+1..-1]
          (i-1).downto(0) do |j|
            next if entries[j][f] == '*'
            if comparison == entries[j][0...f] + entries[j][f+1..-1]
              entries[j][f] += ',' + entries[i][f]
              entries.delete_at(i)
              break
            end
          end
        end
      end

      entries.map { |entry| entry.join(' ') }
    end
  end
end

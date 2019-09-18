module CrontabRb
  module Template
    EVERY= {
      "1"     => "*/:at * * * *",
      "60"    => ":at * * * *",
      "1440"  => ":at * * *",
      "4320"  => ":at */3 * *"
    }
  end
end

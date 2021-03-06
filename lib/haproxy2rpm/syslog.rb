# Taken from
# https://raw.github.com/jordansissel/experiments/master/ruby/eventmachine-speed/basic.rb
#
module Haproxy2Rpm
  class SyslogHandler < EventMachine::Connection

    def initialize(*args)
      # The syslog parsing stuff here taken from the 'logporter' gem.
      pri = "(?:<(?<pri>[0-9]{1,3})>)?"
      month = "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)"
      day = "(?: [1-9]|[12][0-9]|3[01])"
      hour = "(?:[01][0-9]|2[0-4])"
      minute = "(?:[0-5][0-9])"
      second = "(?:[0-5][0-9])"
      time = [hour, minute, second].join(":")
      timestamp = "(?<timestamp>#{month} #{day} #{time})"
      hostname = "(?<hostname>[A-Za-z0-9_.:\-]+)"
      header = timestamp + " " + hostname
      tag = '(?<tag>[a-zA-Z_\-\/\.0-9\[\]]+)'
      message = "(?<message>[ -~]+)"  # ascii 32 to 126
      re = "^#{pri}#{header} #{tag}:\s*#{message}"

      if RUBY_VERSION =~ /^1\.8/
        # Ruby 1.8 doesn't support named captures
        # replace (?<foo> with (
        re = re.gsub(/\(\?<[^>]+>/, "(")
      end

      @syslog3164_re = Regexp.new(re)
    end

    def receive_data(data)
      match = parse_data(data)
      message = match ? match[5] : ""
      Haproxy2Rpm.logger.debug "RECEIVED (syslog): #{data}"
      Haproxy2Rpm.logger.debug "PARSED DATA (syslog): #{match.inspect}"
      Haproxy2Rpm.logger.debug "PARSED PAYLOAD (syslog): #{message}"
      Haproxy2Rpm.rpm.process_and_send(message)
    end

    def parse_data(data)
      @syslog3164_re.match(data)
    end

  end
end

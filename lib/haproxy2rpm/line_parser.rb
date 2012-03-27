module Haproxy2Rpm
  class LineParser

    def initialize(line)
      @parts = line.split("\s")
    end

    def tq
      @tw ||= response_times[0].to_i
    end

    def tw
      @tw ||= response_times[1].to_i
    end

    def tc
      @tc ||= response_times[2].to_i
    end

    def tr
      @tr ||= response_times[3].to_i
    end

    def tt
      @tt ||= response_times[4].to_i
    end

    def status_code
      @status_code ||= @parts[10].to_i
    end

    # we need to chop \"
    def http_method
      @http_method ||= @parts[17][1..-1]
    end

    def uri
      @uri ||= URI.parse(@parts[18])
    end

    def http_path
      uri.path
    end

    def http_query
      uri.query
    end

    def is_error?
      status_code >= 500
    end

    private

    def response_times
      @response_times ||= @parts[9].split("/")
    end
  end
end

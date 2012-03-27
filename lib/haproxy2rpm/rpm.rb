module Haproxy2Rpm
  class Rpm
    
    attr_accessor :routes, :queue_time_stats_engine, :stats_engine
    attr_writer :default_route
    
    def initialize(options = {})
      agent_options = {:log => Haproxy2Rpm.logger}
      agent_options[:app_name] = options[:app_name] if options[:app_name]
      agent_options[:env] = options[:env] if options[:env]
      NewRelic::Agent.manual_start agent_options
      @stats_engine = NewRelic::Agent.agent.stats_engine
      @queue_time_stats_engine = @stats_engine.get_stats_no_scope('WebFrontend/QueueTime')
      @routes = options[:routes] || []
      if options[:config_file]
        Haproxy2Rpm.logger.info "Reading configuration from: #{options[:config_file]}"
        content = File.open(options[:config_file]){|f| f.read }
        instance_eval(content, options[:config_file])
      end
    end
    
    def config
      self
    end

    def default_route
      @default_route ||= '/default'
    end

    def process_and_send(line)
      begin
        message = message_parser.call(line)
      	request_recorder.call(message)
      rescue URI::InvalidURIError
        Haproxy2Rpm.logger.warn "Parser returned an empty message from line #{line}"
      end
    end
    
    def default_message_parser
      lambda do |line|
        LineParser.new(line)
      end
    end
    
    def message_parser
      @message_parser ||= default_message_parser
    end
    
    def message_parser=(block)
      Haproxy2Rpm.logger.debug "Installing custom parser"
      @message_parser = block
    end
    
    def default_request_recorder
      lambda do |request|
        rpm_number_unit = 1000.0
                
        params = {
          'metric' => "Controller#{route_for(request.http_path)}"
        }

        if request.is_error?
          params['is_error'] = true
          params['error_message'] = "#{request.uri} : Status code #{request.status_code}"
        end
#        record_transaction((request.tt - request.tr) / rpm_number_unit, params)
        record_transaction(request.tr / rpm_number_unit, params)
        Haproxy2Rpm.logger.debug "RECORDING (transaction) #{request.http_path}: #{params.inspect}"
        result = queue_time_stats_engine.record_data_point(request.tw / rpm_number_unit)
        Haproxy2Rpm.logger.debug "RECORDING (data point): wait time #{request.tw}, #{result.inspect}"
      end
    end
    
    def request_recorder
      @request_recorder ||= default_request_recorder
    end
    
    def request_recorder=(block)
      Haproxy2Rpm.logger.debug "Installing custom recorder"
      @request_recorder = block
    end
    
    def record_transaction(*args)
      NewRelic::Agent.record_transaction(*args)
    end
    
    protected
    
    def route_for(path)
      routes.each do |route|
        match = path.match(route[:pattern])
        if match
          return route[:target]
        end
      end
      default_route
    end
  end
end

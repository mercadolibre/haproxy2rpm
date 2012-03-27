$LOAD_PATH.unshift( File.dirname(__FILE__) )

require 'test_helper'

class Haproxy2RpmTest < Test::Unit::TestCase
  context 'parsing of haproxy files' do
    setup do
      @result = Haproxy2Rpm::LineParser.new(syslog_entry)
    end

    should 'parse the Tq (total time in ms spent waiting for client)' do
     assert_equal 6559, @result.tq
    end

    # this is the time waiting in the global queue
    should 'parse the Tw (total time in ms spent waiting in queue)' do
      assert_equal 100, @result.tw
    end

    should 'parse the Tc (total time in ms spent waiting for the connection to the final server' do
      assert_equal 7, @result.tc
    end

    # this is the response time of your application server
    should 'parse the Tr (total time in ms spent waiting for server to send full HTTP response)' do
      assert_equal 147, @result.tr
    end

    should 'parse the Tt (total time in ms spent between accept and close' do
      assert_equal 6723, @result.tt
    end

    should 'parse the status code' do
      assert_equal 200, @result.status_code
    end

    should 'parse the http method' do
      assert_equal 'GET', @result.http_method
    end

    should 'parse the uri' do
      assert_equal '/', @result.http_path
    end

    should 'parse the GET params' do
      assert_equal 'example_param=test', @result.http_query
    end
  end

  context 'is_error' do
   should 'return false for redirects' do
      assert !Haproxy2Rpm::LineParser.new(syslog_entry(:status_code => 302)).is_error?
    end

    should 'return false for 200 OK' do
      assert !Haproxy2Rpm::LineParser.new(syslog_entry(:status_code => 200)).is_error?
    end

    should 'return false for 404' do
      assert !Haproxy2Rpm::LineParser.new(syslog_entry(:status_code => 404)).is_error?
    end

    should 'return for 500 and above' do
      assert Haproxy2Rpm::LineParser.new(syslog_entry(:status_code => 500)).is_error?
    end

  end
end

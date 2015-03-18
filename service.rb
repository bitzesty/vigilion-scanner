require "open3"
class NoAVEngine < StandardError; end

module Service
  class App < Grape::API


    def self.check_avengine(*cmd)
      exit_status=nil
      err=nil
      out=nil
      Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thread|
        err = stderr.gets(nil)
        out = stdout.gets(nil)
        [stdin, stdout, stderr].each{|stream| stream.send('close')}
        exit_status = wait_thread.value
      end
      if exit_status.to_i > 0 || err
        err = err.chomp
        raise NoAVEngine, err
      elsif out
        return out.chomp
      else
        return true
      end
    end

    if ENV['AVENGINE'] == 'clamdscan'
      raise NoAVEngine, "clamd not running" unless `ps aux`.include?('clamd')
    else
      # Assumes the AVENGINE responds to --version and returns stderr if not running
      check_avengine "#{ENV['AVENGINE']} --version"
    end



    rescue_from ActiveRecord::RecordNotFound do |e|
      rack_response({error: "These aren't the droids you're looking for..."}.to_json, 404)
    end

    format :json

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      rack_response e.to_json, 400
    end

    mount API::Scan
  end
end

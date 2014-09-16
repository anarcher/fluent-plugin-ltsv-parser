#
# This module is copied from fluentd/lib/fluent/parser.rb and
# fixed not to overwrite 'time' (reserve nil) when time not found in parsed string.

module FluentExt
  class GenericParser
    include Fluent::Configurable

    config_param :time_key, :string, :default => 'time'
    config_param :time_format, :string, :default => nil
    config_param :time_parse, :bool, :default => true

    attr_accessor :log

    def initialize(logger)
      super()

      @cache1_key = nil
      @cache1_time = nil
      @cache2_key = nil
      @cache2_time = nil

      @log = logger
    end

    def parse_time(record)
      time = nil

      unless @time_parse
        return time, record
      end

      if value = record.delete(@time_key)
        if @cache1_key == value
          time = @cache1_time
        elsif @cache2_key == value
          time = @cache2_time
        else
          begin
            time = if @time_format
                     Time.strptime(value, @time_format).to_i
                   else
                     Time.parse(value).to_i
                   end
            @cache1_key = @cache2_key
            @cache1_time = @cache2_time
            @cache2_key = value
            @cache2_time = time
          rescue TypeError, ArgumentError => e
            @log.warn "Failed to parse time", :key => @time_key, :value => value
            record[@time_key] = value
          end
        end
      end

      return time, record
    end
  end

  class LTSVParser < GenericParser
    def parse(text)
      record = Hash[text.split("\t").map{|p| p.split(":", 2)}]
      return parse_time(record)
    end
  end

end

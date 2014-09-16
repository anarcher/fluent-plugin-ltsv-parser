require_relative './parser'

class Fluent::ParserOutput < Fluent::Output
    Fluent::Plugin.register_output('ltsv_parser', self)
    config_param :tag, :string, :default => nil
    config_param :reserve_data, :bool, :default => false
    config_param :key_name, :string
    config_param :filter_in, :string , :default => ""
    config_param :add_prefix, :string ,:default => nil

    attr_reader :parser

    def initialize
        super
        require 'time'
    end

    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
        define_method("log") { $log }
    end

    def configure(conf)
        super
        if @key_name[0] == ":" 
            @key_name = @key_name[1..-1].to_sym
        end
        @parser = FluentExt::LTSVParser.new(log())
        @filter_in = @filter_in.split(",").map(&:strip).select{ |e| e != "" }
    end

    def emit(tag,es,chain)
        tag = @tag || tag
        if @add_prefix
            tag = @add_prefix + "." + tag
        end
        es.each do |time,record|
            raw_value = record[@key_name]
            t,values = raw_value ? filter(parse(raw_value)) : [nil,nil]
            t ||= time

            r = @reserve_data ? record.merge(values) : values 
            if r
                Fluent::Engine.emit(tag,t,r)
            end
        end

        chain.next
    end

    private

    def filter(record)
        if @filter_in.length > 0 then
            record.select{ |x| @filter_in.include? x } 
        end
        record
    end

    def parse(string)
        return @parser.parse(string) 
    end
end

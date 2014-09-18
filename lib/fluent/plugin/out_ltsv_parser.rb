
class Fluent::ParserOutput < Fluent::Output
    Fluent::Plugin.register_output('ltsv_parser', self)
    config_param :tag, :string, :default => nil
    config_param :reserve_data, :bool, :default => false
    config_param :key_name, :string
    config_param :key_fields, :string , :default => ""
    config_param :add_prefix, :string ,:default => nil

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
        @key_fields = @key_fields.split(",").map(&:strip).select{ |e| e != "" }
    end

    def emit(tag,es,chain)
        tag = @tag || tag
        if @add_prefix
            tag = @add_prefix + "." + tag
        end
        es.each do |time,record|
            raw_value = record[@key_name]
            values = raw_value ? filter(parse(raw_value)) : nil

            r = @reserve_data ? record.merge(values) : values 
            if r
                Fluent::Engine.emit(tag,time,r)
            end
        end

        chain.next
    end

    private

    def filter(record)
        if @key_fields.length > 0 then
            _record = record.select{ |x| @key_fields.include? x } 
            if _record.keys.length == @key_fields.length then
                return _record
            else
                log.warn("#{record} has an missing fields")
            end
        else
            return record
        end
        nil
    end

    def parse(text)
        return Hash[text.split("\t").map{|p| p.split(":", 2)}]
    end
end

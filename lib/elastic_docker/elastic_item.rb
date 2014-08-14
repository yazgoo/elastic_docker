require 'nokogiri'
require 'docker'
module ElasticDocker
    class ElasticItem
        attr_accessor :p
        def from_i_(str) str[2..-1] end
        def to_snap_(str) "snap-" + str[0..8] end
        def from_ami_(str) str[4..-1] end
        def from_snap_(str) str[5..-1] end
        def each
            Kernel::p 
            name = self.class.to_s.sub /.*::/, ""
            ids = p.keys.find_all { |k| k =~ /#{name}Id.*/ }.collect { |k| p[k] }
            list(ids).each { |i| @builder.item { yield i } }
        end
        def camelize name
            name = name.to_s.split("_")
            name.shift + name.collect {|x| x.capitalize }.join
        end
        def decamelize name
            (name[0].downcase + name[1..-1]).gsub(/([A-Z])/, "_\\1").downcase.to_sym 
        end
        def decamelize_map map
            keys = map.keys
            keys.each do |key|
                sym = decamelize(key).to_sym
                map[sym] = map[key] if not map[sym]
            end
        end
        def initialize parameters, builder
            @builder = builder
            @p = parameters
            decamelize_map @p
        end
        def method_missing name, *args, &block
            this = self
            name = camelize name
            if block.nil?
                @builder.send(name, *args)
            else
                @builder.send(name, *args) do
                    this.instance_eval &block
                end
            end
        end
        def create_sshd_container image_id
            Docker::Container.create(
                'Image' => image_id[4..11], 
                'Cmd' => ["/usr/sbin/sshd", "-D"], 
                'Privileged' => true,
                'Tty' => true)
        end
        def start_sshd_container image_id
            container = create_sshd_container image_id
            container.start('NetworkMode' => 'bridge',
                            'PublishAllPorts' => true,
                            'Privileged' => true,
                           ) 
        end
        def ami id
            id = "00000000" if id.nil?
            self.imageId "ami-#{id[0..7]}"
        end
        def i id
            id = "00000000" if id.nil?
            self.instanceId "i-#{id[0..7]}"
        end
    end
end

module ElasticDocker
    class Region < ElasticItem
        def list l
            [['lol', 'http://localhost']]
        end
        def describe
            region_info do
                each do |name, endpoint_value|
                    region_name name
                    endpoint endpoint_value
                end
            end
        end
    end
end

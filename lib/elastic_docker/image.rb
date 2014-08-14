module ElasticDocker
    class Image < ElasticItem
        def list l
            l.empty? ? Docker::Image.all : l.collect { |i| Docker::Image.get(i[4..-1]) }
        end
        def image_id id
            id = "00000000" if id.nil?
            imageId "ami-#{id[0..7]}"
        end
        def create
            result = if p[:instance_id] then 
                         Docker::Container.get from_i_(p[:instance_id])
                         .commit "m" => p[:description]
                     else Docker::Image.create 'fromImage' => 'base'
                     end
            result.tag 'repo' => name[0], 'tag' => name[1],
                'force' => true if p[:name] and name = p[:name].split("_")
            image_id result.id
        end
        def describe_tag_set image
            tag_set do
                image.info['RepoTags'].each_with_index do |v, i|
                    item do
                        resource_id 'i-42424242'
                        resource_type 'instance'
                        key i
                        value v
                    end
                end if image.info['RepoTags']
            end
        end
        def describe
            images_set do
                each do |image|
                    image_id image.id
                    image_location "424242424242/#{image.id}"
                    image_state "available"
                    image_owner_id "424242424242"
                    is_public "false"
                    architecture image.json['Architecture']
                    plateform image.json['Os']
                    image_type 'machine'
                    name image.info["RepoTags"].join "," || image.id
                    root_device_type 'ebs'
                    root_device_name '/dev/sda1'
                    describe_block_device_mapping image
                    virtualization_type 'paravirtual'
                    description image.json['Comment']
                    describe_tag_set image
                end
            end
        end
        def describe_block_device_mapping image
            block_device_mapping do
                item do
                    device_name '/dev/sda1'
                    ebs do
                        snapshot_id to_snap_(image.id)
                        volume_size 8
                        delete_on_termination true
                    end
                end
            end
        end
        def deregister
            Docker::Image.get(from_ami_(p[:image_id])).remove force: true
        end
    end
end

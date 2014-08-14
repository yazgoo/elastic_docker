module ElasticDocker
    class Volume < ElasticItem
        def list l
            l.empty? ? Docker::Container.all(:all => true) : l.collect { |i| Docker::Container.get(i[4..-1]) }
        end
        def create
            # docker volume do not persist unless using a backup fs,
            # and they are tightly coupled with a container/image
            # so here is the mapping I chose:
            #   volume   -> container
            #   snapshot -> image
            # So when you attach an image, what you really do is
            # startup a new container, and then attach a volume on it
            # to another container at the device path passed
            # on the container side, mount is tweaked to detect
            # that the device actually is a directory and does a symlink 
            id = p[:snapshot_id]
            Kernel::p from_snap_(id)
            container = Docker::Container.create(
                Image: from_snap_(id), Cmd: ["/usr/sbin/sshd", "-D"],
                Tty: true, Volumes: { '/mnt' => {} })
            container = Docker::Container.get(container.id)
            volume 'available', container
        end
        def start volume_id
            volume = Docker::Container.get(volume_id)
            volume.start
            Docker::Container.get(volume_id).info['Volumes']['/mnt']
        end
        def attach_to_instance container_id, path
            container = Docker::Container.get container_id
            ip = container.info["NetworkSettings"]["IPAddress"] 
            new_ip = nil
            loop do
                container.stop
                container.start 'NetworkMode' => 'bridge',
                    'PublishAllPorts' => true,
                    'Privileged' => true,
                    'Binds' => [ "#{path}:#{params[:Device]}:rw" ]
                container = Docker::Container.get container_id
                p container.info["Volumes"]
                puts "mounted #{params[:Device]} at #{path}" 
                new_ip = container.info["NetworkSettings"]["IPAddress"] 
                break if new_ip == ip 
            end
        end
        def attach
            path = start_volume p[:volume_id].from_v_
            attach_volume_to_instance from_i_(p[:instance_id])
            volume_id p[:volume_id]
            instance_id p[:instance_id]
            device param[:device]
            status 'attached'
        end
        def detach
            Docker::Container.get(params[:volume_id].from_snap_).stop
            volume_id params[:volume_id]
            instance_id params[:instance_id]
            status 'detached'
        end
        def describe
            volume_set do
                each do |container|
                    state = container.json['State']['Running'] ? 'in-use':'available'
                    volume state, container
                end
            end
        end
        def volume state, container = nil
            volume_id "vol-#{container.nil? ? '1a2b3c4d' : container.id[0..7]}"
            size 10
            snapshot_id "snap-#{container.info['Image'][0..7]}"
            availability_zone 'us-east-1a'
            #states = ['in-use', 'available', 'attached']
            status state
            attachment_set
        end
    end
end

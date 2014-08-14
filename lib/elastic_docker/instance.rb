module ElasticDocker
    class Instance < ElasticItem
        def list l
            l.empty? ? Docker::Container.all(:all => true) : l.collect { |i| Docker::Container.get(i[2..-1]) }
        end
        def show instance, status
            info = instance.json
            net = info['NetworkSettings']
            i instance.id
            ami instance.info['Image']
            instanceState {
                state = info['State']
                code, name =  state['Running'] ? (state['Paused'] ? [42, 'paused'] : [16, 'running'])  : [80, 'stopped']
                code code; xml.name name
            }
            privateDnsName net['IPAddress']
            dnsName  net['IPAddress']
            reason {}
            key_name  'blah'
            amiLaunchIndex  0
            productCodes { xml.item  42 }
            instanceType  't1.micro' 
            start = instance.info['Created']
            if start == nil
                start = Time.now
            elsif start.instance_of? String
                start = Time.parse start
            else
                start = Time.at start
            end
            time = start.utc.iso8601
            launchTime time
            placement {
                kernelId 'aki-88aa75e1'
                availabilityZone  'us-east-1a'
            }
            monitoring { xml.state 'disabled' }
            privateIpAddress  net['IPAddress']
            ipAddress  net['IPAddress']
            architecture  'x86_64'
            rootDeviceType  'ebs'
            rootDeviceName  '/dev/sda'
            blockDeviceMapping { }
            virtualizationType  'paravirtual'
            clientToken { }
        end
        def describe_reservation
            reservationId 'r-edfe4393'
            ownerId '424242424242'
        end
        def run
           describe_reservation 
           instances_set do
               item do
                   show start_sshd_container(p[:image_id]), 'startinq'
               end
           end
        end
        def terminate
            instances_set do
                each do |instance|
                    Docker::Container.get(instance.id).delete force: true
                    current_state { code 32; name 'shutting-down' }
                    previous_state { code 16; name 'running' }
                end
            end
        end
        def start
            volume_set do
                each do |volume|
                    describe_volume p, volume.json['State']['Running'] ?
                        'in-use':'available', volume
                end
            end
        end
        def describe
            reservation_set do
                item do
                    describe_reservation
                    instances_set do
                        each do |instance|
                            show instance, 'running?'
                        end
                    end
                end
            end
        end
    end
end

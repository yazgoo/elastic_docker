module ElasticDocker
    class Snapshot < ElasticItem
        def list l
            l.empty? ? ::Docker::Image.all : l.collect { |i| Docker::Image.get i[5..-1] }
        end
        def describe
            snapshot_set do
                each do |snapshot|
                    snapshot_id to_snap_(snapshot.id)
                    volume_id to_snap_(snapshot.id).sub "snap", "vol"
                    status 'completed'
                    start_time Time.now.utc.iso8601
                    progress '100%'
                    owner_id '424242424242'
                    volume_size 2
                    description ''
                    owner_alias 'none'
                end
            end
        end
        def create
            snapshot_id to_snap_(container.info['image'])
            volume_id params[:volume_id]
            status 'completed'
        end
    end
end

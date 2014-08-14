require 'sinatra'
module ElasticDocker
    class Server < Sinatra::Base
        attr_accessor :action, :params
        configure do
            mime_type :xml, 'text/xml;charset=UTF-8'
            set :port, 8080
        end
        post '/' do
            document = Nokogiri::XML::Builder.new encoding: 'UTF-8'
            content_type :xml
            @action = params[:Action]
            ns = "http://ec2.amazonaws.com/doc/#{params['Version']}/"
            @params = params
            this = self
            p params
            document.send("#{action}Response", xmlns: ns) do
                requestId '33952628-63ab-4349-8f06-ddf079610a01'
                action = this.action.scan(/([A-Z][a-z]+)/).collect { |x| x[0] }
                begin
                    item = ElasticDocker::const_get(action[1].sub /s$/, "").new this.params, document
                    item.send action[0].downcase
                rescue => e
                    p e
                    puts e.backtrace
                end
            end
            xml = document.to_xml encoding: "UTF-8"
            # puts xml
            xml
        end
        run!
    end
end


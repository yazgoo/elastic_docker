# coding: utf-8
["version", "elastic_item", "reservation", "region", "image", "instance",
 "volume", "snapshot", "server"].each { |i| require "elastic_docker/#{i}" }

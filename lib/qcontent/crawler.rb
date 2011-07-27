#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

module QContent 
    class Crawler
        def initialize
            @proxies = 1.upto(6).collect{|index| "http://l-crwl#{index}:1080"}
        end
        
        def fetch(url)
            yield Page.new( Nokogiri::HTML(open(url,fetch_options)) )
        end

    private
        def rand_proxy
            @proxies[(rand * 6).to_i]  
        end

        def fetch_options  
            user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.2) Gecko/20061201 Firefox/2.0.0.2 (Ubuntu-feisty)"

            fetch_options = {  
                "User-Agent" => user_agent,  
                "proxy" => rand_proxy  
            }  
        end  
    end

    class Page
        def initialize(html)
            @html = html
        end

        class_eval do
            [:css,:xpath].each do |extract_by|
                define_method extract_by do |arg,&block|
                    if arg.is_a? String then
                        if block.nil? then 
                           @html.send(extract_by,arg)
                        else
                            block.call(@html.send(extract_by,arg))
                        end
                    elsif arg.is_a? Hash then
                        extract_raw = arg.collect{|key,value| [key, @html.send(extract_by,value)]}
                        data = extract_raw.collect do |key, vals|
                            ([key] * vals.size).zip(vals)
                        end
                        result =  data[0].zip(data[1]).collect{|e| Hash[ * e.flatten ]}
                        if block.nil? then
                            result
                        else
                            block.call(result)
                        end
                    else
                        raise ArgumentError.new('Argument type must String or Hash type')
                    end
                end
            end
        end
    end
end

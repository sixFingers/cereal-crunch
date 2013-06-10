#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'ruby-progressbar'

collectionName = ARGV.shift
apiKey = "vpwa68j32q2a7wr6er9fsxw7"
apiUrl = "http://api.crunchbase.com/v/1/"
resources = {companies: "company", people: "person", products: "product"}
collectionUrl = apiUrl+collectionName+".js?api_key="+apiKey;

if !File.directory?("data")
  Dir.mkdir("data")
end

if !File.directory?("data/" + collectionName)
  Dir.mkdir("data/" + collectionName)
end

collectionFileName = "./data/"+collectionName+".js"
collectionFile = open(collectionFileName, "w")

progressBar = nil
open(collectionUrl,
  :content_length_proc => lambda {|t|
    total = t
    if t && 0 < t
      progressBar = ProgressBar.create(:total => t)
    end
  },
  :progress_proc => lambda {|s|
    progressBar.progress = s
  }) {|f|
  f.each_line {|line| 
    collectionFile.puts line
  }
}


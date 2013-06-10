#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'
require 'ruby-progressbar'

# crunchscrape index [collection name]
# crunchscrape entity [entity name]
# crunchscrape collect [collection name]

command = ARGV.shift
@apiKey = "vpwa68j32q2a7wr6er9fsxw7"
@apiUrl = "http://api.crunchbase.com/v/1/"
@resources = {companies: "company", people: "person", products: "product"}

if !File.directory?("data")
  Dir.mkdir("data")
end

def makeFile source, dest
  file = open(dest, "w")
  progressBar = nil
  open(source,
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
      file.puts line
    }
  }
end

def getCollection collectionName
  collectionFileName = "./data/"+collectionName+".js"
  collectionUrl = @apiUrl + collectionName + ".js?api_key=" + @apiKey;
  if !File.directory?("data/" + collectionName)
    Dir.mkdir("data/" + collectionName)
  end
  makeFile(collectionUrl, collectionFileName)
end

def getEntity resourceName
  resourceComponents = resourceName.split("/")
  collectionName = resourceComponents[0]
  entityName = resourceComponents[1]
  entityType = @resources[collectionName.to_sym]
  entityFileName = "./data/" + collectionName + "/" + entityName + ".js"
  entityUrl = @apiUrl + entityType + "/" + entityName + ".js?api_key=" + @apiKey;
  puts entityUrl
  if !File.directory?("data/" + collectionName)
    Dir.mkdir("data/" + collectionName)
  end
  makeFile(entityUrl, entityFileName)
end

case command
  when 'index'
    collectionName = ARGV.shift
    getCollection(collectionName)
  when 'entity'
    resourceName = ARGV.shift
    getEntity(resourceName)
  when 'collect'
    collectionName = ARGV.shift
    collectionFileName = "./data/"+collectionName+".js"
    # Create collection file if it doesn't exist
    if !File.file?(collectionFileName)
      getCollection(collectionName)
    end
    # Create collection folder if it doesn't exist
    if !File.directory?("data/" + collectionName)
      Dir.mkdir("data/" + collectionName)
    end
    open(collectionFileName){|file|
      collection = JSON.parse(file.read)
      puts "#{collection.count} #{collectionName} found."
      collection.each do |item|
        resourceName = collectionName + "/" + item["permalink"]
        getEntity(resourceName)
      end
    }
end
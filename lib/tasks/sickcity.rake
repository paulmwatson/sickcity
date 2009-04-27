require 'curb'
require 'nokogiri'

namespace "sickcity" do

  desc %{Clean noisy tweets}
  task :clean_noisy_tweets => :environment do |t|
    count = 0
    Mention.find(:all, :conditions => 'message is NOT NULL').each do |m| 
      destroy = false
      # Commenting out tweet-fetching code for now
     #puts m
     #tweet_id = m.link.split('/').last
     #twitter_url = "http://twitter.com/statuses/show/#{tweet_id}.xml" 
     #puts twitter_url
     #doc = Curl::Easy.perform(twitter_url)
     #parsed_doc = Nokogiri.parse(doc.body_str)
     #puts parsed_doc

     #text = parsed_doc.search("text").inner_html
      text = m.message
      if text =~ /^RT\s/ || text =~ /http/ || text =~ /^\@/ || (text =~ /\s\#/ && !(text =~ /\s\#sickcity/))
        destroy = true
      end

      if !destroy
        Badword.all.each do |badword|
          if text =~ /#{badword.term}/
            destroy = true
          end
          break if destroy == true
        end
      end

      if destroy
        count += 1 
        puts "Deleting: #{m.message}" 
      end
      # Not ready to scrub yet
      # m.destroy if destroy
    end
  puts "Count: #{count}"
  end
end

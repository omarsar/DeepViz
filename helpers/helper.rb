require 'json'
# module for helper function
module Helpers
	# function to return the word counts
	def bpd_word_count(data)
		word_count = []
		word_count_scaled = []

		data.each do |row|
			word_count << {"text" => row[0], "size" => row[1]}
		end

		# scaling for word cloud
		word_count = word_count.reverse

		new_max = 10.0
		new_min = 1.0
		
		firstword = word_count.first
		lastword = word_count.last

		old_range = word_count.last['size'].to_i - word_count.first['size'].to_i
		new_range = new_max - new_min

		word_count_scaled << {"text" => firstword['text'], "size" => 1}
		
		word_count.slice(1..-2).each do |word|
			new_value = (((word['size'].to_i - word_count.first['size'].to_i) * new_range)/old_range) + new_min
			word_count_scaled << {"text" => word['text'], "size" => new_value}
		end

		word_count_scaled << {"text" => lastword['text'], "size" => 10}

		word_count_scaled.to_json
	end
end
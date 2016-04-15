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

		new_max = 20.0
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

	# generate the overlap between the the queried users and patients
	def overlap_words(normal, patient)
		found_words = []
		normal_count = []
		patient_count = []
		normal.each do |row|
			if patient.map(&:first).include? row[0]
				found_words << row[0]
				normal_count << row[1]
				# search over the patient to look for that same key (word)
				patient.each do |x,y|
					if x == row[0]
						patient_count << y	
					end
				end
				# have to get the values for the other two arrays
			end
		end

		return [found_words, normal_count, patient_count]
	end
end
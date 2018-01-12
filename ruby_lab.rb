#!/usr/bin/ruby

###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Jacob Senecal
# jacobsenecal@yahoo.com
#
###############################################################

$bigrams = Hash.new { |hash, key| hash[key] = Hash.new(0) } # The Bigram data structure
$name = "Jacob Senecal"

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		IO.foreach(file_name) do |line|
			# Pull title out of text line
			title = cleanup_title(line)
		  #title = /.+<SEP>(.+)/.match(line)[1]

			if not title.nil?
				# open('myfile.txt', 'a') do |f|
	 			# 	f.puts title + "\n"
				# end
			  # Split title into individual words
			  words = title.split(" ")

				# Count subsequent words
				for i in 0..words.length-2
					$bigrams[words[i]][words[i+1]] += 1
				end
			end
	end
	# puts $bigrams["love"]

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

def cleanup_title(line)
	# Extract title from line of text
	title = /.+<SEP>(.+)/.match(line)[1]

	# Eliminate braces brackets, and parentheses
	title = title.gsub(/[{\[\(].*/, "")

	# Eliminate +, =, `, *, :, _, -, #
	title = title.gsub(/[\+=`\*:_\-#"].*/, "")

	# Eliminate slashes
	title = title.gsub(/[\\\/].*/, "")

	# Eliminate feat.
	title = title.gsub(/(feat.).*/, "")

	# Eliminate punctuation
	title = title.gsub(/[\?¿!¡\.;&@%#|]/, "")

	# Make title lowercase
	title = title.downcase

	# Filter out non-english songs
	unless title.match(/^[\d\w\s']+$/)
		title = nil
	end

	return title
end

# Function returns the word the most often follows the argument passed to the function
def mcw(inWord)
	subsequent_words = $bigrams[inWord]
	most_common_word = subsequent_words.max_by{|k,v| v}
	return most_common_word[0]
end

def create_title(inWord)
	i = 0
	new_title = ""
	next_word = mcw(inWord)

	while i < 20 and not next_word.nil? do
		new_title += next_word + " "
		next_word = mcw(next_word)
	end

	return new_title
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
end

#main_loop()

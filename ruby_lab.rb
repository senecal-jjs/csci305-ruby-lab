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

			if not title.nil?
			  # Split title into individual words
			  words = title.split(" ")

				# Remove stop words
				stop_words = ['a', 'an', 'and', 'by', 'for', 'from', 'in', 'of', 'on',
					            'or', 'out', 'the', 'to', 'with']

				for i in 0..stop_words.length-1
					words.delete(stop_words[i])
				end

				# Count subsequent words
				for i in 0..words.length-2
					$bigrams[words[i]][words[i+1]] += 1
				end
			end
	end

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

# Function returns the word that most often follows the argument passed to the function
def mcw(inWord)
	subsequent_words = $bigrams[inWord]
	most_common_word = subsequent_words.max_by{|k,v| v}

	# If the word pulled from the hash is not nil return the key from the key value pair
	if not most_common_word.nil?
	  return most_common_word[0]
	else
		return nil
	end
end

# Function creates a title from a seed word and the bigram hash
def create_title(inWord)
	i = 0

	# First word of the title is the seed
	new_title = inWord

	# Next word is the most common word following the seed
	next_word = mcw(inWord)

	# Track if a word has already been used
	word_pattern = Hash.new(0)

	# Add initial words
	word_pattern[inWord] += 1
	word_pattern[next_word] += 1

	# Create list of available words
	keys = $bigrams.keys

	stop_flag = false
	while !stop_flag and not next_word.nil? do
		new_title += " " + next_word
		new_word = mcw(next_word)

		# Check if next word has already been used
		if word_pattern[new_word] > 0
			# If word has already been used terminate song title to prevent repeating pattern
			word_possibilites = $bigrams[next_word]

			# Select key out of subsequent words
			next_word_list = word_possibilites.keys
			next_word = next_word_list[rand(next_word_list.length)]
			#stop_flag = true
		end

		# Add next word to list of used words
		word_pattern[next_word] += 1
		i += 1
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
	response = ""
	begin
		puts "Enter a word [Enter 'q' to quit]: "
	  STDOUT.flush()
	  response = STDIN.gets.chomp
		if response != "q"
		  new_song = create_title(response)
		  puts new_song
		end
	end while response != "q"
end

main_loop()

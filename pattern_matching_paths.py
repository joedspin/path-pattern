# To execute from the command line:
#   cat input_file | ruby pattern_matching_paths.rb > output_file

# Problem Description
# -------------------

# You've been given two lists: the first is a list of patterns, the second
# is a list of slash-separated paths. Your job is to print, for each path,
# the pattern which best matches that path. ("Best" is defined more
# rigorously below, under "Output Format".)

# A pattern is a comma-separated sequence of non-empty fields. For a
# pattern to match a path, every field in the pattern must exactly match
# the corresponding field in the path. (Corollary: to match, a pattern and
# a path must contain the same number of fields.) For example: the pattern
# `x,y` can only match the path `x/y`. Note, however, that leading and
# trailing slashes in paths should be ignored, thus `x/y` and `/x/y/` are
# equivalent.

# Patterns can also contain a special field consisting of a *single
# asterisk*, which is a wildcard and can match any string in the path.

# For example, the pattern `A,*,B,*,C` consists of five fields: three
# strings and two wildcards. It will successfully match the paths
# `A/foo/B/bar/C` and `A/123/B/456/C`, but not `A/B/C`,
# `A/foo/bar/B/baz/C`, or `foo/B/bar/C`.

# This program relies on a Pattern class to document 
# pertinent metrics of each supplied pattern as well as a
# PatternIndex class for quickly retrieving matching patterns

# See the main function at the bottom of this file for an
# explanation of the expected input and how we handle it

# The program IS case sensitive. 'A/B' does not match 'a,*'

class Pattern:
  # Pattern class stores the field_count, wildcard_count, and
  # wildcard_score for each pattern. wilcard_score is the position
  # of the leftmost wildcard

  def __init__(pattern)
    self.field_count = 0
    self.ildcard_count = 0
    self.wildcard_score = 0
    self.fields = parse(pattern)
    self.pattern = pattern
  end

  def parse(str)
    # turn the path into an array of fields
    pattern_arr = str.split(',')
    # while we're here, let's document
    # the wildcard metrics and store the field_count
    self.field_count = len(pattern_arr)
    wildcard_found = false
    pattern_arr.each_with_index do |field, pos|
      if field == '*'
        @wildcard_count += 1
        # marks where the leftmost wildcard is found
        @wildcard_score = pos unless wildcard_found 
        wildcard_found = true
      end
    end
    pattern_arr
  end

  def document(field, pos)
    if field == '*':
        @wildcard_count += 1
        # marks where the leftmost wildcard is found
        @wildcard_score = pos unless wildcard_found 
        wildcard_found = true
      end
  end

  def to_s()
    @pattern
  end

end

class PatternIndex
  # index is a hash with the following structure:
  # KEY: an array with a field_value, field_pos, and field_count
  #    e.g., if a 3-field Pattern has the letter 'a' in the
  #    first position, the key would be ['a',0,3]
  # VALUE: an array of Patterns with that combination
  #
  # Use PatternIndex#find_best_match(path) to retrieve
  # the best match for a given path

  def initialize()
    @index = Hash.new { |hash, key| hash[key] = [] }
    @no_match = Pattern.new('NO MATCH')
  end

  def add_entry(pattern)
    pattern.fields.each_with_index do |field, pos|
      @index[[field, pos, pattern.field_count]] << pattern
    end
  end

  def find_best_match(path)
    # this hash will count how many fields match. in the end,
    # we will only look at paths matching all fields
    field_matches = Hash.new(0)
    path_arr = trim_slashes(path).split('/')
    field_count = path_arr.length
    path_arr.each_with_index do |field, pos|
      # we look up patterns with this field matching in the
      # current position with matching field_count increment the
      # number of fields matched for each returned pattern
      @index[[field, pos, field_count]].each do |pattern|
        field_matches[pattern] += 1
      end
      # do the same for patterns with wildcards in this
      # position and matching field_count
      @index[['*', pos, field_count]].each do |pattern|
        field_matches[pattern] += 1
      end
    end
    # find pattern matches by filtering the list to ones
    # that matched on all fields
    matches = field_matches.map do |pattern, _|
      pattern if field_matches[pattern] == field_count
    end
    matches = matches.compact
    best_match = @no_match
    # establish the worst case where all fields are wildcards
    fewest_wildcards = field_count
    # establish the worst wildcard_score based on our project
    # requirements. score is where the leftmost wildcard 
    # occurs so we can settle ties. When there's a tie,
    # higher score (rightmost first wildcard occurrence) wins.
    # ********
    # this is written so that if there is more than one pattern
    # that wins a tie, the first match will be the winner
    # ********
    best_wildcard_score = -1
    matches.each do |pattern|
      if (pattern.wildcard_count < fewest_wildcards) ||
        (pattern.wildcard_count == fewest_wildcards &&
        pattern.wildcard_score > best_wildcard_score)
          fewest_wildcards = pattern.wildcard_count
          best_wildcard_score = pattern.wildcard_score
          best_match = pattern
      end
    end
    best_match
  end

  def trim_slashes(str)
    str = str[1..-1] if str[0] == '/'
    str.chomp('/')
  end

end

# ************************************
# pattern_matching_paths

$\ = "\n"
# read in a file from the command line or an input file
inputs = ARGF.readlines
# The first line contains an integer, N, specifying the number of patterns
# The following N lines contain one unique pattern per line
# The next line contains an integer, M, specifying the number of paths
# The following M lines contain one path per line
# Only ASCII characters will appear in the input
pattern_index = PatternIndex.new()
pattern_count = inputs[0].chomp.to_i # N
# index the patterns
(1..pattern_count).each do |i|
  pattern = Pattern.new(inputs[i].chomp)
  pattern_index.add_entry(pattern)
end
path_count = inputs[pattern_count + 1].chomp.to_i # M
path_start = pattern_count + 2 # start of paths
# find best pattern match for each path
(path_start...path_start + path_count).each do |i|
  path = inputs[i].chomp
  print pattern_index.find_best_match(path)
end
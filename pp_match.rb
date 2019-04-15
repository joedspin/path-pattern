module MatchHelpers
  
  # return a string with leading and trailing slashes stripped
  def trim_slashes(str)
    str = str[1..-1] if str[0] == '/'
    str.chomp('/')
  end

class Pattern
  attr_reader :field_count, :fields, :pattern, :wildcard_count, :wildcard_score

  def initialize(pattern)
    @field_count = 0
    @wildcard_count = 0
    @wildcard_score = 0
    @fields = parse(pattern, ',')
    #store the original pattern
    @pattern = pattern
  end

  def parse(str, delim)
    # turn the path into an array of fields
    path_arr = str.split(delim)
    parsed = Hash.new()
    # while we're here, let's document
    # the wildcard metrics and store the field_count
    @field_count = path_arr.length
    wildcard_found = false
    path_arr.each_with_index do |field, idx|
      if field == '*'
        @wildcard_count += 1
        # marks where the leftmost wildcard is found
        @wildcard_score = idx unless wildcard_found 
        wildcard_found = true
      end
      parsed[idx] = field
    end
    parsed
  end

  # takes in a Path object as an argument and 
  # compares it to self (Pattern)
  # returns true if it is a match
  def matches?(path)
    return false unless path.field_count == self.field_count
    (0...self.field_count).each do |idx|
      return false unless 
        self.fields[idx] == path.fields[idx] || 
        self.fields[idx] == '*'
    end
    true
  end
end

class Path
  # include MatchHelpers
  attr_reader :field_count, :fields, :path

  def initialize(path)
    @field_count = 0
    @fields = parse(path, '/')
    # store the original path
    @path = path
  end

  def parse(str, delim)
    # turn the path into an array of fields
    str = trim_slashes(str)
    path_arr = str.split(delim)
    parsed = Hash.new()
    @field_count = path_arr.length
    path_arr.each_with_index do |field, idx|
      parsed[idx] = field
    end
    parsed
  end
end
end
def find_best_matches()
  include MatchHelpers
  # read in a file from the command line or an input file
  inputs = ARGF.readlines
  # The first line contains an integer, N, specifying the number of patterns
  # The following N lines contain one unique pattern per line
  # The next line contains an integer, M, specifying the number of paths
  # The following M lines contain one path per line
  # Only ASCII characters will appear in the input
  patterns = []
  paths = []
  pattern_count = inputs[0].chomp.to_i # N
  # populate our array of Pattern objects
  (1..pattern_count).each do |i|
    patterns << Pattern.new(inputs[i].chomp)
  end
  path_count = inputs[pattern_count + 1].chomp.to_i # M
  path_start = pattern_count + 2 # start of paths
  # populate our array of Path objects
  (path_start...path_start + path_count).each do |i|
    paths << Path.new(inputs[i].chomp)
  end
  @no_match_pattern = Pattern.new('NO MATCH')
  paths.each do |path|
    # define our default return value 'NO MATCH' 
    match = @no_match_pattern
    # establish the worst case where all fields are wildcards
    fewest_wildcards = path.field_count
    # establish the worst wildcard_score based on our project
    # requirements. the leftmost wildcard occurs so we can
    # settle ties. When there's a tie, rightmost
    # first wildcard index wins
    best_wildcard_score = -1
    patterns.each do |pattern|
      if pattern.matches?(path)
        if (pattern.wildcard_count < fewest_wildcards) ||
          (pattern.wildcard_count == fewest_wildcards &&
          pattern.wildcard_score > best_wildcard_score)
            fewest_wildcards = pattern.wildcard_count
            best_wildcard_score = pattern.wildcard_score
            match = pattern
        end
      end
    end
  puts match.pattern
  end
end

find_best_matches()
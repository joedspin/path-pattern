module MatchHelpers

    # return a string with leading and trailing slashes stripped
  def trim_slashes(str)
    str = str[1..-1] if str[0] == '/'
    str.chomp('/')
  end

end

class Pattern
  include MatchHelpers
  attr_reader :field_count, :fields, :myself, :wildcard_count, :wildcard_score

  def initialize(pattern)
    @field_count = 0
    @wildcard_count = 0
    @wildcard_score = 0
    @fields = parse(pattern, ',')
    #store the original pattern as myself
    @myself = pattern
  end

  def parse(str, delim)
    # turn the path into an array of fields
    str = trim_slashes(str)
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

  include MatchHelpers
  attr_reader :field_count, :fields, :myself

  def initialize(path)
    @field_count = 0
    @fields = parse(path, '/')
    # store the original path as myself
    @myself = path
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

def find_best_match()
  puts ARGV
  return
  # reads in a file from the command line
  # The first line contains an integer, N, specifying the number of patterns
  # The following N lines contain one unique pattern per line
  # The next line contains an integer, M, specifying the number of paths
  # The following M lines contain one path per line
  # Only ASCII characters will appear in the input
  patterns = []
  paths = []
  pattern_count = inputs[0] # N
  (1..pattern_count).each do |i|
    patterns << Pattern.new(inputs[i])
  end
  path_count = inputs[pattern_count + 1] # M
  path_start = pattern_count + 2 # start of paths
  (path_start...path_start + path_count).each do |i|
    paths << Path.new(inputs[i])
  end
  paths.each do |path|
    match = Pattern.new('NO MATCH')
    fewest_wildcards = path.field_count
    best_wildcard_score = -1
    patterns.each do |pattern|
      # checkit = 'pattern ' + pattern.myself + ' path ' + path.myself + 'matches? ' + pattern.matches?(path).to_s
      # checkit = 'pattern ' + pattern.myself + ' path ' + path.myself + 'matches? ' + pattern.matches?(path).to_s
      # puts checkit
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
  puts match.myself
  end
end

the_input = the_input = [6,
'*,b,*',
'a,*,*',
'*,*,c',
'foo,bar,baz',
'w,x,*,*',
'*,x,y,z',
9,
'/w/x/y/z/',
'a/b/c',
'foo/',
'foo/bar/',
'foo/bar/baz/',
'/a/b/c/',
'w/x/y/q',
'////',
'/*foo//baz/']

# find_best_match(the_input)
find_best_match()
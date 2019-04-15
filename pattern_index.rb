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
    p = Pattern.new(pattern)
    # turn the path into an array of fields
    field_arr = pattern.split(',')
    # while we're here, let's document
    # the wildcard metrics and store the field_count
    p.field_count = field_arr.length
    wildcard_found = false
    field_arr.each_with_index do |field, pos|
      @index[[field, pos, p.field_count]] << p
      if field == '*'
        p.wildcard_count += 1
        # marks where the leftmost wildcard is found
        p.wildcard_score = pos unless wildcard_found 
        wildcard_found = true
      end
    end
  end

  def find_best_match(path)
    # this hash will count how many fields match. in the end,
    # we will only look at patterns matching all fields
    field_matches = Hash.new(0)
    field_arr = trim_slashes(path).split('/')
    field_count = field_arr.length
    field_arr.each_with_index do |field, pos|
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
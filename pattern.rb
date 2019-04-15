class Pattern
  # Pattern class stores the field_count, wildcard_count, and
  # wildcard_score for each pattern. wilcard_score is the position of
  # the leftmost wildcard. Values get stored when Pattern is indexed
  attr_accessor :field_count, :wildcard_count, :wildcard_score

  def initialize(pattern)
    @field_count = 0
    @wildcard_count = 0
    @wildcard_score = 0
    @pattern = pattern
  end

  def to_s()
    @pattern
  end

end
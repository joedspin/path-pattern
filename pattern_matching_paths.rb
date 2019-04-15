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

# This program is case sensitive. 'A/B' does not match 'a,*'

# written by Joe D'Espinosa, April 2019

require_relative 'pattern'
require_relative 'pattern_index'
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
  pattern = inputs[i].chomp
  pattern_index.add_entry(pattern)
end
path_count = inputs[pattern_count + 1].chomp.to_i # M
path_start = pattern_count + 2 # start of paths
# find best pattern match for each path
(path_start...path_start + path_count).each do |i|
  path = inputs[i].chomp
  print pattern_index.find_best_match(path)
end
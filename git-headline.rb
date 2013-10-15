#!/usr/bin/env ruby
require 'date'

# Input is either specified as filename(s), piped in, or the __END__ data
def input_file
  (ARGV.empty? and $stdin.tty?) ? DATA : ARGF
end

# lines of input mapped to booleans for non-empty chars
def pixels
  input_file.lines.map do |line|
    line.chars.map { |c| !!(c =~ /\S/) }
  end
end

# pixels, taken column-wise, mapped to dates
def dated_pixels
  pixels.transpose.flatten.each_with_index.map do |pixel,i|
    [start_date + i, pixel]
  end
end

# 52 weeks ago from the nearest Sunday
def start_date
  @start_date ||= Date.today - Date.today.wday - 7 * 52
end

# commits should be made for active pixel dates
def commit_dates
  dated_pixels.select { |date,active| active }.map(&:first)
end

# the branch to which we'll export commits
def branch
  'refs/heads/master'
end

# fast-export uses "marks" to link data together
def next_mark
  @mark ||= 0
  @mark += 1
  ":#{@mark}"
end

# export a file, returning its mark and the text representing the blob
def fast_export_file
  mark = next_mark
  text = <<FILE
blob
mark #{mark}
#{fast_export_data 'Yay, data!'}
FILE
  return [mark, text]
end

# Retrieve the specified key from `git config`
def config(key)
  %x[git config #{key}].chomp
end

# "Real name" portion of the fast export user
def fast_export_name
  config('user.name')
end

# email@example.com portion of the fast export user
def fast_export_email
  ENV['EMAIL'] || config('user.email')
end

def fast_export_user
  @user ||= "#{fast_export_name} <#{fast_export_email}>"
end

# .to_time returns midnight.  Use 12:00 to ensure the date is consistent
def noon(date)
  date.to_time + 12 * 60 * 60
end

# format a timestamp the way fast-export expects
def fast_export_timestamp(time)
  time.strftime('%s %z')
end

# formatted data chunk (without trailing newline)
def fast_export_data(data)
  # add a newline if one isn't present
  lines = data.sub(/(?<!\n)\Z/, "\n")
  size = lines.size
  return <<DATA.chomp
data #{size}
#{data}
DATA
end

# retrieve the initial SHA-1 for the first commit
def initial_ref
  %x[git rev-parse #{branch}].chomp
end

# create a commit containing a single file with metadata for the correct date
def fast_export_commit(time)
  file_mark, file_text = fast_export_file
  stamp = fast_export_timestamp(time)
  parent = @commit_mark || initial_ref
  reset = @commit_mark ? '' : "reset #{branch}\n"
  @commit_mark = next_mark
  return file_text + <<COMMIT
#{reset}commit #{branch}
mark #{@commit_mark}
author #{fast_export_user} #{stamp}
committer #{fast_export_user} #{stamp}
#{fast_export_data 'Yay, a commit!'}
from #{parent}
M 100644 #{file_mark} yay_a_file.txt
COMMIT
end

# create some number of commits, each a minute apart
def make_commits(date, commits = 20)
  commits.times do |n|
    puts fast_export_commit(noon(date) + n * 60)
  end
end

# alter the number of commits per pixel to work around some caching issues
def n_commits(date)
  20 # back to normal?
end

# create commits for each needed date
def fast_export
  commit_dates.each do |date|
    make_commits(date, n_commits(date))
  end
end

fast_export

# default input:
__END__
                                                  
   0  0 0 000  000   0   0 000   0   0  00  0   0 
   0  0 0 0  0 0     00 00 0     00  0 0  0 0   0 
   0000 0 000  00    0 0 0 00    0 0 0 0  0 0 0 0 
   0  0 0 0  0 0     0 0 0 0     0  00 0  0 0 0 0 
   0  0 0 0  0 000   0   0 000   0   0  00   0 0  
                                                  

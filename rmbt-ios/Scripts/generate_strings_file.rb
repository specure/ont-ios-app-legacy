#!/usr/bin/env ruby

CUR_DIR = File.dirname(__FILE__)
TMP_DIR = "/tmp/_strings"

dictionary = {}

# remove old dir
system("rm -r #{TMP_DIR}/* 2>/dev/null")

# create dirs
system("mkdir #{TMP_DIR} 2>/dev/null")
system("mkdir #{TMP_DIR}/Base.lproj")

# copy source files
system("cp #{CUR_DIR}/../Sources/*.{swift,m} #{TMP_DIR}/.")

# get keys and values from each swift source file
Dir.glob("#{TMP_DIR}/*.swift") do |file|
  puts file

  file_contents = IO.read(file)

  file_contents.scan(/NSLocalizedString\("(.*)",[ ]+value: "(.*)",[ ]+comment: "(.*)"\)/) { |key,value,comment|
    #puts key
    #puts value
    #puts comment
    dictionary[key] = value
  }
end

p dictionary

# remove value: and run genstrings
Dir.glob("#{TMP_DIR}/*.swift") do |file|
  sed_command = "s/NSLocalizedString\\(\"(.*)\",[ ]+value: \"(.*)\",[ ]+comment: \"(.*)\"\\)/NSLocalizedString\\(\"\\1\", comment: \"\\3\"\\)/g"
#  puts "sed -E '#{sed_command}' #{file} > #{TMP_DIR}/tmp.swift"
  system("sed -E '#{sed_command}' #{file} > #{TMP_DIR}/tmp.swift")
  system("mv #{TMP_DIR}/tmp.swift #{file}")
end

system("genstrings -o #{TMP_DIR}/Base.lproj #{TMP_DIR}/*.{swift,m}")

# fix swift values

# UTF-16 to UTF-8
system("iconv -f UTF-16 -t UTF-8 #{TMP_DIR}/Base.lproj/Localizable.strings > #{TMP_DIR}/Base.lproj/_Localizable.strings")

# put values in Localizable.strings
loc_contents = IO.read("#{TMP_DIR}/Base.lproj/_Localizable.strings")

dictionary.each do |key,value|
  loc_contents = loc_contents.gsub(/"#{key}";/, "\"#{value}\";")
end

File.open("#{TMP_DIR}/Base.lproj/_Localizable.strings", 'w') do |out|
    out << loc_contents
end

# UTF-8 to UTF-16
system("iconv -f UTF-8 -t UTF-16 #{TMP_DIR}/Base.lproj/_Localizable.strings > #{TMP_DIR}/Base.lproj/Localizable.strings")

# delete temp file
system("rm #{TMP_DIR}/Base.lproj/_Localizable.strings")

# open folder
system("open #{TMP_DIR}/Base.lproj")


Before do
  FileUtils.rm_rf(Paths.test_dir) if Paths.test_dir.exist?
  FileUtils.mkdir_p(Paths.test_dir) unless Paths.test_dir.directory?
  Dir.chdir(Paths.test_dir)
end

#

After do
  FileUtils.rm_rf(Paths.test_dir) if Paths.test_dir.exist?
  Paths.output_file.delete if Paths.output_file.exist?
  Paths.status_file.delete if Paths.status_file.exist?
  Dir.chdir(Paths.test_dir.parent)
end

#

Given(%r!^I do not have a "(.*)" directory$!) do |path|
  Paths.test_dir.join(path).directory?
end

#

Given(%r!^I have an? "(.*)" page(?: with (.*) "(.*)")? that contains "(.*)"$!) do |file, key, value, text|
  File.write(file, Jekyll::Utils.strip_heredoc(<<-DATA))
    ---
    #{key || "layout"}: #{value || "nil"}
    ---

    #{text}
  DATA
end

#

Given(%r!^I have an? "(.*)" file that contains "(.*)"$!) do |file, text|
  File.write(file, text)
end

#

Given(%r!^I have an? "(.*)" file with content:$!) do |file, text|
  File.write(file, text)
end

#

Given(%r!^I have an? (.*) directory$!) do |dir|
  unless File.directory?(dir)
    then FileUtils.mkdir_p(dir)
  end
end

#

Given(%r!^I have a configuration file with "(.*)" set to "(.*)"$!) do |key, value|
  config = \
    if source_dir.join("_config.yml").exist?
      SafeYAML.load_file(source_dir.join("_config.yml"))
    else
      {}
    end
  config[key] = YAML.load(value)
  File.write("_config.yml", YAML.dump(config))
end

#

Given(%r!^I have a configuration file with:$!) do |table|
  table.hashes.each do |row|
    step %(I have a configuration file with "#{row["key"]}" set to "#{row["value"]}")
  end
end

#

Given(%r!^I have a configuration file with "([^\"]*)" set to:$!) do |key, table|
  File.open("_config.yml", "w") do |f|
    f.write("#{key}:\n")
    table.hashes.each do |row|
      f.write("- #{row["value"]}\n")
    end
  end
end

#

Given(%r!^I have moved into the "(.*)" directory$!) do |dir|
  Dir.chdir(dir)
end

#

When(%r!^I run jekyll\+(.*)$!) do |args|
  run_jekyll(args)
  if args.include?("--verbose") || ENV["DEBUG"]
    $stderr.puts "\n#{jekyll_run_output}\n"
  end
end

#

When(%r!^I run bundle(.*)$!) do |args|
  run_bundle(args)
  if args.include?("--verbose") || ENV["DEBUG"]
    $stderr.puts "\n#{jekyll_run_output}\n"
  end
end

#

Then(%r!^the (.*) directory should +(not )?exist$!) do |dir, negative|
  if negative.nil?
    expect(Pathname.new(dir)).to exist
  else
    expect(Pathname.new(dir)).to_not exist
  end
end

#

Then(%r!^I should (not )?see "(.*)" in "(.*)"$!) do |negative, text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text, Regexp::MULTILINE)
  if negative.nil? || negative.empty?
    expect(file_contents(file)).to match regexp
  else
    expect(file_contents(file)).not_to match regexp
  end
end

#

Then(%r!^I should (not )?see "(.*)" in "(.*)" if on Windows$!) do |negative, text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text, Regexp::MULTILINE)
  if negative.nil? || negative.empty?
    if Jekyll::Utils::Platforms.really_windows?
      expect(file_contents(file)).to match regexp
    else
      expect(file_contents(file)).not_to match regexp
    end
  end
end

#

Then(%r!^I should (not )?see "(.*)" in "(.*)" unless Windows$!) do |negative, text, file|
  step %(the "#{file}" file should exist)
  regexp = Regexp.new(text, Regexp::MULTILINE)
  if negative.nil? || negative.empty?
    if Jekyll::Utils::Platforms.really_windows?
      expect(file_contents(file)).not_to match regexp
    else
      expect(file_contents(file)).to match regexp
    end
  end
end

#

Then(%r!^I should see exactly "(.*)" in "(.*)"$!) do |text, file|
  step %(the "#{file}" file should exist)
  expect(file_contents(file).strip).to eq text
end

#

Then(%r!^the "(.*)" file should +(not )?exist$!) do |file, negative|
  if negative.nil?
    expect(Pathname.new(file)).to exist
  else
    expect(Pathname.new(file)).to_not exist
  end
end

#

Then(%r!^I should (not )?see "(.*)" in the build output$!) do |negative, text|
  if negative.nil? || negative.empty?
    expect(jekyll_run_output).to match Regexp.new(text)
  else
    expect(jekyll_run_output).not_to match Regexp.new(text)
  end
end

#

Then(%r!^I should get a zero exit(?:\-| )status$!) do
  step %(I should see "EXIT STATUS: 0" in the build output)
end

#

Then(%r!^I should get a non-zero exit(?:\-| )status$!) do
  step %(I should not see "EXIT STATUS: 0" in the build output)
end

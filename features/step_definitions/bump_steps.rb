require 'securerandom'

Given /^I have a git project of version '(.*)'$/ do |version|
  Dir.chdir(origin_dir) do
    `git init`
    expect($?.success?).to be true
    `git config receive.denyCurrentBranch ignore`
    expect($?.success?).to be true
  end
  Dir.chdir(project_dir) do
    `git clone file://#{origin_dir}/.git .`
    expect($?.success?).to be true
    `touch README`
    expect($?.success?).to be true
    `git add README`
    expect($?.success?).to be true
    `git commit -m "initial commit"`
    expect($?.success?).to be true
    `git tag -a -m "Version #{version}" #{version}`
    expect($?.success?).to be true
    `git push origin master -u --tags`
    expect($?.success?).to be true
    setup_directory
  end
end

Given /^a commit with the message "(.*?)" on the "(.*?)" branch$/ do |msg, branch|
  Dir.chdir(project_dir) do
    `echo #{SecureRandom.uuid} > Randomfile`
    `git add Randomfile`
    `git commit -m "#{msg}"`
    `git push origin #{branch}`
  end
end

Then /^the version should be '(.*)'$/ do |version|
  Dir.chdir(project_dir) {
    expect(ThorSCMVersion.versioner.from_path.to_s).to eq(version)
  }
end

Then /^the version should be '(.+)' in the p4 project directory$/ do |version|
  Dir.chdir(perforce_project_dir) {
    expect(ThorSCMVersion.versioner.from_path.to_s).to eq(version)
  }
end

Then /^the git server version should be '(.*)'$/ do |version|
  Dir.chdir(origin_dir) {
    expect(ThorSCMVersion.versioner.from_path.to_s).to eq(version)
  }
end

Given /^the origin version is '(.+)'$/ do |version|
  Dir.chdir(origin_dir) {
    cmd = %Q[git tag -a #{version} -m "Version #{version}"]
    `#{cmd}`
  }  
end

When /^I run `(.*)` from the temp directory( and expect a non-zero exit)?$/ do |command, nonzero_exit|
  Dir.chdir(project_dir) {
    out = `#{command}`
    unless $?.success? or nonzero_exit
      puts out
      fail
    end
  }
end

When /^I run `(.*)` from the p4 project directory$/ do |run|
  Dir.chdir(perforce_project_dir) {
    `#{run}`
  }
end

Given /^I have a p4 project of version '(.*)'$/ do |version|
  ENV['P4PORT']    = 'p4server.example.com:1666'
  ENV['P4USER']    = 'tester'
  ENV['P4PASSWD']  = 'tester'
  ENV['P4CHARSET'] = ''
  ENV['P4CLIENT']  = 'testers_workspace'
  Dir.chdir(perforce_project_dir) do
    ThorSCMVersion::Perforce.connection do
      `p4 sync -f`
    end
    File.chmod(0666,"VERSION")
    File.open('VERSION', 'w') do |f|
      f.write(version)
    end
    setup_directory
  end
end

Then /^the p4 server version should be '(.*)'$/ do |version|
  ENV['P4PORT']    = 'p4server.example.com:1666'
  ENV['P4USER']    = 'tester'
  ENV['P4PASSWD']  = 'tester'
  ENV['P4CHARSET'] = ''
  ENV['P4CLIENT']  = 'testers_workspace'
  Dir.chdir(perforce_project_dir) do
    ThorSCMVersion::Perforce.connection do
      `p4 print #{File.join(perforce_project_dir,'VERSION')}`
      #p4.run_print(File.join(perforce_project_dir,'VERSION'))[1].should == version
    end
  end
end

Then(/^there is a version '(.+)' on another branch$/) do |version|
  Dir.chdir(project_dir) do
    `git checkout -b another_branch`
    expect($?.success?).to be true
    `echo anotherbranch > README`
    expect($?.success?).to be true
    `git commit -am 'commit'`
    expect($?.success?).to be true
    `git tag #{version}`
    expect($?.success?).to be true
    `git checkout master`
    expect($?.success?).to be true
  end
end

Given(/^there is a tag '(.*)'$/) do |version|
  Dir.chdir(project_dir) do
    `git tag #{version}`
  end
end

Given(/^.git is a file pointing to the .git folder in a parent module$/) do
  project_git_path = File.join(project_dir, '.git')
  git_folder_path  = File.join(parent_module_dir, '.git')
  expect(File.directory?( project_git_path )).to be true
  File.rename project_git_path, git_folder_path
  `echo "gitdir: #{ git_folder_path }" > "#{ project_git_path }"`
end

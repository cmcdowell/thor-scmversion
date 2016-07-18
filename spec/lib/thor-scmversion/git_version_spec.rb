require 'spec_helper'

module ThorSCMVersion
  describe GitVersion do
    it "should detect if a tag is contained on a given branch" do
      allow(ShellUtils).to receive(:sh).and_return(<<OUT)
* constrain_bump_to_branch
  master
OUT
      expect(GitVersion.contained_in_current_branch?('0.0.1')).not_to be_nil
    end
  end
end

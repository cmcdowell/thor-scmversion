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
    context "that fails to push tags to remote git repo" do
      it "raises a GitError" do
        subject { GitVersion.new('1', '2', '3') }
        allow(ShellUtils).to receive(:sh).and_raise(RuntimeError)

        expect { subject.tag }.to raise_error(GitError)
      end
    end
  end
end

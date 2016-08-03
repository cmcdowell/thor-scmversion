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
    context "when tags fail to push to remote git repo" do
      it "raises a GitError" do
        subject { GitVersion.new('1', '2', '3') }
        allow(ShellUtils).to receive(:sh).and_raise(RuntimeError)

        expect { subject.tag }.to raise_error(GitError)
      end
    end

    describe "latest_from_path" do
      it "returns the latest tag" do
        allow(Open3).to receive(:popen3).and_yield(nil, StringIO.new("0.0.1\n0.0.2"), nil)
        allow(GitVersion).to receive(:contained_in_current_branch?).and_return(true)

        expect(GitVersion.latest_from_path('.').to_s).to eq('0.0.2')
      end
    end
  end
end

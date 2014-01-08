require_relative 'spec_helper'

describe Jiraby::Project do
  before(:each) do
    @project = Jiraby::Project.new(json_data('project_TST.json'))
  end

  describe '#issue_types' do
    it "returns issue type data" do
      issue_types = @project.issue_types
      issue_types.should include('Bug')
      issue_types.should include('Task')
      ['self', 'id', 'description', 'name', 'subtask'].each do |field|
        issue_types['Bug'].should include(field)
        issue_types['Task'].should include(field)
      end
    end
  end #issue_types
end # Jiraby::Project


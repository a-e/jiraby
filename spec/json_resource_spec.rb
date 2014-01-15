require_relative 'spec_helper'
require 'jiraby/jira'
require 'jiraby/rest'
require 'jiraby/json_resource'

describe Jiraby::JSONResource do
  it "tinkering" do
    @jira = Jiraby::Jira.new("localhost:8080")
    @jira.login('admin', 'admin')
    @r = Jiraby::JSONResource.new(@jira.rest.base_url)

    issue = @r['issue/TST-1'].get @jira.rest.headers
    issue.should be_a(Hash)

    bogus = @r['issue/bogus'].get @jira.rest.headers
    bogus.should be_a(Hash)
  end

end # describe Jiraby::JSONResource


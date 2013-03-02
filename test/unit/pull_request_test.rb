require 'test_helper'

class PullRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def test_extract_data_from_branch_name
    branch_naming_convention = ':ticket_:project_:type_:title'
    test_branch_name = '6644_o2r13_bug_pick_and_pack_not_completing'

    parsed_data = PullRequest.extract_data_from_branch_name(
      test_branch_name, branch_naming_convention
    )
    assert parsed_data.is_a? Hash
    assert_equal 4, parsed_data.length, "something's amiss in branch name keys: #{parsed_data.keys.inspect}"
    assert_equal '6644', parsed_data[:ticket], 
      "unexpected ticket_id: #{parsed_data[:ticket]}"
    assert_equal 'o2r13', parsed_data[:project], 
      "unexpected project: #{parsed_data[:project]}"
    assert_equal 'bug', parsed_data[:type], 
      "unexpected type: #{parsed_data[:type]}"
    assert_equal 'pick_and_pack_not_completing', parsed_data[:title], 
      "unexpected title: #{parsed_data[:title]}"


  end
end

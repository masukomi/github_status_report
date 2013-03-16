require 'test_helper'

class PullRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def test_extract_data_from_branch_name
    branch_naming_convention = ':ticket_:project_:type_:title'
    repo = Repo.new(:branch_naming_convention=>branch_naming_convention)
    test_branch_name = '6644_o2r13_bug_pick_and_pack_not_completing'
    test_branch_name_2 = 'xxxx_o2r13_bug_pick_and_pack_not_completing'

    parsed_data = PullRequest.extract_data_from_branch_name(
      test_branch_name, repo
    )
    assert parsed_data.is_a? Hash
    assert_equal 5, parsed_data.length, "something's amiss in branch name keys: #{parsed_data.keys.inspect}"
    assert_equal '6644', parsed_data[:ticket], 
      "unexpected ticket_id: #{parsed_data[:ticket]}"
    assert_equal false, parsed_data[:bad_ticket_id]
    assert_equal 'o2r13', parsed_data[:project], 
      "unexpected project: #{parsed_data[:project]}"
    assert_equal 'bug', parsed_data[:type], 
      "unexpected type: #{parsed_data[:type]}"
    assert_equal 'pick_and_pack_not_completing', parsed_data[:title], 
      "unexpected title: '#{parsed_data[:title]}' via regexp '#{repo.get_regexp_for_branch_names({:as_string=>true})}'"

    parsed_data = PullRequest.extract_data_from_branch_name(
      test_branch_name_2, repo
    )

    assert_equal 'xxxx', parsed_data[:ticket], 
      "unexpected ticket_id: #{parsed_data[:ticket]}"
    assert_equal true, parsed_data[:bad_ticket_id]
    assert_equal 'o2r13', parsed_data[:project], 
      "unexpected project: #{parsed_data[:project]}"
  end
end

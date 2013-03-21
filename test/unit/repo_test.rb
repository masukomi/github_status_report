require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "get_branch_name_keys" do 
    bn1 = ':ticket_:project_:type_:title'
    repo = Repo.new(:branch_naming_convention=>bn1, :numeric_tickets => true)
    assert_equal [:ticket, :project, :type, :title], repo.get_branch_name_keys()
  end
  test "get_regexp_for_branch_name" do
      bn1 = ':ticket_:project_:type_:title'
      bn2 = ':title_:ticket'

      repo = Repo.new(:branch_naming_convention=>bn1, :numeric_tickets => true)

      assert_equal '^(\d+)_(.*?)_(.*?)_(.*)', repo.get_regexp_for_branch_names({:as_string=>true})
      assert_equal '^(.*?)_(.*?)_(.*?)_(.*)', repo.get_regexp_for_branch_names(
                                                  {:as_string=>true,
                                                    :ignore_numeric=>true
                                                  })
      repo.numeric_tickets = false
      assert_equal '^(.*?)_(.*?)_(.*?)_(.*)', repo.get_regexp_for_branch_names({:as_string=>true})

      repo.numeric_tickets = true
      repo.branch_naming_convention = bn2
      # now test that it puts the \d+ 
      # at the right place 
      # AND that it's handling trailing 
      # underscores correctly (not making them)
      assert_equal '^(.*?)_(\d+)', repo.get_regexp_for_branch_names({:as_string=>true})
      repo.numeric_tickets = false
      assert_equal '^(.*?)_(.*)', repo.get_regexp_for_branch_names({:as_string=>true})

      repo.branch_naming_convention = ''
      assert_equal '^(.*)', repo.get_regexp_for_branch_names({:as_string=>true})
  end

  test "sort_pull_recs_by_day" do
    pr1 = PullRequest.new()
      pr1.created_at = 2.days.ago.at_beginning_of_day
      pr1.ticket_id = 1
    pr2 = PullRequest.new()
      pr2.created_at = 2.days.ago.at_beginning_of_day
      pr2.ticket_id = 2
    pr3 = PullRequest.new()
      pr3.created_at = 3.days.ago.at_beginning_of_day
      pr3.ticket_id = 3

    pull_requests = [pr2,pr1,pr3]

    response = Repo.sort_pull_recs_by_day(pull_requests)
    sorted_response_keys = response.keys.sort # [3 days ago, 2 days ago]
    assert_equal 2, response.keys.size()
    assert_equal 3.days.ago.at_beginning_of_day, sorted_response_keys.first
  end
end

require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end


  test "get_branch_name_keys" do
    bn1 = ':ticket_:project_:type_:title'

    repo = Repo.new(:branch_naming_convention=>bn1, 
                    :numeric_tickets => true
            )

    expected_keys = %w{ticket project type title}
    assert_equal expected_keys, repo.get_branch_name_keys()
  end
  test "get_regexp_for_branch_name" do
      bn1 = ':ticket_:project_:type_:title'
      bn2 = ':title_:ticket'

      repo = Repo.new(:branch_naming_convention=>bn1, 
                      :numeric_tickets => true
              )

      assert_equal '\d+_(.*?)_(.*?)_(.*?)', repo.get_regexp_for_branch_names(true)
      repo.numeric_tickets = false
      assert_equal '(.*?)_(.*?)_(.*?)_(.*)', repo.get_regexp_for_branch_names(true)
      # when there are no numeric tickets it doesn't do the ? in the last block.
      # (it's not needed)

      repo.numeric_tickets = true
      repo.branch_naming_convention = bn2
      # now test that it puts the \d+ 
      # at the right place 
      # AND that it's handling trailing 
      # underscores correctly (not making them)
      assert_equal '(.*?)_\d+', repo.get_regexp_for_branch_names(true)
      repo.numeric_tickets = false
      assert_equal '(.*?)_(.*)', repo.get_regexp_for_branch_names(true)


  end
end

require 'octokit'

require 'always_be_contributing/user'

module AlwaysBeContributing
  # An Org knows how to grab all its members
  # from GitHub and sort by contributions
  class Org < Struct.new(:name)
    # returns a list of Users for each member of the Org
    def members
      member_ids.map { |id| User.new id }
    end

    # take each member of the Org, sort by number
    # of contributions since begin_date
    def sorted_members(begin_date)
      members.
        sort_by { |user| user.contribution_count_since(begin_date) }.
        reverse
    end

    private

    def member_ids
      Octokit.org_members(name).map(&:login)
    end
  end
end

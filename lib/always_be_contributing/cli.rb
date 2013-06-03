require 'always_be_contributing/core_ext/date/month_calculator'
require 'always_be_contributing/org'
require 'octokit'

module AlwaysBeContributing
  # CLI manages parameter handling, top level error handling, final
  # rendering and acts as the entry point to main program logic
  #
  # Example:
  #
  #     CLI.new(['github']).run
  class CLI
    attr_accessor :github_org

    def initialize(args)
      @github_org = args[0]
      Octokit.netrc = true
    end

    def run
      exit_usage unless github_org
      render
    end

    private

    def begin_date
      @begin_date ||= begin
        Date.today.beginning_of_month
      end
    end

    def sorted_members
      @sorted_members ||= begin
        Org.new(github_org).
          sorted_members(begin_date)
      end
    end

    # :reek:Duplication: { max_calls: 2 }
    def render
      puts '=== Contributions for members of ' <<
           "github-org: #{github_org} since: #{begin_date} ==="
      sorted_members.each do |member|
        printf "%15s %3i\n",
               member.name,
               member.contribution_count_since(begin_date)
      end
    end

    def exit_usage
      $stderr.puts "usage: #{$PROGRAM_NAME} github-org"
      exit 1
    end
  end
end

require "graphql/client"
require "graphql/client/http"

module GithubGraphQL
  GITHUB_TOKEN = ENV["GITHUB_TOKEN"]
  ORGANIZATION = ENV["GITHUB_ORGANIZATION"]

  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
      def headers(context)
        { Authorization: "bearer #{GITHUB_TOKEN}" }
      end
    end

  if !File.file?("schema.json")
    puts "schema.json doesn't exist yet, download and create it"
    GraphQL::Client.dump_schema(HTTP, "schema.json")
  end

  Schema = GraphQL::Client.load_schema("schema.json")
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  OrganizationPullRequestsWithReviewRequestsQuery = Client.parse <<-"GRAPHQL"
    query {
      organization(login:"#{ORGANIZATION}") {
        repositories(first:30) {
          nodes {
            name
            pullRequests(first:50, states:OPEN) {
              nodes {
                id
                title
                url
                reviewRequests(first:100) {
                  nodes {
                    requestedReviewer {
                      ... on User {
                        isViewer
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL
end

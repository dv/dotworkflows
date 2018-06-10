#!/bin/ruby
# encoding: utf-8
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8
# ^ Encoding set to make GraphQL schema dump work

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require "./lib/github/github_client"

THINGS_PROJECT = ENV.fetch("THINGS_PROJECT", "Pull Requests")

def things_project
  @things_project ||= Appscript.app("Things3").projects[THINGS_PROJECT]
end

# Returns an array of the form
#
#   [{title: "Title of PR", url: "URL to PR"}]
#
def retrieve_pull_requests_i_need_to_review
  client = GithubGraphQL::Client
  result = client.query(GithubGraphQL::OrganizationPullRequestsWithReviewRequestsQuery)

  result.data.organization.repositories.nodes.flat_map do |node|
    node.pull_requests.nodes.select do |pull_request|
      pull_request.review_requests.nodes.any? do |review_request|
        review_request.requested_reviewer.is_viewer
      end
    end
  end.map do |pr|
    {title: pr.title, url: pr.url}
  end
end

# Returns an array of the form
#
#   [{name: NAME, url: URL, todo: TODO object}]
#
def list_pull_request_todos
  things_project.to_dos.get.map do |todo|
    {
      name: todo.name.get,
      url: todo.notes.get.split.first.strip,
      todo: todo
    }
  end
end

def new_todo!(name, notes)
  things_project.make(new: :to_do, with_properties: {name: name, notes: notes})
end

def complete_todo!(todo)
  todo.status.set(:completed)
end

github_pull_requests = retrieve_pull_requests_i_need_to_review
existing_todos = list_pull_request_todos

new_pull_requests = github_pull_requests.select do |pr|
  existing_todos.none? do |todo|
    todo[:url] == pr[:url]
  end
end

completed_pull_request_todos = existing_todos.select do |todo|
  github_pull_requests.none? do |pr|
    todo[:url] == pr[:url]
  end
end

new_pull_requests.each do |pr|
  new_todo!(pr[:title].capitalize, pr[:url])
end

completed_pull_request_todos.each do |todo|
  complete_todo!(todo[:todo])
end

last_checked = Time.new.strftime("%A, %e/%m/%Y @ %H:%M")
things_project.notes.set "Last checked #{last_checked}"

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_support'
require 'active_support/all'

Gitlab.configure do |config|
  config.endpoint       = ENV["GITLAB_ENDPOINT"]
  config.private_token  = ENV["GITLAB_TOKEN"]
end

def title_from_todo(todo)
  case todo.target_type
  when "MergeRequest"
    "#{todo.target.title.capitalize} (Merge Request)"
  when "Issue"
    "#{todo.target.title.capitalize} (Issue)"
  else
    todo.target.title
  end
end

def description_from_todo(todo)
  body = todo.body
  author = todo.author.name

  "#{author}: #{body}"
end

def todos_from_gitlab
  Gitlab.todos.map do |todo|
    # possible fields on todo: ["id", "project", "author", "action_name", "target_type", "target", "target_url", "body", "state", "created_at"]
    url = todo.target_url
    title = title_from_todo(todo)
    description = description_from_todo(todo)

    {url: url, title: title, description: description}
  end
end

def things_project
  Thingamajig::Project.find_by(name: "Gitlab Todos")
end

def things_todos
  things_project.todos.map do |todo|
    {
      url: todo.notes.split.first.strip,
      todo: todo
    }
  end
end

currently_known_todos = things_todos
currently_known_todo_urls = currently_known_todos.map { |todo| todo[:url] }
current_gitlab_todos = todos_from_gitlab
current_gitlab_todo_urls = current_gitlab_todos.map { |todo| todo[:url] }

complete_todos =
  currently_known_todos.select do |things_todo|
    !current_gitlab_todo_urls.include?(things_todo[:url])
  end

new_todos =
  current_gitlab_todos.select do |gitlab_todo|
    !currently_known_todo_urls.include?(gitlab_todo[:url])
  end

complete_todos.each do |things_todo|
  things_todo[:todo].complete!
end

new_todos.each do |gitlab_todo|
  notes = gitlab_todo[:url] + "\n\n" + gitlab_todo[:description]

  things_project.create_todo!(gitlab_todo[:title], notes)
end

last_checked = Time.new.strftime("%A, %e/%m/%Y @ %H:%M")
things_project.notes = "Last checked at #{last_checked}"

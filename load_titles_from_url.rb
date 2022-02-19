# Script which loads all Todos with an empty title,
# checks if the notes is exactly a URL, and if so,
# loads the URL and uses the page's title as the new
# todo's title.
#
# - Adds "Link" tag to the todos it manipulates
# - Uses "(No title found)" if the results didn't contain a title
# - Uses "A Tweet" if it's from twitter

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_support'
require 'active_support/all'

require 'uri'
require 'open-uri'
require 'nokogiri'

def empty_todos
  # This is 3x slower: hingamajig.new.app.to_dos[Appscript.its.name.eq("")]
  Thingamajig.new.todos.select { |todo| todo.name == "" }
end

def empty_todos_with_url_in_notes
  empty_todos.select do |todo|
    todo.notes =~ /\A#{URI::regexp}\z/
  end
end

# Will create or retrieve existing tag with this name
def assert_tag_exists(tag_name = "Link")
  Thingamajig.new.app.make(new: :tag, with_properties: {name: "Link"})
end

def add_tag_to_todo(todo, tag_name)
  todo.tag_names += ", #{tag_name}"
end

def download_url(url)
  tries = 3

  uri = URI.parse(url)

  begin
    uri.open(redirect: false, "User-Agent" => "Thingamajig/1.0")
  rescue OpenURI::HTTPRedirect => redirect
    uri = redirect.uri # assigned from the "Location" response header
    retry if (tries -= 1) > 0
    raise
  end
end

def get_title_from_url(url)
  html = download_url(url)

  dom = Nokogiri::HTML(html)
  dom.css("title").text&.strip
end

def update_todo(todo)
  url = todo.notes
  title = get_title_from_url(url)

  add_tag_to_todo(todo, "Link")

  if title.present?
    todo.name = title
  else
    # Twitter gives no data for crawlers
    if todo.notes =~ /twitter.com/
      todo.name = "A Tweet"
    else
      todo.name = "(No title found)"
    end
  end
end

empty_todos_with_url_in_notes.each do |todo|
  begin
    update_todo(todo)
  rescue => e
    puts "Problem with URL #{todo.notes} #{e.inspect}"
    # skip this todo
  end
end

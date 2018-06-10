require "rb-scpt"

class Things
  attr :things

  def osa_object
    things
  end

  def initialize
    @things ||= Appscript.app("Things3")
  end

  def projects
    things.projects.get.map do |osa_project|
      Things::Project.new(osa_project)
    end
  end
end

require_relative "things/osa_object"
require_relative "things/project"
require_relative "things/todo"

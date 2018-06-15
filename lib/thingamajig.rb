require "rb-scpt"

class Thingamajig
  attr :app

  def osa_object
    app
  end

  def initialize
    @app ||= Appscript.app("Things3")
  end

  def projects
    app.projects.get.map do |osa_project|
      Thingamajig::Project.new(osa_project)
    end
  end
end

require_relative "thingamajig/osa_object"
require_relative "thingamajig/area"
require_relative "thingamajig/project"
require_relative "thingamajig/todo"

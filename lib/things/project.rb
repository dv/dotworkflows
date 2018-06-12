class Things
  class Project < OsaObject
    def self.find_by(name:)
      Things::Project.new(Things.new.osa_object.projects[name])
    end

    def todos(filter = nil)
      osa_todos = osa_object.to_dos
      osa_todos = osa_todos[filter] if filter

      osa_todos.get.map do |osa_todo|
        Things::Todo.new osa_todo
      end
    end

    def create_todo!(name, notes)
      Things::Todo.new @osa_object.make(new: :to_do, with_properties: {name: name, notes: notes})
    end

    def inspect
      "#<Things::Project '#{name}'>"
    end
  end
end

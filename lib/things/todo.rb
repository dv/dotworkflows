class Things
  class Todo < OsaObject
    def complete!
      self.status = :completed
    end

    def completed?
      self.status == :completed
    end

    def cancel!
      self.status = :canceled
    end

    def canceled?
      self.status == :canceled
    end

    def active? # meaning "Today"
      activation_date && activation_date <= Date.today.to_time
    end

    def activation_date=(new_activation_date)
      if completed? || canceled?
        self.completion_date = nil
      end

      osa_object.schedule(for: new_activation_date)
    end

    def inspect
      "#<Things::Todo '#{name}'>"
    end
  end
end

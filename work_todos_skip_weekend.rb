#!/bin/ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_support'
require 'active_support/all'

next_monday = Date.parse("Monday").to_time

if next_monday < Time.now
  next_monday += 1.week
end

friday_before = next_monday - 3.days
friday_evening = friday_before + 18.hours

if Time.now <= friday_evening
  # puts "nothing to do"
  exit

else
  puts "gotta do some stuff"
  exit

  todos_to_check =
    Things::Area.find_by(name: "Work").projects.flat_map do |project|
      project.todos(Things::Todo.predicate_active.and(Things::Todo.predicate_open))
    end

  todos_to_check.each do |todo|
    todo.activation_date = next_monday
  end
end

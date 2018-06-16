#!/bin/ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_support'
require 'active_support/all'

require "./lib/thingamajig.rb"

Things = Thingamajig

def todos_to_move
  Things::Area.find_by(name: "Work").projects.flat_map do |project|
    project.todos(Things::Todo.predicate_active.and(Things::Todo.predicate_open))
  end
end

def next_monday
  result = Date.parse("Monday").to_time

  if result < Time.now
    result += 1.week
  end

  result
end

def friday_evening
  friday_before = next_monday - 3.days
  friday_before + 18.hours
end

if Time.now <= friday_evening
  # Nothing to do, it's not Friday evening yet
  exit

else
  puts "It's weekend! Reschedule work related Todos to Monday"

  todos_to_move.each do |todo|
    puts "Moving #{todo.inspect}"
    todo.activation_date = next_monday
  end
end

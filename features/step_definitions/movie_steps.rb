# require 'rspec/expectations'
require 'capybara/rspec'
require 'capybara/dsl'

# putting this at the top level will make capybara methods available everywhere
# you can put it in a module if you want to, well, modularize ...
include Capybara::DSL

# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create(title: movie[:title], 
                 rating: movie[:rating], 
                 release_date: movie[:release_date])
  end
end

Then /(.*) seed movies should exist/ do | n_seeds |
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  pending "Fill in this step in movie_steps.rb"
end

When /I click "Release Date"/ do 
    release = Capybara::Node::Finders::find(selector_for("release date"))
    click_link(release.text)
end

Then /the movies should display in ascending order of release/ do 
  elements = Capybara::Node::Finders::all(selector_for("release column"))
  elements = elements.map { |a| a.text }
  elements = elements.sort

  first = elements[0]

  elements.each_slice(2) do |a, b|
    if first != a 
        flag = !page.body.match(/[\S\s]*.*[\S\s]*#{Regexp.escape(first)}[\S\s]*.*[\S\s]*#{Regexp.escape(a)}[\S\s]*.*[\S\s]*/).nil?
        expect(flag).to eq true
    end

    flag2 = !page.body.match(/[\S\s]*.*[\S\s]*#{Regexp.escape(a)}[\S\s]*.*[\S\s]*#{Regexp.escape(b)}[\S\s]*.*[\S\s]*/).nil?
    expect(flag2).to eq true

    first = b
  end
end

When /I click "Movie Title"/ do 
    title = Capybara::Node::Finders::find(selector_for("movie title"))
    click_link(title.text)
end

Then /the movies should display in alphabetical order/ do 
  elements = Capybara::Node::Finders::all(selector_for("movie column"))
  elements = elements.map { |a| a.text }
  elements = elements.sort

  first = elements[0]

  elements.each_slice(2) do |a, b|
    if first != a 
        flag = !page.body.match(/[\S\s]*.*[\S\s]*#{Regexp.escape(first)}[\S\s]*.*[\S\s]*#{Regexp.escape(a)}[\S\s]*.*[\S\s]*/).nil?
        expect(flag).to eq true
    end

    flag2 = !page.body.match(/[\S\s]*.*[\S\s]*#{Regexp.escape(a)}[\S\s]*.*[\S\s]*#{Regexp.escape(b)}[\S\s]*.*[\S\s]*/).nil?
    expect(flag2).to eq true

    first = b
  end
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |do_uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(", ").each do |rating|
    if do_uncheck == "un" then uncheck(rating) else check(rating) end
  end
end

# Part 2, Step 3
Then /^I should (not )?see the following movies: (.*)$/ do |no, movie_list|
  # Take a look at web_steps.rb Then /^(?:|I )should see "([^"]*)"$/
  elements = Capybara::Node::Finders::all(selector_for("movie column"))
  elements = elements.map { |a| a.text }

  movies.split(", ").each do |movie|
    if no == "not " 
        expect(elements).to_not include movie
    else 
        expect(elements).to include movie
    end
  end
end

Then /I should see all the movies/ do
  # Make sure that all the movies in the app are visible in the table
  elements = Capybara::Node::Finders::all(selector_for("movie column"))
  elements = elements.map { |a| a.text }

  movies = Movie.all.map { |m| m.title }

  movies.each do |movie|
    expect(elements).to include movie
  end
end

### Utility Steps Just for this assignment.

Then /^debug$/ do
  # Use this to write "Then debug" in your scenario to open a console.
   require "byebug"; byebug
  1 # intentionally force debugger context in this method
end

Then /^debug javascript$/ do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end


Then /complete the rest of of this scenario/ do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  fail "Remove this step from your .feature files"
end

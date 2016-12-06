require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require 'pry'

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      # binding.pry
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end
  
  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
  
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "Sherlock Holmes!"
  
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")
  
  erb :chapter
end

not_found do
  redirect "/"
end

def each_chapter(&block)
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  result = []
  return result unless query
  
  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    result << {number: number, name: name, paragraphs: matches} if matches.any?
  end
  
  result
end

get '/search' do
  @results = chapters_matching(params[:query])
  
  erb :search
end



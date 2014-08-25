require 'sinatra'
require 'sinatra/reloader'
require 'pry'

require 'csv'

####################################################################
def get_movie(filename, id)
  movie = {}
  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    if row[:id] == id
      movie = row.to_hash
      break
    end
  end
  movie
end

def get_movies_by_title(filename)
  movies = []
  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    movies << row.to_hash
  end
  movies.sort_by { |movie| movie[:title] }
end

def get_movies_by_rating(filename)
  movies = []
  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    movies << row.to_hash
  end
  movies.sort_by { |movie| -movie[:rating].to_i }
end

def get_movies_by_year(filename)
  movies = []
  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    movies << row.to_hash
  end
  movies.sort_by { |movie| -movie[:year].to_i }
end



####################################################################
helpers do
  def on_last_page?(page_num, last_page_num)
    page_num < last_page_num
  end

  def on_first_page?(page_num)
    page_num == 1
  end
end

def matches_query?(movie, query)
  movie[:title].downcase.include?(query) ||
    (movie[:synopsis] && movie[:synopsis].downcase.include?(query))
end

def filter_movies(movies, query)
  search_results = []

  movies.each do |movie|
    if matches_query?(movie, query)
      search_results << movie
    end
  end

  search_results
end




############################################################



get "/" do
  erb :index
end

get "/movies" do
  movies = get_movies_by_title('movies.csv')
  movies = filter_movies(movies, params[:query].downcase) if params[:query]

  @page_num = params[:page] ? params[:page].to_i : 1
  @last_page_num = movies.count / 20 + 1

  last_index = @page_num * 20 - 1
  first_index = last_index - 19

  @movies = movies[first_index..last_index]

  erb :'/movies/index'
end

get "/highest rated" do
  @movies = get_movies_by_rating('movies.csv')
  erb :'/movies/rating'
end

get "/newest" do
  @movies = get_movies_by_year('movies.csv')
  erb :'/movies/newest'
end

get "/movies/:id" do
  @movie = get_movie('movies.csv', params[:id])
  erb :'movies/show'
end

#!/usr/bin/env ruby
require 'rack'
require 'sqlite3'
require_relative 'album'

NUMBER_OF_ALBUMS = 100
FORM_ERB = "form.html.erb"
LIST_ERB = "list.html.erb"
DATABASE_FILENAME = "albums.sqlite3.db"

class AlbumApp

  def call(env)
    request = Rack::Request.new(env)
    case request.path
    when "/form" then render_form(request)
    when "/list" then render_list(request)
    else render_404
    end
  end

  def render_form(request)
    response = Rack::Response.new
    response.write(ERB.new(File.read(FORM_ERB)).result(binding))
    response.finish
  end

  def render_list(request)
    response = Rack::Response.new

    sort_order = request.params['order']
    rank_to_highlight = request.params['rank'].to_i

    albums = load_albums(sort_order)

    response.write(ERB.new(File.read(LIST_ERB)).result(binding))
    response.finish
  end

  def load_albums(sort_order)
    database = SQLite3::Database.open(DATABASE_FILENAME)
    database.results_as_hash = true
    results = database.execute("SELECT * FROM albums ORDER BY #{sort_order}") # Little bobby tables
    database.close
    results.map { |row| Album.new(row['rank'], row['title'], row['year']) }
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end

end

Signal.trap('INT') { Rack::Handler::WEBrick.shutdown } # Ctrl-C to quit
Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080
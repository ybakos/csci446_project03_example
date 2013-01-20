#!/usr/bin/env ruby
require 'rack'
require_relative 'album'

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
    File.open("form_top.html", "rb") { |form| response.write(form.read) }
    (1..100).each { |i| response.write("<option value=\"#{i}\">#{i}</option>\n") }
    File.open("form_bottom.html", "rb") { |form| response.write(form.read) }
    response.finish
  end

  def render_list(request)
    response = Rack::Response.new
    response.write "Params: #{request.params}\n"
    response.write "order: #{request.params['order']}\n"
    response.write "rank: #{request.params['rank']}\n"
    File.open("list_top.html", "rb") { |template| response.write(template.read) }

    albums = File.readlines("top_100_albums.txt").each_with_index.map { |record, i| Album.new(i + 1, record) }

    albums.each do |album|
      response.write("\t<tr>\n")
      response.write("\t\t<td>#{album.rank}</td>\n")
      response.write("\t\t<td>#{album.title}</td>\n")
      response.write("\t\t<td>#{album.year}</td>\n")
      response.write("\t</tr>\n")
    end

    File.open("list_bottom.html", "rb") { |template| response.write(template.read) }
    response.finish
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end

end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080
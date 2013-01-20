#!/usr/bin/env ruby
require 'rack'

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
    File.open("top_100_albums.txt", "rb") { |list| response.write(list.read) }
    response.finish
  end

  def render_404
    [404, {"Content-Type" => "text/plain"}, ["Nothing here!"]]
  end

end

Rack::Handler::WEBrick.run AlbumApp.new, :Port => 8080
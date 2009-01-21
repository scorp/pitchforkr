require 'rubygems'
require 'sinatra'
require 'model'
require 'vendor/will_paginate/lib/will_paginate/view_helpers'

def page_list
  current_page = params[:page]
  total = Review.count
  pages = total/25
  pages = (1..pages).to_a
  pages[0..10].collect do |p|
    "<a href=\"/pages/#{p}\">#{p}</a>"
  end.join + "<span>...</span>" + (pages[(pages.size - 10)..pages.size]).collect do |p|
    "<a href=\"/pages/#{p}\">#{p}</a>"
  end.join  
end

get "/" do
  o = params[:o]
  @greatest = Review.find(:all, :limit=>25, :order=>"rating desc")
  @latest = Review.find(:all, :limit=>25, :order=>"content_id desc")
  erb :index
end

get "/:id" do
  @reviews = [Review.find_by_content_id(params[:id])]
  erb :index
end

get "/pages/:page" do
  @reviews = Review.paginate(:page => params[:page], :order=>"rating desc")
  erb :index
end

get "/artist/:artist" do
  @reviews = Review.find(:all, :conditions=>["artist like ?", '%' + params[:artist].split(/\s|_|-/).join('%') + '%'], :order=>"rating desc")
  erb :index
end

get "/album/:album" do
  @reviews = Review.find(:all, :conditions=>["title like ?", '%' + params[:album].split(/\s|_|-/).join('%') + '%'], :order=>"rating desc")
  erb :index
end

get "/text/:text" do
  @reviews = Review.find(:all, :conditions=>["review like ?", '%' + params[:text].split(/\s|_|-/).join('%') + '%'], :order=>"rating desc")
  erb :index
end


use_in_file_templates!
__END__

@@ layout
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html>
    <head>
      <meta http-equiv="Content-type" content="text/html; charset=utf-8">
      <title>pitchforkd</title>
      <link rel="stylesheet" href="/stylesheets/styles.css" type="text/css" media="screen" title="no title" charset="utf-8">
    </head>
    <body>
      <div id="container">
        <%= yield %>
      </div>
      <script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
      </script>
      <script type="text/javascript">
      try {
      var pageTracker = _gat._getTracker("UA-7104424-1");
      pageTracker._trackPageview();
      } catch(err) {}</script>
    </body>
  </html>

@@ index
  <div id="latest">
  <h2>latest</h2>
  <ol class="latest review_list">  
  <% @latest.each_with_index do |r,i| 
    even_odd = (i + 1)%2 == 0 ? "even" : "odd" %>
    <li id="latest_content_<%=r.content_id%>" class="review <%=even_odd%>">
      <img src="<%=r.image_url%>" class="album_art"/>
      <ul>
      <li class="title_artist">
        <div>
          <span class="title"><%=r.title%></span> : <span class="artist"><%=r.artist%>&nbsp;&nbsp;</span><span class="rating"><%=r.rating%></span>
        </div>
      </li>
      <li class="review_summary"><%= r.review_summary %>...
        <a href="http://www.pitchforkmedia.com/node/<%=r.content_id%>" target="_blank">[ full review ]</a></li>
      </ul>
    </li>
  <% end %>
  </ol>
  </div>
  
  <div id="greatest">
  <h2>greatest</h2>
  <ol class="greatest review_list">  
  <% @greatest.each_with_index do |r,i| 
    even_odd = (i + 1)%2 == 0 ? "even" : "odd" %>
    <li id="greatest_content_<%=r.content_id%>" class="review <%=even_odd%>">
      <img src="<%=r.image_url%>" class="album_art"/>
      <ul>
        <li class="title_artist">
          <div>
            <span class="title"><%=r.title%></span> : <span class="artist"><%=r.artist%>&nbsp;&nbsp;</span><span class="rating"><%=r.rating%></span>
          </div>
        </li>
        <li class="review_summary"><a href="http://www.pitchforkmedia.com/node/<%=r.content_id%>" target="_blank">[ full review ]</a></li>
      </ul>
    </li>
  <% end %>
  </ol>
  </div>
  <div class="page_list"></div>
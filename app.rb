require 'rubygems'
require 'sinatra'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Admin'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb :index
end

get '/visit' do
  erb :visit
end  

post '/visit' do

  @client = params[:client]
  @phone = params[:phone]
  @data_visit = params[:data_visit]
  @barber = params[:barber]
  @color = params[:color]

    if @client == '' && @phone == '' && @data_visit ==''
      @error = "enter data"
      erb :visit
    end  

  f = File.open( "./public/client.txt", "w")
  f.write ("Client #{@client}, phone #{@phone}, data #{@data_visit}, barber: #{@barber} color: #{@color}\n")
  f.close
  erb :index

end 

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email = params[:email]
  @comment = params[:comment]

  comm = File.open("/public/comment.txt", "w")
  comm.write ("Comment: #{@mail} #{@comment}")
  comm.close
  erb :index
end 

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  @username = params[:username]
  @password = params[:password]
    if @username == 'admin' && @password == 'secret' #this account admin protection
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
else
  erb "input is not correct"
end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

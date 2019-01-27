require 'rubygems'
require 'sinatra'
require 'pony'

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

  f = File.open( "./public/client.txt", "w")
  f.write ("Client #{@client}, phone #{@phone}, data #{@data_visit}, barber: #{@barber} color: #{@color}\n")
  f.close
  erb :index

  hh = {:client => "enter Name", :phone =>"enter phone", :date_visit => "enter date"}
      hh.each do |key, value|
        if params[key] == ''
          @error = hh[key]
            return erb :visit
        end
      end  

end 

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  username = params[:username]
  message = params[:message]
 
Pony.mail({
  :to => 'a.og2009@yandex.ru',
  :from => 'landsurveyor450@gmail.com',
  :via => :smtp,
  :subject => "Новое сообщение от пользователя #{username}",
  :body => "#{message}",
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'landsurveyor450',
    :password             => 'Rjvgkbdbn8',
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "127.0.0.1" # the HELO domain provided by the client to the server
  }
})
  erb :contacts
end
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

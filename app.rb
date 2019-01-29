require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def is_barber_exists? db, name

  db.execute('select * from Barbers where name=?',[name]).length > 0

end

def seed_db
  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'insert into Barbers (name) value (?)', [barber]
    end   
  end  

end  

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end   

before do
  db = get_db
  @barbers = db.execute 'select * from Barbers' 

end

configure do
  enable :sessions
  
  db = get_db
  db = 'CREATE TABLE IF NOT EXISTS "Users" (
    "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
    "client"	TEXT,
    "phone"	TEXT,
    "data_visit"	TEXT,
    "barber"	TEXT,
    "color"	TEXT
  );'

  db = 'CREATE TABLE IF NOT EXISTS "Barbers" (
    "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
    "name"	TEXT,
  );'

  seed_db db, ['Вася Пупкин', 'Игорь Капуста', 'Мила Людмила', 'Федор Пух', 'Яна Трирубляинаша']

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

  db = get_db
  db.execute 'insert into Users (client, phone, data_visit, barber, color) values (?, ?, ?, ?, ?)', [@client, @phone, @data_visit, @barber,@color]

  hh = {:client => "enter Name", :phone =>"enter phone", :date_visit => "enter date"}
      hh.each do |key, value|
        if params[key] == ''
          @error = hh[key]
            return erb :visit
        end
      end  
      erb :index
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

get '/showusers' do
    db = get_db

    @results = db.execute 'select * from Users order by id desc'

    erb :showusers
end 



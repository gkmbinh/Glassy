

require './app/models/oauth_utils'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json

  def index
    @users = User.all

    if session[:access_token]==nil 
      redirect_to get_authorization_url(nil, nil) 
    end

    session[:refresh_token] ='1/qecXGIQGg8UAYSvNmt37GK4HlUL4v2ber37z7xaNLo4'
    session[:access_token]= "ya29.1.AADtN_WS4-tE7XvjV2Z24pSnKcdCWbBPbqc61yAPGf426eD9JTJGNhQzYzlyFTo" 

    hash = {
            access_token:  session[:access_token].to_s,
            refresh_token:  session[:refresh_token].to_s
    } 

    puts "session hash"
    puts YAML::dump(hash)

    credentials = Signet::OAuth2::Client.new(hash) 
    

   # credentials = refesh_auth_tooken(hash)

   # if credentials.refresh_token !=nil
   #     puts "New Refesh Tooken"
   #     session[:access_token]=  credentials.access_token
   #     session[:refresh_token] = credentials.refresh_token
   # end 

    puts YAML::dump(credentials)

    puts "-----"
      

    @mirror = MirrorClient.new(credentials)

    puts "Lam gi thi lam de ..."

    puts "Timeline Menu"

    if params[:menu]

       @mirror.insert_timeline_item({
        text: params[:text],
        speakableText: 'What did you eat? Bacon?',
        notification: { level: 'DEFAULT' },
        menuItems: [
          { action: 'REPLY' },
          { action: 'READ_ALOUD' },
          { action: 'SHARE' },
          { action: "DELETE"} ]
       }) 

    end 

    if params[:photo]
      # display Map on timeline   
         @mirror.insert_timeline_item({
                  html: "<article class=\"photo\">\n  <img src=\"https://mirror-api-playground.appspot.com/links/filoli-spring-fling.jpg\" width=\"100%\" height=\"100%\">\n  <div class=\"photo-overlay\"/>\n  <section>\n    <p class=\"text-auto-size\">Spring Fling Fundraiser at Filoli</p>\n  </section>\n</article>\n",
                  speakableText: 'Is this nice?',
                  notification: {
                    level: "DEFAULT"
                  },
                   menuItems: [
                              { action: 'REPLY' },
                              { action: 'READ_ALOUD' }, 
                              { action: "DELETE"} 
                            ]

                })

    end 

    if params[:local]
      # localtion divice
      puts "user Localtion"

      local = @mirror.get_location("latest")

      puts YAML::dump(local)
      
      @mirror.insert_timeline_item({
                  html:'
                  <article>
                        <figure>
                          <img src="glass://map?w=240&h=360&marker=0;42.369590,
                            -71.107132&marker=1;42.36254,-71.08726&polyline=;42.36254,
                            -71.08726,42.36297,-71.09364,42.36579,-71.09208,42.3697,
                            -71.102,42.37105,-71.10104,42.37067,-71.1001,42.36561,
                            -71.10406,42.36838,-71.10878,42.36968,-71.10703"
                            height="360" width="240">
                        </figure>
                        <section>
                          <div class="text-auto-size">
                            <p class="yellow">12 minutes to home</p><p>Medium traffic on Broadway</p>
                          </div>
                        </section>
                      </article>
                  ',
                  speakableText: 'Is this nice?',
                  notification: {
                    level: "DEFAULT"
                  },
                   menuItems: [
                              { action: 'REPLY' },
                              { action: 'READ_ALOUD' }, 
                              { action: "DELETE"} 
                            ]

                })
     end 

    

  end

  def oauth2callback

    @users = User.all

    puts "Post Time line first" #4567

      hash = {
            access_token:  session[:access_token].to_s,
            refresh_token:  session[:refresh_token].to_s
      } 

     if params[:code]
       puts YAML::dump(params)
       puts "----CODE---"  
          credentials = get_credentials(params[:code], nil)
          session[:access_token] = credentials.access_token
          session[:refresh_token] =  credentials.refresh_token

       else
          credentials = Signet::OAuth2::Client.new(hash)
     end 
      
      # puts YAML::dump(params[:code])
      # Handle step 2 of the OAuth 2.0 dance - code exchange
       
      
      puts "----CREDENTIALS---"   
      puts YAML::dump(credentials)


      #user_info = get_user_info(credentials)

      #puts "----INFO USER---"   

      #puts YAML::dump(user_info)
 
      puts "----TIEMLINE FIRST---"   

      @mirror = MirrorClient.new(credentials)

      @mirror.insert_timeline_item({
        text: 'Hello world!' 
      })

      #session[:user_id] = user_info.id

      #mirror = make_client(user_info.id)
      #bootstrap_new_user(mirror)

      #redirect to '/'
    #lsif session[:user_id].nil? ||
    #    get_stored_credentials(session[:user_id]).nil?
      # Handle step 1 of the OAuth 2.0 dance - redirect to Google
    #  redirect to get_authorization_url(nil, nil)
    #else
      # We're authenticated, so redirect back to the base URL.
    #  redirect to '/users'
     #end


    render 'index'
  end 
  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:user_email, :access_token, :refresh_token)
    end
end

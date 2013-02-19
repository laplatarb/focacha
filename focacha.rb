require_relative 'models/channel'
require_relative 'models/message'
require_relative 'models/stream_response'
require_relative 'models/current_topic_change_message'
require_relative 'models/user'

module Focacha
  class Application < Sinatra::Base
    configure do
      # config_file
      register Sinatra::ConfigFile
      config_file 'config/config.yml.erb'

      # google_plus
      if settings.auth['google']['enable']
        GooglePlus.api_key = settings.auth['google']['api_key']
      end

      # logging
      enable :logging

      # method override
      enable :method_override

      # mongoid
      #Mongoid.logger = Logger.new($stdout)
      #Moped.logger = Logger.new($stdout)
      #Mongoid.logger.level = Logger::DEBUG
      #Moped.logger.level = Logger::DEBUG
      Mongoid.load! 'config/mongoid.yml', environment

      # namespace
      register Sinatra::Namespace

      # omniauth
      use OmniAuth::Builder do
        settings = Focacha::Application.settings

        if settings.auth['facebook']['enable']
          provider :facebook, settings.auth['facebook']['app_id'], settings.auth['facebook']['secret']
        end

        if settings.auth['google']['enable']
          provider :google_oauth2, settings.auth['google']['consumer_key'], settings.auth['google']['consumer_secret'], { access_type: 'online', approval_prompt: '' }
        end

        if settings.auth['twitter']['enable']
          provider :twitter, settings.auth['twitter']['consumer_key'], settings.auth['twitter']['consumer_secret']
        end
      end

      # reloader
      register Sinatra::Reloader if development?

      # sessions
      enable :sessions
      set :session_secret, settings.session['secret']
      set :connections, []

      # sinatra-partial
      register Sinatra::Partial
      set :partial_template_engine, :slim
      enable :partial_underscores

      # sinatra-r18n
      register Sinatra::R18n
      R18n::I18n.default = settings.i18n['default_locale']
      R18n.default_places { 'config/locales' }

      # static
      set :static, true

      # twitter
      if settings.auth['twitter']['enable']
        Twitter.configure do |config|
          config.consumer_key = settings.auth['twitter']['consumer_key']
          config.consumer_secret = settings.auth['twitter']['consumer_secret']
        end
      end
    end

    helpers do
      def current_user
        @user ||= User.find_by(uid: session[:uid]) if session[:uid]
      end

      def facebook_enabled?
        settings.auth['facebook']['enable']
      end

      def google_enabled?
        settings.auth['google']['enable']
      end

      def html_pipeline
        @html_pipeline ||= HTML::Pipeline.new [
          HTML::Pipeline::MarkdownFilter,
          HTML::Pipeline::SanitizationFilter,
          HTML::Pipeline::CamoFilter,
          HTML::Pipeline::ImageMaxWidthFilter,
          HTML::Pipeline::HttpsFilter,
          HTML::Pipeline::MentionFilter,
          HTML::Pipeline::EmojiFilter,
          HTML::Pipeline::SyntaxHighlightFilter
        ], { asset_root: '/images/' }
      end

      def twitter_enabled?
        settings.auth['twitter']['enable']
      end
    end

    before do
      pass if request.path_info =~ /\/auth\//

      unless current_user
        halt 401, slim(:'auth/sign_in', layout: :'layouts/unauthorized')
      end
    end

    get '/' do
      redirect '/channels'
    end

    namespace '/auth' do
      get '/:provider/callback' do
        auth = request.env['omniauth.auth']
        user = User.find_by(provider: auth['provider'], uid: auth['uid']) || User.create_with_omniauth(auth)
        session[:uid] = user.uid
        redirect '/'
      end

      get '/failure' do
        slim :'auth/failure', layout: :'layouts/unauthorized'
      end

      delete '/destroy' do
        session[:uid] = nil
        redirect '/'
      end
    end

    namespace '/channels' do
      get do
        slim :'channels/index', layout: :'layouts/focacha', locals: { channels: Channel.all, channel: Channel.new }
      end

      post do
        channel = Channel.new params[:channel]
        channel.user = current_user

        if channel.valid?
          channel.save
          redirect '/'
        else
          slim :'channels/index', layout: :'layouts/focacha', locals: { channels: Channel.all, channel: Channel.new }
        end
      end
      
      get '/:id/stream', provides: 'text/event-stream' do
        stream :keep_open do |out|
          # store connection for later on
          settings.connections << out
          # remove connection when closed properly 
          out.callback { settings.connections.delete out }
          # remove connection when closed due to an error
          out.errback do
            logger.warn 'We just lost a connection!'
            
            settings.connections.delete out
          end
        end
      end

      get '/:id' do
        channel = Channel.find_by(id: params[:id])
        slim :'channels/show', layout: :'layouts/focacha', locals: { channel: channel }
      end

      put '/:id/change_current_topic' do
        channel = Channel.find_by(id: params[:id])
        channel.update_attributes params[:channel]
        channel.messages.create({ text: channel.current_topic, user: current_user }, CurrentTopicChangeMessage)
        redirect "/channels/#{channel.id}"
      end

      post '/:id/messages', provides: 'json' do
        channel = Channel.find_by(id: params[:id])
        message = channel.messages.new(text: params[:message])
        message.user = current_user
        
        p message.valid?
        
        if message.valid?
          message.save
          settings.connections.each { |out| out << StreamResponse.new(:new_message, { message: message }).build }
          status 201
        else
          status 424
        end
      end
    end
  end
end


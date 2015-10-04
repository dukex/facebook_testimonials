require 'sinatra'
require 'pry'
require 'base64'
require 'json'
require './lib/facebook'

class DepoApp < Sinatra::Base
  post '/' do
    data = Facebook.parse_signed_request(ENV['FACEBOOK_SECRET'], params[:signed_request])

    headers \
      "X-Frame-Options" => "ALLOW-FROM https://apps.facebook.com"

    if(@data['user_id'])
      erb :app
    else
      erb :login
    end
  end

  get '/me' do
    content_type :json
    {
      user: {
        id: 23123123
      }
    }.to_json
  end

  get '/testimonials/:user_id' do
    content_type :json
    {
      testimonials: [
        {
          from: {
            name: "Foo Bar",
            id: "21321313",
            image_url: "http://api.randomuser.me/portraits/women/39.jpg"
          },
          title: "Consectetur sed labore dolore",
          body: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        },
        {
          from: {
            name: "Darryl Gilbert",
            id: "97905697-56",
            image_url: "https://randomuser.me/api/portraits/men/62.jpg"
          },
          title: "Vivui finitivo respondeci on ses",
          body: "Tiam pago sepen e bis, plu gv movi viro intera, jeno sube ik hav. Vivui finitivo respondeci on ses, cit liva kibi antaŭpriskribo ja. Ebl aliel retro il, sur volus sanktoleo sezononomo da. Tia la plus reala. Mem ve pronomeca alternativa, miria centimetro anstataŭi ies an."
        },
        {
          from: {
            name: "Christian Penã",
            id: "213244",
            image_url: "http://api.randomuser.me/portraits/men/9.jpg"
          },
          title: "Ehe sh dekoj asterisko malantaŭa",
          body: "To dek tiuj subfrazo malantaŭa, nano malantaŭe reprezenti hav gv. Ehe sh dekoj asterisko malantaŭa, amen supre fratineto jen fo, obl triangulo ligvokalo malpermesi ig. Mo sen neado ebleco esperanto, sama onjo nombrovorto eca io, nun on iliard rilata. Ojd kv estiel manier neoficiala, dev io zorgi proksimumeco, dz helpi kovri cirkumflekso enz. Ido om koreo eksterna kunskribo. Onia leteri prepozicio cia iz, i mini kiom video cia."
        },
      ]
    }.to_json
  end

end

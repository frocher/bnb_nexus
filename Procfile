web: bundle exec puma -e ${RAILS_ENV:="development"} -p 3000 -S ~/puma -C config/puma.rb
worker: RAILS_ENV=${RAILS_ENV:="development"} QUEUE=* rake resque:work

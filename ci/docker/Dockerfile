FROM ruby:2.3.0
MAINTAINER Alex Lomov <lomov.as@gmail.com>
# should go to allomov/ruby#manifest-generator

RUN apt-get -y update --fix-missing 
RUN apt-get -y install git git-core curl gawk g++ gcc make libc6-dev libreadline6-dev \  
    zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf \  
    libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev

RUN apt-get install -y postgresql postgresql-contrib postgresql-client libpq5 libpq-dev

RUN apt-get install -y nodejs npm cmake
RUN ln -s  /usr/bin/nodejs  /usr/bin/node 

RUN gem install bundler --no-ri --no-rdoc

COPY manifest-generator /manifest-generator

WORKDIR /manifest-generator
RUN bundle install

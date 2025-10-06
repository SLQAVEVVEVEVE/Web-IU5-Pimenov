FROM ruby:3.3.9

RUN apt-get update -y && apt-get install -y build-essential nodejs

WORKDIR /app

# сначала ставим гемы
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# затем весь код
COPY . .

EXPOSE 3000
CMD ["bin/rails","server","-b","0.0.0.0","-p","3000"]

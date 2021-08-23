FROM ubuntu:18.04

# Update the image
RUN apt-get update -y

RUN apt-get install -y libsqlite3-dev libxslt-dev \
                       libxml2-dev zlib1g-dev \
                       software-properties-common \
                       gcc git



SHELL ["/bin/bash", "-c"]


ENV RUBY_VERSION 2.6.3
ENV SRP_ROOT /Serpico

ENV SRP_ADMIN admin
ENV SRP_ADMIN_PASS pass
ENV SRP_INIT "yes"


# Install rvm
RUN apt-add-repository -y ppa:rael-gc/rvm
RUN apt-get install -y rvm
RUN source /usr/share/rvm/scripts/rvm \
           && rvm install ${RUBY_VERSION} \
           && rvm ${RUBY_VERSION}



WORKDIR $SRP_ROOT
COPY . $SRP_ROOT

RUN source /usr/share/rvm/scripts/rvm \
    && gem install bundler \
    && bundle install

RUN echo -e Initializing database...
RUN source /usr/share/rvm/scripts/rvm \
    && ruby scripts/first_time.rb


ENV PATH /usr/share/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN source /usr/share/rvm/scripts/rvm
RUN echo "source /usr/share/rvm/scripts/rvm" >> /etc/profile
RUN echo "rvm --default use $RUBY_VERSION" >> /etc/profile

EXPOSE 8443
CMD ["bash", "-c", "source /usr/share/rvm/scripts/rvm && ruby serpico.rb"]

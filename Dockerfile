FROM        gliderlabs/alpine:3.4
MAINTAINER  Niki Eskola
 
# Update the package repository
RUN apk update
RUN apk add git vim varnish bash bash-doc bash-completion
#RUN apt-get -qq update

# Install base system
#RUN apt-get install -y varnish vim git

# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl

# Export environment variables
ENV VARNISH_PORT 80

# Expose port 80
EXPOSE 80

ADD parse /parse
ADD start /start

RUN chmod 0755 /start /parse

CMD ["/start"]

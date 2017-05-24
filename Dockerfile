FROM        gliderlabs/alpine:3.4
MAINTAINER  Niki Eskola <niki.eskola@veikkaus.fi>
 
# Update the package repository
RUN apk update
RUN apk add git vim varnish bash bash-doc bash-completion curl

# Make our custom VCLs available on the container
ADD default.vcl /etc/varnish/default.vcl
RUN chown varnish.root /etc/varnish/default.vcl

# Export environment variables
ENV VARNISH_PORT 8010

# Expose port 8010
EXPOSE 8010

ADD parse /parse
ADD start /start

RUN chmod 0755 /start /parse 

USER varnish
CMD ["/start"]

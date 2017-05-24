HOSTNAME=a93eb918ffd5 NODE2_ENV_no_proxy=*.local, 169.254/16 TERM=xterm NODE1_NAME=/varnish/node1 NODE1_PORT_80_TCP_PROTO=tcp NODE1_ENV_PYTHON_PIP_VERSION=8.1.2 NODE2_ENV_PYTHON_VERSION=2.7.12 NODE2_PORT_80_TCP_PORT=80 NODE2_ENV_PYTHON_PIP_VERSION=8.1.2 NODE1_ENV_no_proxy=*.local, 169.254/16 NODE2_PORT=tcp://172.17.0.3:80 NODE1_PORT_80_TCP_ADDR=172.17.0.2 NODE1_PORT_80_TCP=tcp://172.17.0.2:80 NODE2_PORT_80_TCP_PROTO=tcp PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin _=/bin/printenv NODE2_PORT_80_TCP_ADDR=172.17.0.3 NODE1_PORT=tcp://172.17.0.2:80 PWD=/ NODE1_ENV_PYTHON_VERSION=2.7.12 NODE1_PORT_80_TCP_PORT=80 NODE2_PORT_80_TCP=tcp://172.17.0.3:80 NODE2_ENV_GPG_KEY=C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF NODE1_ENV_LANG=C.UTF-8 NODE1_ENV_GPG_KEY=C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF HOME=/var/lib/varnish SHLVL=2 no_proxy=*.local, 169.254/16 NODE2_NAME=/varnish/node2 VARNISH_PORT=8010 NODE2_ENV_LANG=C.UTF-8
vcl 4.0;

import directors;

backend default {
  .host = "127.0.0.1";
  .port = "8080";
  .connect_timeout = 60s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .max_connections = 800;
}
  
sub vcl_recv {
  set req.http.grace = 120;
 
  # Set X-Forwarded-For header for logging in nginx
  unset req.http.X-Forwarded-For;
  set req.http.X-Forwarded-For = client.ip;
 
  # Remove has_js and CloudFlare/Google Analytics __* cookies and statcounter is_unique
  set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_[_a-z]+|has_js|is_unique)=[^;]*", "");
  # Remove a ";" prefix, if present.
  set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");
 
  # Either the admin pages or the login
  if (req.url ~ "/wp-(login|admin|cron)") {
    # Dont cache, pass to backend
    return (pass);
  }
  if (req.method == "POST") {
    # Dont cache, pass to backend
    return (pass);
  } 
}
  backend NODE1_PORT_80_TCP_ADDR {
    .host = "172.17.0.2";
    .port = "80";
    .connect_timeout = 60s;
    .first_byte_timeout = 60s;
    .between_bytes_timeout = 60s;
    .max_connections = 800;
  }
  
  backend NODE2_PORT_80_TCP_ADDR {
    .host = "172.17.0.3";
    .port = "80";
    .connect_timeout = 60s;
    .first_byte_timeout = 60s;
    .between_bytes_timeout = 60s;
    .max_connections = 800;
  }
  

  
sub vcl_init {
    new cluster1 = directors.round_robin();

     cluster1.add_backend(NODE1_PORT_80_TCP_ADDR); 
     cluster1.add_backend(NODE2_PORT_80_TCP_ADDR); 
}
  
sub vcl_backend_response {
   if (bereq.url ~ "\.(css|js|png|gif|jpg)$") {
     unset beresp.http.set-cookie;
     set beresp.ttl = 66h;
  }
}
  
sub vcl_recv {
    set req.backend_hint = cluster1.backend();
}
Can't open log - retrying for 5 seconds
Log opened
*   << Session  >> 1         
-   Begin          sess 0 HTTP/1
-   SessOpen       172.17.0.1 42522 0.0.0.0:8010 172.17.0.4 8010 1495619841.578349 16
-   SessClose      RX_TIMEOUT 5.002
-   End            

*   << BeReq    >> 32771     
-   Begin          bereq 32770 pass
-   Timestamp      Start: 1495619965.744635 0.000000 0.000000
-   BereqMethod    GET
-   BereqURL       /
-   BereqProtocol  HTTP/1.1
-   BereqHeader    Host: localhost:8010
-   BereqHeader    Cache-Control: max-age=0
-   BereqHeader    Upgrade-Insecure-Requests: 1
-   BereqHeader    User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   BereqHeader    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   BereqHeader    Accept-Encoding: gzip, deflate, sdch, br
-   BereqHeader    Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   BereqHeader    grace: 120
-   BereqHeader    X-Forwarded-For: 172.17.0.1
-   BereqHeader    Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   BereqHeader    X-Varnish: 32771
-   VCL_call       BACKEND_FETCH
-   VCL_return     fetch
-   BackendOpen    21 boot.NODE1_PORT_80_TCP_ADDR 172.17.0.2 80 172.17.0.4 49104
-   Timestamp      Bereq: 1495619965.745073 0.000438 0.000438
-   Timestamp      Beresp: 1495619965.746414 0.001779 0.001341
-   BerespProtocol HTTP/1.1
-   BerespStatus   200
-   BerespReason   OK
-   BerespHeader   Server: gunicorn/19.6.0
-   BerespHeader   Date: Wed, 24 May 2017 09:59:25 GMT
-   BerespHeader   Connection: close
-   BerespHeader   Content-Type: text/html; charset=utf-8
-   BerespHeader   Content-Length: 1285
-   BerespHeader   Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   TTL            RFC 120 10 -1 1495619966 1495619966 1495619965 0 0
-   VCL_call       BACKEND_RESPONSE
-   TTL            VCL 120 10 0 1495619966
-   VCL_return     deliver
-   Storage        malloc Transient
-   ObjProtocol    HTTP/1.1
-   ObjStatus      200
-   ObjReason      OK
-   ObjHeader      Server: gunicorn/19.6.0
-   ObjHeader      Date: Wed, 24 May 2017 09:59:25 GMT
-   ObjHeader      Content-Type: text/html; charset=utf-8
-   ObjHeader      Content-Length: 1285
-   ObjHeader      Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   Fetch_Body     3 length stream
-   BackendClose   21 boot.NODE1_PORT_80_TCP_ADDR
-   Timestamp      BerespBody: 1495619965.746484 0.001849 0.000070
-   Length         1285
-   BereqAcct      584 0 584 209 1285 1494
-   End            

*   << Request  >> 32770     
-   Begin          req 32769 rxreq
-   Timestamp      Start: 1495619965.744531 0.000000 0.000000
-   Timestamp      Req: 1495619965.744531 0.000000 0.000000
-   ReqStart       172.17.0.1 42524
-   ReqMethod      GET
-   ReqURL         /
-   ReqProtocol    HTTP/1.1
-   ReqHeader      Host: localhost:8010
-   ReqHeader      Connection: keep-alive
-   ReqHeader      Cache-Control: max-age=0
-   ReqHeader      Upgrade-Insecure-Requests: 1
-   ReqHeader      User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   ReqHeader      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   ReqHeader      Accept-Encoding: gzip, deflate, sdch, br
-   ReqHeader      Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   ReqHeader      Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   VCL_call       RECV
-   ReqHeader      grace: 120
-   ReqUnset       X-Forwarded-For: 172.17.0.1
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   ReqUnset       Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqUnset       Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   VCL_return     pass
-   VCL_call       HASH
-   VCL_return     lookup
-   VCL_call       PASS
-   VCL_return     fetch
-   Link           bereq 32771 pass
-   Timestamp      Fetch: 1495619965.746498 0.001967 0.001967
-   RespProtocol   HTTP/1.1
-   RespStatus     200
-   RespReason     OK
-   RespHeader     Server: gunicorn/19.6.0
-   RespHeader     Date: Wed, 24 May 2017 09:59:25 GMT
-   RespHeader     Content-Type: text/html; charset=utf-8
-   RespHeader     Content-Length: 1285
-   RespHeader     Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   RespHeader     X-Varnish: 32770
-   RespHeader     Age: 0
-   RespHeader     Via: 1.1 varnish-v4
-   VCL_call       DELIVER
-   VCL_return     deliver
-   Timestamp      Process: 1495619965.746550 0.002019 0.000052
-   RespHeader     Accept-Ranges: bytes
-   Debug          "RES_MODE 2"
-   RespHeader     Connection: keep-alive
-   Timestamp      Resp: 1495619965.746604 0.002074 0.000055
-   ReqAcct        582 0 582 283 1285 1568
-   End            

*   << BeReq    >> 65538     
-   Begin          bereq 65537 pass
-   Timestamp      Start: 1495619968.351579 0.000000 0.000000
-   BereqMethod    GET
-   BereqURL       /
-   BereqProtocol  HTTP/1.1
-   BereqHeader    Host: localhost:8010
-   BereqHeader    Cache-Control: max-age=0
-   BereqHeader    Upgrade-Insecure-Requests: 1
-   BereqHeader    User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   BereqHeader    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   BereqHeader    Accept-Encoding: gzip, deflate, sdch, br
-   BereqHeader    Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   BereqHeader    grace: 120
-   BereqHeader    X-Forwarded-For: 172.17.0.1
-   BereqHeader    Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   BereqHeader    X-Varnish: 65538
-   VCL_call       BACKEND_FETCH
-   VCL_return     fetch
-   BackendOpen    22 boot.NODE2_PORT_80_TCP_ADDR 172.17.0.3 80 172.17.0.4 33840
-   Timestamp      Bereq: 1495619968.351859 0.000280 0.000280
-   Timestamp      Beresp: 1495619968.359301 0.007722 0.007442
-   BerespProtocol HTTP/1.1
-   BerespStatus   200
-   BerespReason   OK
-   BerespHeader   Server: gunicorn/19.6.0
-   BerespHeader   Date: Wed, 24 May 2017 09:59:28 GMT
-   BerespHeader   Connection: close
-   BerespHeader   Content-Type: text/html; charset=utf-8
-   BerespHeader   Content-Length: 1285
-   BerespHeader   Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   TTL            RFC 120 10 -1 1495619968 1495619968 1495619968 0 0
-   VCL_call       BACKEND_RESPONSE
-   TTL            VCL 120 10 0 1495619968
-   VCL_return     deliver
-   Storage        malloc Transient
-   ObjProtocol    HTTP/1.1
-   ObjStatus      200
-   ObjReason      OK
-   ObjHeader      Server: gunicorn/19.6.0
-   ObjHeader      Date: Wed, 24 May 2017 09:59:28 GMT
-   ObjHeader      Content-Type: text/html; charset=utf-8
-   ObjHeader      Content-Length: 1285
-   ObjHeader      Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   Fetch_Body     3 length stream
-   BackendClose   22 boot.NODE2_PORT_80_TCP_ADDR
-   Timestamp      BerespBody: 1495619968.359373 0.007794 0.000072
-   Length         1285
-   BereqAcct      584 0 584 209 1285 1494
-   End            

*   << Request  >> 65537     
-   Begin          req 32769 rxreq
-   Timestamp      Start: 1495619968.351513 0.000000 0.000000
-   Timestamp      Req: 1495619968.351513 0.000000 0.000000
-   ReqStart       172.17.0.1 42524
-   ReqMethod      GET
-   ReqURL         /
-   ReqProtocol    HTTP/1.1
-   ReqHeader      Host: localhost:8010
-   ReqHeader      Connection: keep-alive
-   ReqHeader      Cache-Control: max-age=0
-   ReqHeader      Upgrade-Insecure-Requests: 1
-   ReqHeader      User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   ReqHeader      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   ReqHeader      Accept-Encoding: gzip, deflate, sdch, br
-   ReqHeader      Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   ReqHeader      Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   VCL_call       RECV
-   ReqHeader      grace: 120
-   ReqUnset       X-Forwarded-For: 172.17.0.1
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   ReqUnset       Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqUnset       Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   VCL_return     pass
-   VCL_call       HASH
-   VCL_return     lookup
-   VCL_call       PASS
-   VCL_return     fetch
-   Link           bereq 65538 pass
-   Timestamp      Fetch: 1495619968.359385 0.007872 0.007872
-   RespProtocol   HTTP/1.1
-   RespStatus     200
-   RespReason     OK
-   RespHeader     Server: gunicorn/19.6.0
-   RespHeader     Date: Wed, 24 May 2017 09:59:28 GMT
-   RespHeader     Content-Type: text/html; charset=utf-8
-   RespHeader     Content-Length: 1285
-   RespHeader     Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   RespHeader     X-Varnish: 65537
-   RespHeader     Age: 0
-   RespHeader     Via: 1.1 varnish-v4
-   VCL_call       DELIVER
-   VCL_return     deliver
-   Timestamp      Process: 1495619968.359402 0.007889 0.000017
-   RespHeader     Accept-Ranges: bytes
-   Debug          "RES_MODE 2"
-   RespHeader     Connection: keep-alive
-   Timestamp      Resp: 1495619968.359457 0.007943 0.000054
-   ReqAcct        582 0 582 283 1285 1568
-   End            

*   << BeReq    >> 65540     
-   Begin          bereq 65539 pass
-   Timestamp      Start: 1495619969.542862 0.000000 0.000000
-   BereqMethod    GET
-   BereqURL       /
-   BereqProtocol  HTTP/1.1
-   BereqHeader    Host: localhost:8010
-   BereqHeader    Cache-Control: max-age=0
-   BereqHeader    Upgrade-Insecure-Requests: 1
-   BereqHeader    User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   BereqHeader    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   BereqHeader    Accept-Encoding: gzip, deflate, sdch, br
-   BereqHeader    Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   BereqHeader    grace: 120
-   BereqHeader    X-Forwarded-For: 172.17.0.1
-   BereqHeader    Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   BereqHeader    X-Varnish: 65540
-   VCL_call       BACKEND_FETCH
-   VCL_return     fetch
-   BackendOpen    22 boot.NODE1_PORT_80_TCP_ADDR 172.17.0.2 80 172.17.0.4 49110
-   Timestamp      Bereq: 1495619969.543072 0.000210 0.000210
-   Timestamp      Beresp: 1495619969.544415 0.001552 0.001343
-   BerespProtocol HTTP/1.1
-   BerespStatus   200
-   BerespReason   OK
-   BerespHeader   Server: gunicorn/19.6.0
-   BerespHeader   Date: Wed, 24 May 2017 09:59:29 GMT
-   BerespHeader   Connection: close
-   BerespHeader   Content-Type: text/html; charset=utf-8
-   BerespHeader   Content-Length: 1285
-   BerespHeader   Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   TTL            RFC 120 10 -1 1495619970 1495619970 1495619969 0 0
-   VCL_call       BACKEND_RESPONSE
-   TTL            VCL 120 10 0 1495619970
-   VCL_return     deliver
-   Storage        malloc Transient
-   ObjProtocol    HTTP/1.1
-   ObjStatus      200
-   ObjReason      OK
-   ObjHeader      Server: gunicorn/19.6.0
-   ObjHeader      Date: Wed, 24 May 2017 09:59:29 GMT
-   ObjHeader      Content-Type: text/html; charset=utf-8
-   ObjHeader      Content-Length: 1285
-   ObjHeader      Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   Fetch_Body     3 length stream
-   BackendClose   22 boot.NODE1_PORT_80_TCP_ADDR
-   Timestamp      BerespBody: 1495619969.544473 0.001611 0.000058
-   Length         1285
-   BereqAcct      584 0 584 209 1285 1494
-   End            

*   << Request  >> 65539     
-   Begin          req 32769 rxreq
-   Timestamp      Start: 1495619969.542799 0.000000 0.000000
-   Timestamp      Req: 1495619969.542799 0.000000 0.000000
-   ReqStart       172.17.0.1 42524
-   ReqMethod      GET
-   ReqURL         /
-   ReqProtocol    HTTP/1.1
-   ReqHeader      Host: localhost:8010
-   ReqHeader      Connection: keep-alive
-   ReqHeader      Cache-Control: max-age=0
-   ReqHeader      Upgrade-Insecure-Requests: 1
-   ReqHeader      User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   ReqHeader      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   ReqHeader      Accept-Encoding: gzip, deflate, sdch, br
-   ReqHeader      Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   ReqHeader      Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   VCL_call       RECV
-   ReqHeader      grace: 120
-   ReqUnset       X-Forwarded-For: 172.17.0.1
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   ReqUnset       Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqUnset       Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   VCL_return     pass
-   VCL_call       HASH
-   VCL_return     lookup
-   VCL_call       PASS
-   VCL_return     fetch
-   Link           bereq 65540 pass
-   Timestamp      Fetch: 1495619969.544486 0.001687 0.001687
-   RespProtocol   HTTP/1.1
-   RespStatus     200
-   RespReason     OK
-   RespHeader     Server: gunicorn/19.6.0
-   RespHeader     Date: Wed, 24 May 2017 09:59:29 GMT
-   RespHeader     Content-Type: text/html; charset=utf-8
-   RespHeader     Content-Length: 1285
-   RespHeader     Set-Cookie: voter_id=5f4e4d2b90164b49; Path=/
-   RespHeader     X-Varnish: 65539
-   RespHeader     Age: 0
-   RespHeader     Via: 1.1 varnish-v4
-   VCL_call       DELIVER
-   VCL_return     deliver
-   Timestamp      Process: 1495619969.544502 0.001703 0.000016
-   RespHeader     Accept-Ranges: bytes
-   Debug          "RES_MODE 2"
-   RespHeader     Connection: keep-alive
-   Timestamp      Resp: 1495619969.544548 0.001749 0.000046
-   ReqAcct        582 0 582 283 1285 1568
-   End            

*   << BeReq    >> 65542     
-   Begin          bereq 65541 pass
-   Timestamp      Start: 1495619970.980687 0.000000 0.000000
-   BereqMethod    POST
-   BereqURL       /
-   BereqProtocol  HTTP/1.1
-   BereqHeader    Host: localhost:8010
-   BereqHeader    Content-Length: 6
-   BereqHeader    Cache-Control: max-age=0
-   BereqHeader    Origin: http://localhost:8010
-   BereqHeader    Upgrade-Insecure-Requests: 1
-   BereqHeader    User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   BereqHeader    Content-Type: application/x-www-form-urlencoded
-   BereqHeader    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   BereqHeader    Referer: http://localhost:8010/
-   BereqHeader    Accept-Encoding: gzip, deflate, br
-   BereqHeader    Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   BereqHeader    grace: 120
-   BereqHeader    X-Forwarded-For: 172.17.0.1
-   BereqHeader    Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   BereqHeader    X-Varnish: 65542
-   VCL_call       BACKEND_FETCH
-   VCL_return     fetch
-   FetchError     no backend connection
-   Timestamp      Beresp: 1495619970.980796 0.000108 0.000108
-   Timestamp      Error: 1495619970.980810 0.000123 0.000015
-   BerespProtocol HTTP/1.1
-   BerespStatus   503
-   BerespReason   Service Unavailable
-   BerespReason   Backend fetch failed
-   BerespHeader   Date: Wed, 24 May 2017 09:59:30 GMT
-   BerespHeader   Server: Varnish
-   VCL_call       BACKEND_ERROR
-   BerespHeader   Content-Type: text/html; charset=utf-8
-   BerespHeader   Retry-After: 5
-   VCL_return     deliver
-   Storage        malloc Transient
-   ObjProtocol    HTTP/1.1
-   ObjStatus      503
-   ObjReason      Backend fetch failed
-   ObjHeader      Date: Wed, 24 May 2017 09:59:30 GMT
-   ObjHeader      Server: Varnish
-   ObjHeader      Content-Type: text/html; charset=utf-8
-   ObjHeader      Retry-After: 5
-   Length         282
-   BereqAcct      0 0 0 0 0 0
-   End            

*   << Request  >> 65541     
-   Begin          req 32769 rxreq
-   Timestamp      Start: 1495619970.980612 0.000000 0.000000
-   Timestamp      Req: 1495619970.980612 0.000000 0.000000
-   ReqStart       172.17.0.1 42524
-   ReqMethod      POST
-   ReqURL         /
-   ReqProtocol    HTTP/1.1
-   ReqHeader      Host: localhost:8010
-   ReqHeader      Connection: keep-alive
-   ReqHeader      Content-Length: 6
-   ReqHeader      Cache-Control: max-age=0
-   ReqHeader      Origin: http://localhost:8010
-   ReqHeader      Upgrade-Insecure-Requests: 1
-   ReqHeader      User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36
-   ReqHeader      Content-Type: application/x-www-form-urlencoded
-   ReqHeader      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
-   ReqHeader      Referer: http://localhost:8010/
-   ReqHeader      Accept-Encoding: gzip, deflate, br
-   ReqHeader      Accept-Language: en-US,en;q=0.8,fi;q=0.6
-   ReqHeader      Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   VCL_call       RECV
-   ReqHeader      grace: 120
-   ReqUnset       X-Forwarded-For: 172.17.0.1
-   ReqHeader      X-Forwarded-For: 172.17.0.1
-   ReqUnset       Cookie: _ga=GA1.1.1161501955.1482492854; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqUnset       Cookie: ; frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   ReqHeader      Cookie: frosmo_quickContext=%7B%22UID%22%3A%22oi1f04.iv29lquk%22%2C%22VERSION%22%3A%221.1.0%22%7D; voter_id=5f4e4d2b90164b49
-   VCL_return     pass
-   VCL_call       HASH
-   VCL_return     lookup
-   VCL_call       PASS
-   VCL_return     fetch
-   Link           bereq 65542 pass
-   Timestamp      Fetch: 1495619970.980861 0.000249 0.000249
-   Timestamp      ReqBody: 1495619970.980882 0.000270 0.000021
-   RespProtocol   HTTP/1.1
-   RespStatus     503
-   RespReason     Backend fetch failed
-   RespHeader     Date: Wed, 24 May 2017 09:59:30 GMT
-   RespHeader     Server: Varnish
-   RespHeader     Content-Type: text/html; charset=utf-8
-   RespHeader     Retry-After: 5
-   RespHeader     X-Varnish: 65541
-   RespHeader     Age: 0
-   RespHeader     Via: 1.1 varnish-v4
-   VCL_call       DELIVER
-   VCL_return     deliver
-   Timestamp      Process: 1495619970.980900 0.000288 0.000018
-   RespHeader     Content-Length: 282
-   Debug          "RES_MODE 2"
-   RespHeader     Connection: keep-alive
-   Timestamp      Resp: 1495619970.980972 0.000360 0.000072
-   ReqAcct        709 6 715 239 282 521
-   End            

*   << Session  >> 32772     
-   Begin          sess 0 HTTP/1
-   SessOpen       172.17.0.1 42528 0.0.0.0:8010 172.17.0.4 8010 1495619968.343914 20
-   SessClose      RX_TIMEOUT 5.005
-   End            

*   << Session  >> 32769     
-   Begin          sess 0 HTTP/1
-   SessOpen       172.17.0.1 42524 0.0.0.0:8010 172.17.0.4 8010 1495619965.738747 19
-   Link           req 32770 rxreq
-   Link           req 65537 rxreq
-   Link           req 65539 rxreq
-   Link           req 65541 rxreq
-   SessClose      RX_TIMEOUT 10.247
-   End            


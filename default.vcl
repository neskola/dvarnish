vcl 4.0;

backend default {
  .host = "127.0.0.1";
  .port = "8080";
  .connect_timeout = 60s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .max_connections = 800;
}
 
acl purge {
  "127.0.0.1";
  "localhost";
}
 
sub vcl_recv {
  set req.grace = 2m;
 
  # Set X-Forwarded-For header for logging in nginx
  remove req.http.X-Forwarded-For;
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
}

  
sub vcl_init {
    new cluster1 = directors.round_robin();

}
  
sub vcl_fetch {
   if (req.url ~ "\.(css|js|png|gif|jpg)$") {
     unset beresp.http.set-cookie;
     set beresp.ttl = 66h;
  }
}
  
sub vcl_recv {
    set req.backend_hint = cluster1.backend();
}

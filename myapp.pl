#!/usr/bin/env perl
use utf8;
use Mojolicious::Lite;

get '/' => sub {
  my $self = shift;
  my $body = $self->param('body');
  $self->stash(body => $body);
  $self->render('index');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
%= form_for '/' => begin
  %= text_field 'body'
  %= submit_button '投稿する'
% end
<p><%= $body %></p>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

#!/usr/bin/env perl
use utf8;
use Mojolicious::Lite;

get '/' => sub {
  my $self = shift;
  $self->render('index');
};

post '/post' => sub {
  my $self = shift;
  my $body = $self->param('body');
  $self->stash(body => $body);
  $self->render('post');
};

app->start;
__DATA__

@@ form.html.ep
%= form_for '/post' => method => 'POST' => begin
  %= text_field 'body'
  %= submit_button '投稿する'
% end

@@ index.html.ep
% layout 'default';
% title '入力フォーム';
%= include 'form'

@@ post.html.ep
% layout 'default';
% title '出力';
%= include 'form'
<p><%= $body %></p>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

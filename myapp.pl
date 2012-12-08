#!/usr/bin/env perl
use utf8;
use Mojolicious::Lite;
use Encode;
use Time::Piece;
use Mojo::Util;
use Mojo::JSON;

helper xml_escape => sub {
  shift;
  Mojo::Util::xml_escape(@_)
};

get '/' => sub {
  my $self = shift;
  my $datafile = qq{myapp.dat};
  unless (-e $datafile ) {
    open my $fh, '>', $datafile or die $!;
    close $fh;
  }
  open my $fh, '<', $datafile or die $!;
  my @entries = <$fh>;
  close $fh;
  my $json = Mojo::JSON->new;
  @entries = map { $json->decode($_) } reverse @entries;
  $self->stash(entries => \@entries);
  $self->render('index');
};

post '/post' => sub {
  my $self = shift;
  my $body = $self->param('body');
  if ($body =~ /\A[\s　]*\z/ms) {
    $self->redirect_to('/');
    return;
  }
  my $entry = {
    body => $body,
    posted => time,
  };
  my $data = Mojo::JSON->new->encode($entry);
  my $datafile = qq{myapp.dat};
  open my $fh, '>>', $datafile or die $!;
  print $fh qq{$data\n};
  close $fh;
  $self->redirect_to('/');
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
% for my $entry (@{$entries}) {
  % my $body = xml_escape $entry->{body};
  % $body =~ s!(https?://[^\s　]+)!<a href="$1">$1</a>!msg;
  % my $posted = Time::Piece::localtime($entry->{posted});
  <p><%== $body %> (<%= $posted->ymd('/') %> <%= $posted->hms(':') %>)</p>
% }

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

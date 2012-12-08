#!/usr/bin/env perl
use utf8;
use Mojolicious::Lite;
use Encode;
use Time::Piece;

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
  @entries = map { decode_utf8($_) } reverse @entries;
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
  my $now = localtime;
  $body .= sprintf qq{ (%s %s)}, $now->ymd('/'), $now->hms(':');
  my $datafile = qq{myapp.dat};
  open my $fh, '>>', $datafile or die $!;
  print $fh encode_utf8(qq{$body\n});
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
  % chomp $entry;
  % $entry =~ s!(https?://[^\s　]+)!<a href="$1">$1</a>!msg;
  <p><%== $entry %></p>
% }

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Test::Deep;
use File::Spec;
BEGIN {
    (my $volume, my $directories, my $file) = File::Spec->splitpath($0);
    my $shredder_utils = File::Spec->catfile(
        File::Spec->catdir(File::Spec->curdir(), $directories), "utils.pl");
    require $shredder_utils;
}

plan tests => 9;

my @ARGS = sort qw(limit status name email replace_relations no_tickets);

use_ok('RT::Shredder::Plugin::Users');
{
    my $plugin = new RT::Shredder::Plugin::Users;
    isa_ok($plugin, 'RT::Shredder::Plugin::Users');

    is(lc $plugin->Type, 'search', 'correct type');

    my @args = sort $plugin->SupportArgs;
    cmp_deeply(\@args, \@ARGS, "support all args");

    my ($status, $msg) = $plugin->TestArgs( name => 'r??t*' );
    ok($status, "arg name = 'r??t*'") or diag("error: $msg");

    for (qw(any disabled enabled)) {
        my ($status, $msg) = $plugin->TestArgs( status => $_ );
        ok($status, "arg status = '$_'") or diag("error: $msg");
    }
    ($status, $msg) = $plugin->TestArgs( status => '!@#' );
    ok(!$status, "bad 'status' arg value");
}


#!/usr/bin/env perl
# @hc0d3r
# ~ ~ ~ ~ w1r3bot ~ ~ ~ ~
# you can do anything with this code, except sale it,
# is very recommend print this and use as toilet paper

BEGIN { push @INC, './lib/'; push @INC, './plugins/'; }

use strict;
use warnings;
use w1r3bot;
use w1r3::net;
use Module::Load;

sub help_banner {
    print <<HELP;

 [+] w1rebot v@{[ &w1r3bot::VERSION ]}

  -c > irc host to connect
  -p > irc port to connect
  -t > timeout to connect
  -n > set your nickname
  -u > set username
  -r > set real username
  -pw > set your password
  -j > chans to join
  -a > set admins
  -h > display this help menu

  [*] Examples:

    w1r3bot -c irc.matrix -p 6667 -n neo -p 2674rul3z -j '#morpheus,#trynity,#smith' -a master_of_puppets -4

HELP
    exit;
};

sub parser_opts {
    my($out,$in) = @_;
    my $ok;

    for(my $i=0; $i<@ARGV; $i++){
        $ok = 0;

        foreach my $arg( keys %$in){
            my($need_arg,$argname) = @{ $in->{$arg} };

            if($ARGV[$i] =~ /^-$arg$/){
                $ok = 1;
                if(!$need_arg){
                    $$out{$argname} = 1;
                } else {
                    die "-$arg: needs argument\n" if(!defined $ARGV[++$i]);
                    $$out{$argname} = $ARGV[$i];
                }

                last;
            }
        }

        die "Invalid option: $ARGV[$i]\n" if(!$ok);
    }
}

my(%opts);
parser_opts \%opts, {
    c => [1, 'host'],
    p => [1, 'port'],
    n => [1, 'nick'],
    u => [1, 'user'],
    r => [1, 'realname'],
    j => [1, 'chans'],
    a => [1, 'admins'],
    t => [1, 'timeout'],
    h => [0, 'help'],
    4 => [0, 'ipv4'],
    6 => [0, 'ipv6'],
    pw => [1, 'password']
};

help_banner if($opts{'help'});

if(!$opts{'host'} || !$opts{'port'}){
    warn "\nYou must set a host and port to connect\n";
    warn "Use -h to get help\n\n";
    exit;
}

print "\n\n";
print "[+] irc host: ".$opts{'host'}."\n";
print "[+] irc port: ".$opts{'port'}."\n";

if(!$opts{'nick'}){
    warn "[-] Nickname not set, using default: ".&w1r3bot::DEFAULT_NICK."\n";
}

if(!$opts{'admins'}){
    warn "[-] You not set admins, many functions needs admin priv !\n";
} else {
    $opts{'admins'} = [split /,/, $opts{'admins'}];
    print "[+] Admin list: ".(join ",",@{ $opts{'admins'} })."\n";
}

$opts{'chans'} = [split /,/, $opts{'chans'}] if(defined $opts{'chans'});

print "[+] Chan list: ".(join ",",@{ $opts{'chans'} })."\n" if($opts{'chans'});
print "[+] Connecting ...\n";
print "\n\n";


my $bot = new w1r3bot(
    nick =>  $opts{'nick'},
    realname => $opts{'realname'},
    password => $opts{'password'},
    username => $opts{'user'}
);

$bot->set_admins(@{ $opts{'admins'} });
$bot->join_chans(@{ $opts{'chans'} });

foreach my $file(glob("plugins/*.pm")){
	$file =~ s/plugins\/(.*).pm$/$1/;
	load $file;
	$file->load_functions($bot);
}

if( $bot->xconnect(
        host => $opts{'host'},
        port => $opts{'port'},
        verbose => 1,
        timeout => $opts{'timeout'},
)){
    $bot->main_loop;
} else {
    warn "[-] Failed to connect on ".$opts{'host'}.":".$opts{'port'}." (".$bot->{'w1r3socket'}->get_err.")\n\n";
}

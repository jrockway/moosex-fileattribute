use inc::Module::Install;
use strict;

all_from 'lib/MooseX/FileAttribute.pm';

requires 'Moose';
requires 'Moose::Util::MetaRole';
requires 'MooseX::Types' => '0.11';
requires 'MooseX::Types::Path::Class';

test_requires 'Test::More';
test_requires 'Test::Exception';

repository 'http://github.com/jrockway/moosex-fileattribute';
bugtracker 'http://github.com/jrockway/moosex-fileattribute';
license 'Perl';

WriteAll();

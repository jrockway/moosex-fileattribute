package MooseX::FileAttribute;
use strict;
use warnings;
use Moose::Exporter;

our $VERSION = '0.01';
use 5.008001;

use MooseX::Types -declare => ['ExistingFile', 'ExistingDir'];
use MooseX::Types::Moose qw(Str);
use MooseX::Types::Path::Class qw(File Dir);

Moose::Exporter->setup_import_methods(
    with_meta => ['has_file', 'has_directory'],
    # as_is     => [qw/File Dir ExistingFile ExistingDir/],
);

subtype ExistingFile, as File, where { -e $_->stringify },
  message { "File '$_' must exist." };

subtype ExistingDir, as Dir, where { -e $_->stringify && -d $_->stringify },
  message { "Directory '$_' must exist" };

coerce ExistingFile, from Str, via { Path::Class::file($_) };
coerce ExistingDir, from Str, via { Path::Class::dir($_) };

sub has_file {
    my ($meta, $name, %options) = @_;

    my $must_exist = delete $options{must_exist} || 0;

    $meta->add_attribute(
        $name,
        is     => 'ro',
        isa    => $must_exist ? ExistingFile : File,
        coerce => 1,
        %options,
    );
}

sub has_directory {
    my ($meta, $name, %options) = @_;

    my $must_exist = delete $options{must_exist} || 0;

    $meta->add_attribute(
        $name,
        is     => 'ro',
        isa    => $must_exist ? ExistingDir : Dir,
        coerce => 1,
        %options,
    );
}

1;

__END__

=head1 NAME

MooseX::FileAttribute - sugar for classes that have file or directory attributes

=head1 SYNOPSIS

Instead of C<has>, use C<has_file> or C<has_directory> to create
attributes that hold a file or directory:

   package Class;
   use Moose;
   use MooseX::FileAttribute;

   has_file 'foo' => (
       documentation => 'path to the foo file',
       must_exist    => 1,
       required      => 1,
   );

   has_directory 'bar' => (
       required => 1,
   );

   sub BUILD {
       use autodie 'mkdir';
       mkdir $self->bar unless -d $self->bar;
   }

Then use the class like you'd use any Moose class:

   my $c = Class->new( foo => '/quux/bar/foo', bar => '/quux/bar/' );
   my $fh = $c->foo->openr; # string initarg promoted to Path::Class::File attribute
   while( my $line = <$fh> ) { ... }

=head1 DESCRIPTION

I write a lot of classes that take files or directories on the
command-line.  This results in a lot of boilerplate, usually:

   package Class;
   use Moose;
   use MooseX::Types::Path::Class qw(File);

   has 'foo' => (
       is       => 'ro',
       isa      => File,
       coerce   => 1,
       required => 1,
   );

This module lets you save yourself some typing in this case:

   has_file 'foo' => ( required => 1 );

These are exactly equivalent.  C<has_directory> does the same thing
that C<has_file> does, but with a C<Dir> constraint.

This module also defines two additional type constraints to ensure
that the specified file or directory exists and is a file or
directory.  You can use these constraints instead of the defaults by
passing C<< must_exist => 1 >> to the C<has_*> function.

=head1 BUGS

The ExistingFile constraint will accept named pipes, ttys,
directories, etc., as files, as long as what's named exists on disk.
The ExistingDir constraint is more strict, only allowing directories.

=head1 REPOSITORY AND BUG TRACKER

http://github.com/jrockway/moosex-fileattribute

=head1 AUTHOR

Jonathan Rockway C<< <jrockway@cpan.org> >>

=head1 COPYRIGHT

Copyright (c) 2009 Jonathan Rockway.

This module is Free software.  You can redistribute it under the same
terms as Perl itself.

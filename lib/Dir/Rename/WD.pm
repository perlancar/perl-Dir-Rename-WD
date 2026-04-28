package Dir::Rename::WD;

use strict;
use warnings;

use Cwd 'cwd';
use Errno qw(EINVAL EBUSY);
use Exporter qw(import);

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(rename_wd);

sub rename_wd {
    defined(my $new_name = shift) or do { $! = EINVAL; return };
    @_ and do { $! = EINVAL; return };

    # check new name
    length $new_name or do { $! = EINVAL; return };
    $new_name =~ s!\\!/!g if $^O eq 'MSWin32';
    $new_name =~ m!/! and do { $! = EINVAL; return };
    $new_name eq '.' and return 1;
    $new_name eq '..' and do { $! = EINVAL; return };

    # up one dir
    my $cwd = cwd();
    $cwd =~ s!\\!/!g if $^O eq 'MSWin32';
    $cwd =~ s!.+/!!;
    if ($cwd eq '/') { $! = EBUSY; return }
    chdir ".." or return;

    # rename
    rename $cwd, $new_name or return;

    # cd into new dir
    chdir $new_name or return;

    1;
}

1;
# ABSTRACT: Rename current working directory

=head1 SYNOPSIS

 use Dir::Rename::WD qw(rename_wd);

 rename_wd "newname" or die "Can't rename working directory: $!";


=head1 DESCRIPTION

This module provides a single routine to change working directory then put the
process back to the newly renamed working directory. Basically to do this, we
change directory up one level first, then change into the directory after the
rename.


=head1 FUNCTIONS

=head2 rename_wd

Usage:

 rename_wd $newname

Rename current working directory. Takes a single argument (will set C<$!> to
C<EINVAL> if argument not supplied or extra arguments are supplied).

Return true on success, false otherwise (check C<$!> for error detail). Failing
also include case when directory has been renamed but we cannot change back into
it e.g. due to permission problem like directory not having execute bit set.

Root directory cannot be renamed (will set C<$!> to C<EBUSY>).


=head1 SEE ALSO

L<renwd> from L<App::renwd> provides a CLI for this routine.

L<renlikewd> from L<App::renlikewd> which provides tab completion for renaming
current directory on the CLI.

=cut

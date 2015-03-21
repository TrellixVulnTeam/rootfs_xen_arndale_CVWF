# debian/source directory content -- lintian check script -*- perl -*-

# Copyright (C) 2010 by Raphaël Hertzog
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, you can find it on the World Wide
# Web at http://www.gnu.org/copyleft/gpl.html, or write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
# MA 02110-1301, USA.

package Lintian::debian_source_dir;
use strict;
use warnings;
use autodie;

use List::MoreUtils qw(any);

use Lintian::Data;
use Lintian::Tags qw(tag);

our %KNOWN_FORMATS = map { $_ => 1 }
  ('1.0', '2.0', '3.0 (quilt)', '3.0 (native)', '3.0 (git)', '3.0 (bzr)');

our $KNOWN_FILES = Lintian::Data->new('debian-source-dir/known-files');

sub run {
    my (undef, undef, $info) = @_;
    my $dsrc = $info->debfiles('source');

    if (!-l "$dsrc/format" && -e "$dsrc/format") {
        open(my $fd, '<', "$dsrc/format");
        my $format = <$fd>;
        chomp $format;
        close($fd);
        tag 'unknown-source-format', $format unless $KNOWN_FORMATS{$format};
    } else {
        tag 'missing-debian-source-format';
    }

    if (!-l "$dsrc/git-patches" && -s "$dsrc/git-patches") {
        open(my $git_patches_fd, '<', "$dsrc/git-patches");
        if (any { !/^\s*+#|^\s*+$/o} <$git_patches_fd>) {
            my $dpseries = $info->debfiles('patches/series');
            # gitpkg does not create series as a link, so this is most likely
            # a traversal attempt.
            if (!-l $dpseries) {
                if (!-r $dpseries) {
                    tag 'git-patches-not-exported';
                } else {
                    open(my $series_fd, '<', $dpseries);
                    my $comment_line = <$series_fd>;
                    my $count = grep { !/^\s*+\#|^\s*+$/o } <$series_fd>;
                    tag 'git-patches-not-exported'
                      unless (
                        $count
                        && ($comment_line
                            =~ m/^\s*\#.*quilt-patches-deb-export-hook/o));
                    close($series_fd);
                }
            }
        }
        close($git_patches_fd);
    }

    if (!-l $dsrc && -d $dsrc) {
        opendir(my $dirfd, $dsrc);
        while (my $file = readdir($dirfd)) {
            next if $file eq '.' or $file eq '..';
            tag 'unknown-file-in-debian-source', $file
              unless $KNOWN_FILES->known($file);
        }
        closedir($dirfd);
    }

    return;
}

1;

# Local Variables:
# indent-tabs-mode: nil
# cperl-indent-level: 4
# End:
# vim: syntax=perl sw=4 sts=4 sr et

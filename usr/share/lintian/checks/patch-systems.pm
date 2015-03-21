# patch-systems -- lintian check script -*- perl -*-
#
# Copyright (C) 2007 Marc Brockschmidt
# Copyright (C) 2008 Raphael Hertzog
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

package Lintian::patch_systems;
use strict;
use warnings;
use autodie;

use constant PATCH_DESC_TEMPLATE => 'TODO: Put a short summary on'
  . ' the line above and replace this paragraph';

use Lintian::Tags qw(tag);
use Lintian::Util qw(fail is_ancestor_of strip);

sub run {
    my (undef, undef, $info) = @_;

    # Some (cruft) checks are valid for every patch system, so we need
    # to record that:
    my $uses_patch_system = 0;

    # Get build deps so we can decide which build system the
    # maintainer meant to use:
    my $build_deps = $info->relation('build-depends-all');
    # Get source package format
    my $format = '';
    if (defined $info->field('format')) {
        $format = $info->field('format');
    }
    my $quilt_format = ($format =~ /3\.\d+ \(quilt\)/) ? 1 : 0;

    my $droot = $info->debfiles;
    my $dpdir = "$droot/patches";
    if (!is_ancestor_of($droot, $dpdir)) {
        # Bad symlink
        return;
    }

    #----- dpatch
    if ($build_deps->implies('dpatch')) {
        $uses_patch_system++;
        #check for a debian/patches file:
        if (-l "$dpdir/00list" and not is_ancestor_of($droot, "$dpdir/00list"))
        {
            # skip
        } elsif (!-r "$dpdir/00list") {
            tag 'dpatch-build-dep-but-no-patch-list';
        } else {
            my $list_uses_cpp = 0;
            if (-f "$dpdir/00options"
                && is_ancestor_of($droot, "$dpdir/00options")) {
                open(my $fd, '<', "$dpdir/00options");
                while(<$fd>) {
                    if (/DPATCH_OPTION_CPP=1/) {
                        $list_uses_cpp = 1;
                        last;
                    }
                }
                close($fd);
            }
            foreach my $listfile (glob("$dpdir/00list*")) {
                my @patches;
                if (-f $listfile and is_ancestor_of($droot, $listfile)) {
                    open(my $fd, '<', $listfile);
                    while(<$fd>) {
                        chomp;
                        next if (/^\#/); #ignore comments or CPP directive
                        s%//.*%% if $list_uses_cpp; # remove C++ style comments
                        if ($list_uses_cpp && m%/\*%) {
                            # remove C style comments
                            $_ .= <$fd> while($_ !~ m%\*/%);
                            s%/\*[^*]*\*/%%g;
                        }
                        next if (/^\s*$/); #ignore blank lines
                        push @patches, split(' ', $_);
                    }
                    close($fd);
                }

                # Check each patch.
                foreach my $patch_file (@patches) {
                    $patch_file .= '.dpatch'
                      if -e "$dpdir/$patch_file.dpatch"
                      and not -e "$dpdir/$patch_file";
                    next if (-l "$dpdir/$patch_file");
                    next unless is_ancestor_of($droot, "$dpdir/$patch_file");

                    if (!-r "$dpdir/$patch_file") {
                        tag 'dpatch-index-references-non-existent-patch',
                          $patch_file;
                        next;
                    }
                    if (-f "$dpdir/$patch_file") {
                        my $has_comment = 0;
                        open(my $fd, '<', "$dpdir/$patch_file");
                        while (<$fd>) {
                            # stop if something looking like a patch
                            # starts:
                            last if /^---/;
                            # note comment if we find a proper one
                            $has_comment = 1
                              if (/^\#+\s*DP:\s*(\S.*)$/
                                && $1 !~ /^no description\.?$/i);
                            $has_comment = 1
                              if (/^\# (?:Description|Subject)/);
                        }
                        close($fd);
                        unless ($has_comment) {
                            tag 'dpatch-missing-description', $patch_file;
                        }
                    }
                    check_patch($dpdir, $patch_file);
                }
            }
        }
    }

    #----- quilt
    if ($build_deps->implies('quilt') or $quilt_format) {
        $uses_patch_system++;
        # check for a debian/patches file:
        if (-l "$dpdir/series" and not is_ancestor_of($droot, "$dpdir/series"))
        {
            # skip
        } elsif (!-r "$dpdir/series") {
            tag 'quilt-build-dep-but-no-series-file' unless $quilt_format;
        } else {
            if (-f "$dpdir/series") {
                my @patches;
                my @badopts;
                open(my $series_fd, '<', "$dpdir/series");
                while (my $patch = <$series_fd>) {
                    my $hastrailingnewline = 0;
                    $patch =~ s/(?:^|\s+)#.*$//; # Strip comment
                    next unless $patch;
                    if (rindex($patch,"\n") < 0) {
                        tag 'quilt-series-without-trailing-newline';
                    }
                    strip($patch); # Strip leading/trailing spaces
                    if ($patch =~ m{^(\S+)\s+(\S.*)$}) {
                        my $patch_options;
                        ($patch, $patch_options) = ($1, $2);
                        if ($patch_options ne '-p1') {
                            push @badopts, $patch;
                        }
                    }
                    push @patches, $patch;
                }
                close($series_fd);
                if (scalar(@badopts)) {
                    tag 'quilt-patch-with-non-standard-options', @badopts;
                }

                # Check each patch.
                foreach my $patch_file (@patches) {
                    next if (-l "$dpdir/$patch_file");
                    next unless is_ancestor_of($droot, "$dpdir/$patch_file");

                    if (!-r "$dpdir/$patch_file") {
                        tag 'quilt-series-references-non-existent-patch',
                          $patch_file;
                        next;
                    }
                    if (-f "$dpdir/$patch_file") {
                        my $has_description = 0;
                        my $has_template_description = 0;
                        open(my $patch_fd, '<', "$dpdir/$patch_file");
                        while (<$patch_fd>) {
                            # stop if something looking like a patch starts:
                            last if /^---/;
                            next if /^\s*$/;
                            # Skip common "lead-in" lines
                            $has_description = 1
                              unless m{^(?:Index: |=+$|diff .+|index )};
                            $has_template_description = 1
                              if index($_, PATCH_DESC_TEMPLATE) != -1;
                        }
                        close($patch_fd);
                        unless ($has_description) {
                            tag 'quilt-patch-missing-description', $patch_file;
                        }
                        if ($has_template_description) {
                            tag 'quilt-patch-using-template-description',
                              $patch_file;
                        }
                    }
                    check_patch($dpdir, $patch_file);
                }
            }
        }
        if ($quilt_format) { # 3.0 (quilt) specific checks
            # Format 3.0 packages may generate a debian-changes-$version patch
            my $version = $info->field('version');
            my $versioned_patch = "$dpdir/debian-changes-$version";
            my $patch_header = "$droot/source/patch-header";
            my $ok = 1;
            if (-l "$droot/source" or -l $patch_header) {
                # possible issue
                if (!is_ancenstor_of($droot, $patch_header)) {
                    $ok = 0;
                }
            }
            # $dpdir is known to be safe at this point, so only check
            # the patch itself
            if ($ok and -l $versioned_patch) {
                if (!is_ancenstor_of($droot, $versioned_patch)) {
                    $ok = 0;
                }
            }
            if ($ok && -f $versioned_patch && !-f $patch_header) {
                tag 'format-3.0-but-debian-changes-patch';
            }
        }
    } else {
        if (    -r "$dpdir/series"
            and -f "$dpdir/series") {
            # 3.0 (quilt) sources don't need quilt as dpkg-source will
            # do the work
            if (!-l "$dpdir/series" || is_ancestor_of($droot, "$dpdir/series"))
            {
                tag 'quilt-series-but-no-build-dep' unless $quilt_format;
            }
        }
    }

    #----- look for README.source
    if ($uses_patch_system && !$quilt_format && !-f "$droot/README.source") {
        if (!-l "$droot/README.source") {
            # tag, unless README.source was a symlink (which could be a
            # traversal attempt)
            tag 'patch-system-but-no-source-readme';
        }
    }

    #----- general cruft checking:
    if ($uses_patch_system > 1) {
        tag 'more-than-one-patch-system';
    }
    my @direct;
    open(my $fd, '<', $info->diffstat);
    while (<$fd>) {
        my ($file) = (m,^\s+(.*?)\s+\|,)
          or fail("syntax error in diffstat file: $_");
        push(@direct, $file) if ($file !~ m,^debian/,);
    }
    close($fd);
    if (@direct) {
        my $files= (@direct > 1) ? "$direct[0] and $#direct more" : $direct[0];

        tag 'patch-system-but-direct-changes-in-diff', $files
          if ($uses_patch_system);
        tag 'direct-changes-in-diff-but-no-patch-system', $files
          if (not $uses_patch_system);
    }
    return;
}

# Checks on patches common to all build systems.
sub check_patch {
    my ($dpdir, $patch_file) = @_;

    # Use --strip=1 to strip off the first layer of directory in case
    # the parent directory in which the patches were generated was
    # named "debian".  This will produce false negatives for --strip=0
    # patches that modify files in the debian/* directory, but as of
    # 2010-01-01, all cases where the first level of the patch path is
    # "debian/" in the archive are false positives.
    open(my $fd, '-|', 'lsdiff', '--strip=1', "$dpdir/$patch_file");
    while (<$fd>) {
        chomp;
        if (m|^(?:\./)?debian/|o) {
            tag 'patch-modifying-debian-files', $patch_file, $_;
        }
    }
    close($fd);
    return;
}

1;

# Local Variables:
# indent-tabs-mode: nil
# cperl-indent-level: 4
# End:
# vim: syntax=perl sw=4 sts=4 sr et

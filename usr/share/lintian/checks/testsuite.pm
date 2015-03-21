# testsuite -- lintian check script -*- perl -*-

# Copyright (C) 2013 Nicolas Boulenguez <nicolas@debian.org>

# This file is part of lintian.

# Lintian is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Lintian is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Lintian.  If not, see <http://www.gnu.org/licenses/>.

package Lintian::testsuite;

use strict;
use warnings;
use autodie;

use Lintian::Tags qw(tag);
use Lintian::Util qw(
  file_is_encoded_in_non_utf8
  read_dpkg_control
);

# empty because it is test xor test-command
my @MANDATORY_FIELDS = qw(
);

my %KNOWN_FIELDS = map { $_ => 1 } qw(
  tests
  restrictions
  features
  depends
  tests-directory
  test-command
);
my %KNOWN_FEATURES = map { $_ => 1 } qw(
);
my %KNOWN_RESTRICTIONS = map { $_ => 1 } qw(
  allow-stderr
  breaks-testbed
  build-needed
  isolation-container
  isolation-machine
  needs-recommends
  needs-root
  rw-build-tree
);

sub run {
    my ($pkg, $type, $info) = @_;
    my $testsuite = $info->field('testsuite');
    my $control = $info->index('debian/tests/control');

    if (defined($testsuite) xor defined($control)) {
        tag 'inconsistent-testsuite-field';
    }
    if (defined($testsuite) and $testsuite ne 'autopkgtest') {
        tag 'unknown-testsuite', $testsuite;
    }

    if (defined($control)) {
        if (not $control->is_regular_file) {
            tag 'debian-tests-control-is-not-a-regular-file';
        } else {
            # Since $control is defined, we know that none of the
            # parent segments (i.e. debian and debian/tests) were
            # symlinks.  With the "is_regular_file" test above we know
            # that the file itself is not a symlink.  These two facts
            # _combined_ means we can skip the is_ancestor_of check
            # here.
            my $path = $info->unpacked($control);
            my $not_utf8_line = file_is_encoded_in_non_utf8($path);

            if ($not_utf8_line) {
                tag 'debian-tests-control-uses-national-encoding',
                  "at line $not_utf8_line";
            }
            check_control_contents($info, $path);
        }
    }
    return;
}

sub check_control_contents {
    my ($info, $path) = @_;

    my @paragraphs;
    my @lines = ();
    if (not eval { @paragraphs = read_dpkg_control($path, 0, \@lines); }) {
        chomp $@;
        $@ =~ s/^syntax error at //;
        tag 'syntax-error-in-debian-tests-control', $@;
    } else {
        while (my ($index, $paragraph) = each(@paragraphs)) {
            check_control_paragraph($info, $paragraph,
                $lines[$index]->{'START-OF-PARAGRAPH'});
        }
    }
    return;
}

sub check_control_paragraph {
    my ($info, $paragraph, $line) = @_;

    for my $fieldname (@MANDATORY_FIELDS) {
        if (not exists $paragraph->{$fieldname}) {
            tag 'missing-runtime-tests-field', $fieldname,
              'paragraph starting at line', $line;
        }
    }

    unless (exists $paragraph->{'tests'}
        || exists $paragraph->{'test-command'}) {
        tag 'missing-runtime-tests-field', 'tests || test-command',
          'paragraph starting at line', $line;
    }
    if (   exists $paragraph->{'tests'}
        && exists $paragraph->{'test-command'}) {
        tag 'exclusive-runtime-tests-field', 'tests, test-command',
          'paragraph starting at line', $line;
    }

    for my $fieldname (sort(keys(%{$paragraph}))) {
        if (not exists $KNOWN_FIELDS{$fieldname}) {
            tag 'unknown-runtime-tests-field', $fieldname,
              'paragraph starting at line', $line;
        }
    }

    if (exists $paragraph->{'features'}) {
        for my $feature (split(' ', $paragraph->{'features'})) {
            if (not exists $KNOWN_FEATURES{$feature}) {
                tag 'unknown-runtime-tests-feature', $feature,
                  'paragraph starting at line', $line;
            }
        }
    }

    if (exists $paragraph->{'restrictions'}) {
        for my $restriction (split ' ', $paragraph->{'restrictions'}) {
            if (not exists $KNOWN_RESTRICTIONS{$restriction}) {
                tag 'unknown-runtime-tests-restriction', $restriction,
                  'paragraph starting at line', $line;
            }
        }
    }

    if (exists $paragraph->{'tests'}) {
        my $directory = 'debian/tests';
        if (exists $paragraph->{'tests-directory'}) {
            $directory = $paragraph->{'tests-directory'};
        }
        for my $testname (split(' ', $paragraph->{'tests'})) {
            check_test_file($info, $directory, $testname, $line);
        }
    }
    return;
}

sub check_test_file {
    my ($info, $directory, $name, $line) = @_;
    my $path = "$directory/$name";
    my $index = $info->index($path);

    if ($name !~ m{^ [ [:alnum:] \+ \- \. / ]++ $}xsm) {
        tag 'illegal-runtime-test-name', $name,
          'paragraph starting at line', $line;
    }
    if (not defined($index)) {
        tag 'missing-runtime-test-file', $path,
          'paragraph starting at line', $line;
    } elsif (not $index->is_regular_file) {
        tag 'runtime-test-file-is-not-a-regular-file', $path;
    }
    # Test files are allowed not to be executable.
    return;
}

1;

# source-copyright-file -- lintian check script -*- perl -*-

# Copyright (C) 2011 Jakub Wilk
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

package Lintian::source_copyright;

use strict;
use warnings;
use autodie;

use File::Find qw();

use List::MoreUtils qw(any);
use Text::Levenshtein qw(distance);

use Lintian::Relation::Version qw(versions_compare);
use Lintian::Tags qw(tag);
use Lintian::Util qw(parse_dpkg_control slurp_entire_file);
use Lintian::Data;

my $BAD_SHORT_LICENSES = Lintian::Data->new(
    'source-copyright/bad-short-licenses',
    qr/\s*\~\~\s*/,
    sub {
        return {
            'regex' => qr/$_[0]/xms,
            'tag'   => $_[1],
        };
    });

my $dep5_last_normative_change = '0+svn~166';
my $dep5_last_overhaul         = '0+svn~148';
my %dep5_renamed_fields        = (
    'format-specification' => 'format',
    'maintainer'           => 'upstream-contact',
    'upstream-maintainer'  => 'upstream-contact',
    'contact'              => 'upstream-contact',
    'name'                 => 'upstream-name',
);

sub run {
    my (undef, undef, $info) = @_;
    my $copyright_filename = $info->debfiles('copyright');

    if (-l $copyright_filename) {
        tag 'debian-copyright-is-symlink';
        return;
    }

    if (not -f $copyright_filename) {
        my @pkgs = $info->binaries;
        tag 'no-debian-copyright';
        $copyright_filename = undef;
        if (scalar @pkgs == 1) {

            # If debian/copyright doesn't exist, and the only a single
            # binary package is built, there's a good chance that the
            # copyright file is available as
            # debian/<pkgname>.copyright.
            $copyright_filename = $info->debfiles($pkgs[0] . '.copyright');
            if (not -f $copyright_filename or -l $copyright_filename) {
                $copyright_filename = undef;
            }
        }
    }

    if (defined($copyright_filename)) {
        _check_dep5_copyright($info, $copyright_filename);
    }
    return;
}

# Note that we allow people to use "https://" even the
# policy says it must be "http://".  It might be
# pedantically wrong, but it is not worth arguing over On
# the plus side, it gives security to people blindly
# copy-wasting the URLs using "https://".
# return undef is not dep5 and '' if unknown version
sub _find_dep5_version {
    my ($original_uri) = @_;
    my $uri = $original_uri;
    my $version;

    if ($uri =~ m,\b(?:rev=REVISION|VERSIONED_FORMAT_URL)\b,) {
        tag 'boilerplate-copyright-format-uri', $uri;
        return;
    }

    if (
        $uri =~ s{ https?://wiki\.debian\.org/
                                Proposals/CopyrightFormat\b}{}xsm
      ){
        $version = '0~wiki';
        $uri =~ m,^\?action=recall&rev=(\d+)$,
          and $version = "$version~$1";
        return $version;
    }
    if ($uri =~ m,^https?://dep\.debian\.net/deps/dep5/?$,) {
        $version = '0+svn';
        return $version;
    }
    if (
        $uri =~ s{\A https?://svn\.debian\.org/
                                  wsvn/dep/web/deps/dep5\.mdwn\b}{}xsm
      ){
        $version = '0+svn';
        $uri =~ m,^\?(?:\S+[&;])?rev=(\d+)(?:[&;]\S+)?$,
          and $version = "$version~$1";
        return $version;
    }
    if (
        $uri =~ s{ \A https?://(?:svn|anonscm)\.debian\.org/
                                    viewvc/dep/web/deps/dep5\.mdwn\b}{}xsm
      ){
        $version = '0+svn';
        $uri =~ m{\A \? (?:\S+[&;])?
                             (?:pathrev|revision|rev)=(\d+)(?:[&;]\S+)?
                          \Z}xsm
          and $version = "$version~$1";
        return $version;
    }
    if (
        $uri =~ m{ \A
                       https?://www\.debian\.org/doc/
                       (?:packaging-manuals/)?copyright-format/(\d+\.\d+)/?
                   \Z}xsm
      ){
        $version = $1;
        return $version;
    }

    tag 'unknown-copyright-format-uri', $original_uri;
    return;
}

sub _check_dep5_copyright {
    my ($info, $copyright_filename) = @_;
    my $contents = slurp_entire_file($copyright_filename);
    my (@dep5, @lines);

    if (
        $contents !~ m{
               (?:^ | \n)
               (?i: format(?: [:] |[-\s]spec) )
               (?: . | \n\s+ )*
               (?: /dep[5s]?\b | \bDEP-?5\b
                 | [Mm]achine-readable\s(?:license|copyright)
                 | /copyright-format/ | CopyrightFormat
                 | VERSIONED_FORMAT_URL
               ) }x
      ){
        tag 'no-dep5-copyright';
        return;
    }

    # Before trying to parse the copyright as Debian control file, try to
    # determine the format URI.
    my $first_para = $contents;
    $first_para =~ s,^#.*,,mg;
    $first_para =~ s,[ \t]+$,,mg;
    $first_para =~ s,^\n+,,g;
    $first_para =~ s,\n\n.*,\n,s;    #;; hi emacs
    $first_para =~ s,\n?[ \t]+, ,g;
    $first_para =~ m,^Format(?:-Specification)?:\s*(.*),mi;
    my $uri = $1;
    $uri =~ s/^([^#\s]+)#/$1/
      if defined $uri;               # strip fragment identifier

    if (!defined $uri) {
        tag 'unknown-copyright-format-uri';
        return;
    }

    my $version = _find_dep5_version($uri);

    return if !defined($version);
    if ($version =~ m,wiki,) {
        tag 'wiki-copyright-format-uri', $uri;
    }elsif ($version =~ m,svn$,) {
        tag 'unversioned-copyright-format-uri', $uri;
    }elsif (versions_compare $version, '<<', $dep5_last_normative_change) {
        tag 'out-of-date-copyright-format-uri', $uri;
    }

    if (versions_compare $version, '<<', $dep5_last_overhaul) {
        return;
    }

    # We are reasonably certain that we're dealing
    # with an up-to-date DEP-5 format. Let's try to do
    # more strict checks.
    eval {
        open(my $fd, '<', \$contents);
        @dep5 = parse_dpkg_control($fd, 0, \@lines);
        close($fd);
    };
    if ($@) {
        chomp $@;
        $@ =~ s/^syntax error at //;
        tag 'syntax-error-in-dep5-copyright', $@;
        return;
    }

    return if (!@dep5);

    _parse_dep5($info, \@dep5, \@lines);

    return;
}

sub _parse_dep5 {
    my ($info, $dep5ref, $linesref) = @_;
    my @dep5       = @$dep5ref;
    my @lines      = @$linesref;
    my $first_para = shift @dep5;
    my %standalone_licenses;
    my %required_standalone_licenses;
    my %short_licenses_seen;

    for my $field (keys %{$first_para}) {
        my $renamed_to = $dep5_renamed_fields{$field};
        if (defined $renamed_to) {
            tag 'obsolete-field-in-dep5-copyright', $field,
              $renamed_to, "(line $lines[0]{$field})";
        }
    }
    if (    not defined $first_para->{'format'}
        and not defined $first_para->{'format-specification'}){
        tag 'missing-field-in-dep5-copyright', 'format',
          "(line $lines[0]{'format'})";
    }

    my ($found_license_header, undef, undef, @short_licenses_header)
      =parse_license($first_para->{'license'}, 1);
    for my $short_license (@short_licenses_header) {
        $required_standalone_licenses{$short_license} = 1;
        $short_licenses_seen{$short_license}          = 1;
    }

    my (@commas_in_files, %file_para_coverage);
    my %file_coverage = map { $_ => 0 } get_all_files($info);
    my $i = 0;
    my $current_line = 0;
    my $commas_in_files = any { m/,/xsm } $info->sorted_index;
    for my $para (@dep5) {
        $i++;
        $current_line = $lines[$i]{'START-OF-PARAGRAPH'};
        my ($files_fname, $files)
          =get_field($para, 'files', $lines[$i]);
        my $license   = get_field($para, 'license',   $lines[$i]);
        my $copyright = get_field($para, 'copyright', $lines[$i]);

        if (    not defined $files
            and defined $license
            and defined $copyright){
            tag 'ambiguous-paragraph-in-dep5-copyright',
              "paragraph at line $current_line";

            # If it is the first paragraph, it might be an instance of
            # the (no-longer) optional "first Files-field".
            $files = '*' if $i == 1;
        }

        if (defined $license and not defined $files) {
            my ($found_license, $full_license, $short_license,@short_licenses)
              = parse_license($license, $current_line);

            # Standalone license paragraph
            if (defined($short_license) and $short_license =~ /\s++\|\s++/) {
                tag 'pipe-symbol-used-as-license-disjunction', $short_license,
                  "(paragraph at line $current_line)";
            }
            if (not defined($full_license)) {
                tag 'missing-license-text-in-dep5-copyright', $license,
                  "(paragraph at line $current_line)";
            }else {
                for (@short_licenses) {
                    $standalone_licenses{$_}             = $i;
                    $short_licenses_seen{$_} = $i;
                }
            }
        }elsif (defined $files) {
            if ($files =~ m/\A\s*\Z/mxs) {
                tag 'missing-field-in-dep5-copyright', 'files',
                  '(empty field,',
                  "paragraph at line $current_line)";
            }

            # Files paragraph
            if (not @commas_in_files and $files =~ /,/) {
                @commas_in_files = ($i, $files_fname);
            }

            # only attempt to evaluate globbing if commas could be legal
            if (not @commas_in_files or $commas_in_files) {
                my @wildcards = split /[\n\t ]+/, $files;
                for my $wildcard (@wildcards) {
                    $wildcard =~ s/^\s+|\s+$//g;
                    if ($wildcard eq '') {
                        next;
                    }
                    my ($regex, $wildcard_error)= wildcard_to_regex($wildcard);
                    if (defined $wildcard_error) {
                        tag 'invalid-escape-sequence-in-dep5-copyright',
                          substr($wildcard_error, 0, 2)
                          . " (paragraph at line $current_line)";
                        next;
                    }

                    my $used = 0;
                    $file_para_coverage{$current_line} = 0;
                    for my $srcfile (keys %file_coverage) {
                        if ($srcfile =~ $regex) {
                            $used = 1;
                            $file_coverage{$srcfile} = $current_line;
                            $file_para_coverage{$current_line} = 1;
                        }
                    }
                    if (not $used) {
                        tag 'wildcard-matches-nothing-in-dep5-copyright',
                          "$wildcard (paragraph at line $current_line)";
                    }
                }
            }

            my ($found_license, $full_license, $short_license, @short_licenses)
              = parse_license($license, $current_line);
            if (defined($short_license) and $short_license =~ /\s++\|\s++/) {
                tag 'pipe-symbol-used-as-license-disjunction', $short_license,
                  "(paragraph at line $current_line)";
            }
            if ($found_license) {
                for (@short_licenses) {
                    $short_licenses_seen{$_} = $i;
                    if (not defined($full_license)) {
                        $required_standalone_licenses{$_} = $i;
                    }
                }
            }else {
                tag 'missing-field-in-dep5-copyright', 'license',
                  "(paragraph at line $current_line)";
            }

            if (not defined $copyright) {
                tag 'missing-field-in-dep5-copyright', 'copyright',
                  "(paragraph at line $current_line)";
            }elsif ($copyright =~ m/\A\s*\Z/mxs) {
                tag 'missing-field-in-dep5-copyright', 'copyright',
                  '(empty field,',
                  "paragraph at line $current_line)";
            }

        }else {
            tag 'unknown-paragraph-in-dep5-copyright', 'paragraph at line',
              $current_line;
        }
    }
    if (@commas_in_files and not $commas_in_files) {
        my ($paragraph_no, $field_name) = @commas_in_files;
        tag 'comma-separated-files-in-dep5-copyright',
          'paragraph at line',
          $lines[$paragraph_no]{$field_name};
    } else {
        foreach my $srcfile (sort keys %file_coverage) {
            my $i = $file_coverage{$srcfile};
            if ($srcfile =~ '^\.pc/') {
                next;
            }
            if (not $i) {
                tag 'file-without-copyright-information', $srcfile;
            }
            delete $file_para_coverage{$i};
        }
        foreach my $i (sort keys %file_para_coverage) {
            tag 'unused-file-paragraph-in-dep5-copyright',
              "paragraph at line $i";
        }
    }
    while ((my $license, $i) = each %required_standalone_licenses) {
        if (not defined $standalone_licenses{$license}) {
            tag 'missing-license-paragraph-in-dep5-copyright', $license,
              "(paragraph at line $lines[$i]{'START-OF-PARAGRAPH'})";
        }
    }
    while ((my $license, $i) = each %standalone_licenses) {
        if (not defined $required_standalone_licenses{$license}) {
            tag 'unused-license-paragraph-in-dep5-copyright', $license,
              "(paragraph at line $lines[$i]{'START-OF-PARAGRAPH'})";
        }
    }
  LICENSE:
    while ((my $license, $i) = each %short_licenses_seen) {
        if ($license =~ m,\s,) {
            if($license =~ m,[^ ]+ \s+ with \s+ (.*),x) {
                my $exceptiontext = $1;
                unless ($exceptiontext =~ m,[^ ]+ \s+ exception,x) {
                    tag 'bad-exception-format-in-dep5-copyright', $license,
                      "(paragraph at line $lines[$i]{'START-OF-PARAGRAPH'})";
                }
            }else {
                tag 'space-in-std-shortname-in-dep5-copyright', $license,
                  "(paragraph at line $lines[$i]{'START-OF-PARAGRAPH'})";
            }
        }
        foreach my $bad_short_license ($BAD_SHORT_LICENSES->all) {
            my $value = $BAD_SHORT_LICENSES->value($bad_short_license);
            my $regex = $value->{'regex'};
            if ($license =~ m/$regex/x) {
                tag $value->{'tag'}, $license,
                  "(paragraph at line $lines[$i]{'START-OF-PARAGRAPH'})";
                next LICENSE;
            }
        }
    }
    return;
}

# parse a license block
sub parse_license {
    my ($license_block, $line) = @_;
    my $full_license  = undef;
    my $short_license = undef;
    return 0 unless defined($license_block);
    if ($license_block =~ m/\n/) {
        ($short_license, $full_license) = split /\n/, $license_block, 2;
    }else {
        $short_license = $license_block;
    }
    $short_license =~ s/[(),]//;
    if ($short_license =~ m/\A\s*\Z/) {
        tag 'empty-short-license-in-dep5-copyright',
          "(paragraph at line $line)";
        return 1, $full_license, '';
    }
    $short_license = lc($short_license);
    my @licenses
      =map { "\L$_" } (split(m/\s++(?:and|or)\s++/, $short_license));
    return 1, $full_license, $short_license, @licenses;
}

sub get_field {
    my ($para, $field, $line) = @_;
    if (exists $para->{$field}) {
        return $para->{$field} unless wantarray;
        return ($field, $para->{$field});
    }

    # Fall back to a "likely misspelling" of the field.
    foreach my $f (sort keys %$para) {
        if (distance($field, $f) < 3) {
            tag 'field-name-typo-in-dep5-copyright', $f, '->', $field,
              "(line $line->{$f})";
            return $para->{$f} unless wantarray;
            return ($f, $para->{$f});
        }
    }
    return;
}

sub wildcard_to_regex {
    my ($regex) = @_;
    $regex =~ s,^\./+,,;
    $regex =~ s,//+,/,g;
    my $error;
    eval {
        $regex =~ s{
            (\*) |
            (\?) |
            ([^*?\\]+) |
            (\\[\\*?]) |
            (.+)
        }{
            if (defined $1) {
                '.*';
            } elsif (defined $2) {
                '.'
            } elsif (defined $3) {
                quotemeta($3);
            } elsif (defined $4) {
                $4;
            } else {
                $error = $5;
                die;
            }
        }egx;
    };
    if ($@) {
        return (undef, $error);
    } else {
        return (qr/^(?:$regex)$/, undef);
    }
}

sub get_all_files {
    my ($info) = @_;
    # files with a trailing slash are directories
    my @all_files = grep { not m,/$, } $info->sorted_index;
    my $debfiles_root = $info->debfiles;
    File::Find::find({
            wanted => sub {
                return unless -f $_;
                my $dir = $File::Find::dir;
                $dir =~ s,^\Q$debfiles_root\E(?:(?=/)|$),debian,;
                push @all_files, "$dir/$_";
            },
        },
        $debfiles_root
    );
    return @all_files;
}

1;

# Local Variables:
# indent-tabs-mode: nil
# cperl-indent-level: 4
# End:
# vim: syntax=perl sw=4 sts=4 sr et

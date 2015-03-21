# description -- lintian check script -*- perl -*-

# Copyright (C) 1998 Christian Schwarz
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

package Lintian::description;
use strict;
use warnings;
use autodie;

# Compared to a lower-case string, so it must be all lower-case
use constant DH_MAKE_PERL_TEMPLATE => 'this description was'
  . ' automagically extracted from the module by dh-make-perl';

use Encode qw(decode);

use Lintian::Check qw(check_spelling check_spelling_picky);
use Lintian::Tags qw(tag);
use Lintian::Util qw(strip);

sub run {
    my ($pkg, $type, $info, undef, $group) = @_;
    my $tabs = 0;
    my $lines = 0;
    my $template = 0;
    my $unindented_list = 0;
    my $synopsis;
    my $description;

    # description?
    my $full_description = $info->field('description');
    unless (defined $full_description) {
        tag 'package-has-no-description';
        return;
    }

    $full_description =~ m/^([^\n]*)\n(.*)$/s;
    ($synopsis, $description) = ($1, $2);
    unless (defined $synopsis) {
        # The first line will always be completely stripped but
        # continuations may have leading whitespace.  Therefore we
        # have to strip $full_description to restore this property,
        # when we use it as a fall-back value of the synopsis.
        $synopsis = strip($full_description);
        $description = '';
    }

    $description = '' unless defined($description);

    if ($synopsis =~ m/^\s*$/) {
        tag 'description-synopsis-is-empty';
    } else {
        if ($synopsis =~ m/^\Q$pkg\E\b/i) {
            tag 'description-starts-with-package-name';
        }
        if ($synopsis =~ m/^(an?|the)\s/i) {
            tag 'description-synopsis-starts-with-article';
        }
        if ($synopsis =~ m/(?<!etc)\.\s*$/i) {
            tag 'description-synopsis-might-not-be-phrased-properly';
        }
        if ($synopsis =~ m/\t/) {
            tag 'description-contains-tabs' unless $tabs++;
        }
        if ($synopsis =~ m/^missing\s*$/i) {
            tag 'description-is-debmake-template' unless $template++;
        } elsif ($synopsis =~ m/<insert up to 60 chars description>/) {
            tag 'description-is-dh_make-template' unless $template++;
        }
        if ($synopsis !~ m/\s/) {
            tag 'description-too-short';
        }
        my $pkg_fmt = lc $pkg;
        my $synopsis_fmt = lc $synopsis;
        # made a fuzzy match
        $pkg_fmt =~ s,[-_], ,g;
        $synopsis_fmt =~ s,[-_/\\], ,g;
        $synopsis_fmt =~ s,\s+, ,g;
        if ($pkg_fmt eq $synopsis_fmt) {
            tag 'description-is-pkg-name', $synopsis;
        }

        # We have to decode into UTF-8 to get the right length for the
        # length check.  If the changelog uses a non-UTF-8 encoding,
        # this will mangle it, but it doesn't matter for the length
        # check.
        if (length(decode('utf-8', $synopsis)) >= 80) {
            tag 'description-too-long';
        }
    }

    my $flagged_homepage;
    foreach (split /\n/, $description) {
        next if m/^ \.\s*$/o;

        if ($lines == 0) {
            my $firstline = lc $_;
            my $lsyn = lc $synopsis;
            if ($firstline =~ /^\Q$lsyn\E$/) {
                tag 'description-synopsis-is-duplicated';
            } else {
                $firstline =~ s/[^a-zA-Z0-9]+//g;
                $lsyn =~ s/[^a-zA-Z0-9]+//g;
                if ($firstline eq $lsyn) {
                    tag 'description-synopsis-is-duplicated';
                }
            }
        }

        $lines++;

        if (m/^ \.\s*\S/o) {
            tag 'description-contains-invalid-control-statement';
        } elsif (m/^ [\-\*]/o) {
       # Print it only the second time.  Just one is not enough to be sure that
       # it's a list, and after the second there's no need to repeat it.
            tag 'possible-unindented-list-in-extended-description'
              if $unindented_list++ == 2;
        }

        if (m/\t/o) {
            tag 'description-contains-tabs' unless $tabs++;
        }

        if (m,^\s*Homepage: <?https?://,i) {
            tag 'description-contains-homepage';
            $flagged_homepage = 1;
        }

        if (index(lc($_), DH_MAKE_PERL_TEMPLATE) != -1) {
            tag 'description-contains-dh-make-perl-template';
        }

        # Check for duplicated words.  We want to catch "this this."
        # but not "ITU-T T.81", so compare non-whitespace sequences
        # rather than word characters but allow punctuation at the
        # end.
        #
        # We don't want to think ", ," or "a, a" is a duplicated word,
        # so require that a word start and end with a word character.
        #
        # We replace text that is quoted with ' "" '.  The assumption
        # is that quoted words are "okay" and blindly removing them
        # causes false positives with text like "'a' or 'b' or 'c'".
        my $stripped = $_;
        $stripped =~ s,(["'])(.*?)(\1), "" ,g;
        while ($stripped
            =~ m%(?:\s|^)((\w(?:\S*\w)?)(\s+(\2))+)(?:[\).,?!:;\s]|\z)%i) {
            my $words = $1;
            $stripped =~ s/\Q$words//;
            tag 'description-contains-duplicated-word', $words;
        }

        my $first_person = $_;
        while ($first_person
            =~ m/(?:^|\s)(I|[Mm]y|[Oo]urs?|mine|myself|me|us|[Ww]e)(?:$|\s)/) {
            my $word = $1;
            $first_person =~ s/\Q$word//;
            tag 'using-first-person-in-description', "line $lines: $word";
        }

        if ($lines == 1) {
            # checks for the first line of the extended description:
            if (m/^ \s/o) {
                tag 'description-starts-with-leading-spaces';
            }
            if (m/^\s*missing\s*$/oi) {
                tag 'description-is-debmake-template' unless $template++;
            } elsif (m/<insert long description, indented with spaces>/) {
                tag 'description-is-dh_make-template' unless $template++;
            }
        }

        if (length(decode('utf-8', $_)) > 80) {
            tag 'extended-description-line-too-long';
        }
    }

    if ($type ne 'udeb') {
        if ($lines == 0) {
            tag 'extended-description-is-empty';
        } elsif ($lines <= 2 and not $synopsis =~ /(?:dummy|transition)/i) {
            tag 'extended-description-is-probably-too-short'
              unless $info->is_pkg_class('any-meta')
              or $pkg =~ m{-dbg\Z}xsm;
        } elsif ($description =~ /^ \.\s*\n|\n \.\s*\n \.\s*\n|\n \.\s*\n?$/) {
            tag 'extended-description-contains-empty-paragraph';
        }
    }

    # Check for a package homepage in the description and no Homepage
    # field.  This is less accurate and more of a guess than looking
    # for the old Homepage: convention in the body.
    unless ($info->field('homepage') or $flagged_homepage) {
        if (
            $description =~ /homepage|webpage|website|url|upstream|web\s+site
                         |home\s+page|further\s+information|more\s+info
                         |official\s+site|project\s+home/xi
            and $description =~ m,\b(https?://[a-z0-9][^>\s]+),i
          ) {
            tag 'description-possibly-contains-homepage', $1;
        } elsif ($description =~ m,\b(https?://[a-z0-9][^>\s]+)>?\.?\s*\z,i) {
            tag 'description-possibly-contains-homepage', $1;
        }
    }

    if ($synopsis) {
        check_spelling('spelling-error-in-description-synopsis',
            $synopsis,undef, $group->info->spelling_exceptions);
        check_spelling_picky('capitalization-error-in-description-synopsis',
            $synopsis);
    }

    if ($description) {
        check_spelling('spelling-error-in-description',
            $description,undef, $group->info->spelling_exceptions);
        check_spelling_picky('capitalization-error-in-description',
            $description);
    }

    return;
}

1;

# Local Variables:
# indent-tabs-mode: nil
# cperl-indent-level: 4
# End:
# vim: syntax=perl sw=4 sts=4 sr et

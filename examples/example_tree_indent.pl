#!/usr/bin/env perl

use strict;
use warnings;

use CSS::Struct::Output::Indent;
use Tags::HTML::Tree;
use Tags::HTML::Page::Begin;
use Tags::HTML::Page::End;
use Tags::Output::Indent;
use Tree;
use Unicode::UTF8 qw(decode_utf8 encode_utf8);

my $css = CSS::Struct::Output::Indent->new;
my $tags = Tags::Output::Indent->new(
        'preserved' => ['style', 'script'],
        'xml' => 1,
);

my $tags_tree = Tags::HTML::Tree->new(
        'css' => $css,
        'tags' => $tags,
);
$tags_tree->prepare;

my $begin = Tags::HTML::Page::Begin->new(
        'author' => decode_utf8('Michal Josef Špaček'),
        'css' => $css,
        'generator' => 'Tags::HTML::Tree',
        'lang' => {
                'title' => 'Tree',
        },
        'script_js' => $tags_tree->script_js,
        'tags' => $tags,
);
my $end = Tags::HTML::Page::End->new(
        'tags' => $tags,
);

# Example tree object.
my $tree = Tree->new('Root');
$tree->meta({'uid' => 0});
my $count = 0;
my %node;
foreach my $node_string (qw/H I J K L M N O P Q/) {
         $node{$node_string} = Tree->new($node_string);
         $node{$node_string}->meta({'uid' => ++$count});
}
$tree->add_child($node{'H'});
$node{'H'}->add_child($node{'I'});
$node{'I'}->add_child($node{'J'});
$node{'H'}->add_child($node{'K'});
$node{'H'}->add_child($node{'L'});
$tree->add_child($node{'M'});
$tree->add_child($node{'N'});
$node{'N'}->add_child($node{'O'});
$node{'O'}->add_child($node{'P'});
$node{'P'}->add_child($node{'Q'});

# Init.
$tags_tree->init($tree);

# Process CSS.
$tags_tree->process_css;

# Process HTML.
$begin->process;
$tags_tree->process;
$end->process;

# Print out.
print encode_utf8($tags->flush);

# Output:
# TODO
package Tags::HTML::Tree;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use English;
use Error::Pure qw(err);
use Mo::utils 0.01 qw(check_required);
use Mo::utils::CSS 0.02 qw(check_css_class);
use Scalar::Util qw(blessed);

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['css_class'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# CSS class.
	$self->{'css_class'} = 'changes';

	# Process params.
	set_params($self, @{$object_params_ar});

	check_required($self, 'css_class');
	check_css_class($self, 'css_class');

	# Object.
	return $self;
}

sub _cleanup {
	my $self = shift;

	delete $self->{'_tree'};

	return;
}

sub _init {
	my ($self, $tree) = @_;

	if (! defined $tree
		|| ! blessed($tree)
		|| ! $tree->isa('Tree')) {

		err "Data object must be a 'Tree' instance.";
	}

	$self->{'_tree'} = $tree;

	return;
}

# Process 'Tags'.
sub _process {
	my $self = shift;

	if (! exists $self->{'_tree'}) {
		return;
	}

	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', $self->{'css_class'}],
	);
	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	if (! exists $self->{'_tree'}) {
		return;
	}

	$self->{'css'}->put(
		['s', '.'.$self->{'css_class'}],
		['e'],

		['s', '.'.$self->{'css_class'}.' .version'],
		['d', 'border-bottom', '2px solid #eee'],
		['d', 'padding-bottom', '20px'],
		['d', 'margin-bottom', '20px'],
		['e'],
	);

	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Tags::HTML::Tree - Tags helper for Tree.

=head1 SYNOPSIS

 use Tags::HTML::Tree;

 my $obj = Tags::HTML::Tree->new(%params);
 $obj->cleanup;
 $obj->init($tree);
 $obj->prepare;
 $obj->process;
 $obj->process_css;

=head1 METHODS

=head2 C<new>

 my $obj = Tags::HTML::Tree->new(%params);

Constructor.

=over 8

=item * C<css>

'L<CSS::Struct::Output>' object for L<process_css> processing.

Default value is undef.

=item * C<no_css>

No CSS support flag.
If this flag is set to 1, L<process_css()> returns undef.

Default value is 0.

=item * C<tags>

'L<Tags::Output>' object.

Default value is undef.

=back

=head2 C<cleanup>

 $obj->cleanup;

Cleanup module to init state.

Returns undef.

=head2 C<init>

 $obj->init($changes);

Set L<CPAN::Changes> instance defined by C<$changes> to object.

Minimal version of L<CPAN::Changes> is 0.500002.

Returns undef.

=head2 C<prepare>

 $obj->prepare;

Process initialization before page run.

Do nothing in this module.

Returns undef.

=head2 C<process>

 $obj->process;

Process L<Tags> structure for output with message.

Returns undef.

=head2 C<process_css>

 $obj->process_css;

Process L<CSS::Struct> structure for output.

Returns undef.

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.
         From Tags::HTML::new():
                 Parameter 'tags' must be a 'Tags::Output::*' class.
         Parameter 'css_class' is required.

 init():
         Data object must be a 'Tree' instance.

 process():
         From Tags::HTML::process():
                 Parameter 'tags' isn't defined.

=head1 EXAMPLE1

=for comment filename=example_tree_raw.pl

 use strict;
 use warnings;

 use CSS::Struct::Output::Raw;
 use Tags::HTML::Tree;
 use Tags::HTML::Page::Begin;
 use Tags::HTML::Page::End;
 use Tags::Output::Raw;
 use Unicode::UTF8 qw(decode_utf8 encode_utf8);

 my $css = CSS::Struct::Output::Raw->new;
 my $tags = Tags::Output::Raw->new(
         'xml' => 1,
 );

 my $begin = Tags::HTML::Page::Begin->new(
         'author' => decode_utf8('Michal Josef Špaček'),
         'css' => $css,
         'generator' => 'Tags::HTML::Tree',
         'lang' => {
                 'title' => 'Tree',
         },
         'tags' => $tags,
 );
 my $end = Tags::HTML::Page::End->new(
         'tags' => $tags,
 );
 my $obj = Tags::HTML::Tree->new(
         'css' => $css,
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
 $obj->init($tree);

 # Process CSS.
 $obj->process_css;

 # Process HTML.
 $begin->process;
 $obj->process;
 $end->process;

 # Print out.
 print encode_utf8($tags->flush);

 # Output:
 # TODO

=head1 EXAMPLE2

=for comment filename=example_tree_indent.pl

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
         'preserved' => ['style'],
         'xml' => 1,
 );

 my $begin = Tags::HTML::Page::Begin->new(
         'author' => decode_utf8('Michal Josef Špaček'),
         'css' => $css,
         'generator' => 'Tags::HTML::Tree',
         'lang' => {
                 'title' => 'Tree',
         },
         'tags' => $tags,
 );
 my $end = Tags::HTML::Page::End->new(
         'tags' => $tags,
 );

 my $obj = Tags::HTML::Tree->new(
         'css' => $css,
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
 $obj->init($tree);

 # Process CSS.
 $obj->process_css;

 # Process HTML.
 $begin->process;
 $obj->process;
 $end->process;

 # Print out.
 print encode_utf8($tags->flush);

 # Output:
 # TODO

=head1 DEPENDENCIES

# TODO
L<Class::Utils>,
L<CPAN::Version>,
L<English>,
L<Error::Pure>,
L<Scalar::Util>,
L<Tags::HTML>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Tags-HTML-Tree>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2024 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut

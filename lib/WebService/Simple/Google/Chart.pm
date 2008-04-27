package WebService::Simple::Google::Chart;
use strict;
use warnings;

our $VERSION = '0.01';

use base qw(WebService::Simple);
__PACKAGE__->config(
    base_url      => "http://chart.apis.google.com/chart",
    request_param => {},
);

sub get_url {
    my ( $self, $param ) = @_;
    my ( @label, @value, $data, $total_count );
    $data        = $param->{data};
    $total_count = 0;
    map { $total_count += $data->{$_} } keys %$data;
    foreach my $key ( keys %{ $param->{data} } ) {
        push( @label, $key );
        my $percent = int( $param->{data}->{$key} / $total_count * 100 + 0.5 );
        push( @value, $percent );
    }
    $self->{request_param}->{chs} = $param->{size};
    $self->{request_param}->{cht} = $param->{type};
    $self->{request_param}->{chl} = join( "|", @label );
    $self->{request_param}->{chd} = "t:" . join( ",", @value );
    return $self->request_url( $self->{request_param} );
}

sub render_to_file {
    my $self  = shift;
    my $param = shift;
    my $filename;
    if ( ref $param eq 'Hash' ) {
        $self->{request_param} = $param;
    }
    else {
        $filename = $param;
    }
    $self->SUPER::get( $self->{request_param}, ":content_file" => $filename );
}

sub _total_value {
    my ( $self, $data ) = @_;
    my @values;
    map { push( @values, $data->{$_} ) } keys %$data;
    @values = sort { $b <=> int $a } @values;
    return $values[0];
}

1;

=head1 NAME

WebService::Simple::Google::Chart - Get Google Chart URL and File

=head1 SYNOPSIS

  use WebService::Simple::Google::Chart;

  my $chart = WebService::Simple::Google::Chart->new;
  my $data  = { foo => 200, bar => 130, hoge => 70 };
  my $url   = $chart->get_url(
      {
          size => "250x100",
          type => "p3",
          data => $data,
      }
  );
  print $url;
  $chart->render_to_file("foo.png");


=head1 DESCRIPTION

=head1 METHOS

=head2 get_url

=head2 render_to_file

=head1 AUTHOR

Yusuke Wada <yusuke@kamawada.com>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

1;

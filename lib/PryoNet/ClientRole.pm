package PryoNet::ClientRole;

# VERSION

use IO::Async::Loop;

{    # preload these to avoid frame drops
    use IO::Async::Resolver;
    use IO::Async::Internals::Connector;
    use IO::Async::Future;
}

use Moo::Role;

has tcp => ( is => 'rw' );

sub connect {
    my ( $self, $host, $tcp_port ) = @_;

    $self->loop->connect(
        host             => $host,
        service          => $tcp_port,
        socktype         => "stream",
        on_stream        => $self->curry::on_accept,
        on_resolve_error => sub { die "Cannot resolve - $_[0]"; },
        on_connect_error => sub { die "Cannot connect"; },
    );

    return;
}

sub on_accept {
    my ( $self, $stream ) = @_;
    $stream->configure(
        on_read   => $self->curry::on_read( $self ),
        autoflush => 1,
    );
    $self->loop->add( $stream );
    $self->tcp( $stream );
    return;
}

1;

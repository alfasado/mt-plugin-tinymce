package TinyMCE::Plugin;

our $tinymce = MT->component( 'TinyMCE' );

sub _set_editor_prefs {
    my ( $cb, $app, $param ) = @_;
    my $tmpl_dir = File::Spec->catdir( $tinymce->path, 'alt-tmpl' );
    $app->config( 'AltTemplatePath', $tmpl_dir );
    my $static_path = $app->static_path;
    my $blog = $app->blog;
    my $get_from = 'blog:'. $blog->id;
    my $editor_style_css = $tinymce->get_config_value( 'editor_style_css', $get_from );
    $editor_style_css = $tinymce->get_config_value( 'editor_style_css' ) unless $editor_style_css;
    my %args = ( blog => $app->blog );
    $editor_style_css = build_tmpl( $app, $editor_style_css, \%args );
    $param->{ 'editor_style_css' } = $editor_style_css;
    $param->{ 'theme_advanced_buttons1' } = $tinymce->get_config_value( 'theme_advanced_buttons1' );
    $param->{ 'theme_advanced_buttons2' } = $tinymce->get_config_value( 'theme_advanced_buttons2' );
    $param->{ 'theme_advanced_buttons3' } = $tinymce->get_config_value( 'theme_advanced_buttons3' );
    $param->{ 'theme_advanced_buttons4' } = $tinymce->get_config_value( 'theme_advanced_buttons4' );
    $param->{ 'theme_advanced_buttons5' } = $tinymce->get_config_value( 'theme_advanced_buttons5' );
    $param->{ 'lang' } = $app->blog->language;
    $param->{ 'tinymce'  } = 1;
    $param->{ 'editor_skin'  } = $tinymce->get_config_value( 'editor_skin' );
}

sub build_tmpl {
    my ( $app, $tmpl, $args, $params ) = @_;
    if ( ( ref $tmpl ) eq 'MT::Template' ) {
        $tmpl = $tmpl->text;
    }
    $tmpl = $app->translate_templatized( $tmpl );
    require MT::Template;
    require MT::Builder;
    require MT::Template::Context;
    my $ctx = MT::Template::Context->new;
    my $blog = $args->{ blog };
    my $entry = $args->{ entry };
    my $category = $args->{ category };
    if ( (! $blog ) && ( $entry ) ) {
        $blog = $entry->blog;
    }
    if ( (! $blog ) && ( $category ) ) {
        $blog = MT::Blog->load( $category->blog_id );
    }
    my $author = $args->{ author };
    my $start = $args->{ start };
    my $end = $args->{ end };
    $ctx->stash( 'blog', $blog );
    $ctx->stash( 'blog_id', $blog->id ) if $blog;
    $ctx->stash( 'entry', $entry );
    $ctx->stash( 'page', $entry );
    $ctx->stash( 'category', $category );
    $ctx->stash( 'category_id', $category->id ) if $category;
    $ctx->stash( 'author', $author );
    if ( $start && $end ) {
        if ( ( valid_ts( $start ) ) && ( valid_ts( $end ) ) ) {
            $ctx->{ current_timestamp } = $start;
            $ctx->{ current_timestamp_end } = $end;
        }
    }
    for my $stash ( keys %$args ) {
        if (! $ctx->stash( $stash ) ) {
            if ( ( $stash ne 'start' ) && ( $stash ne 'end' ) ) {
                $ctx->stash( $stash, $args->{ $stash } );
            }
        }
    }
    for my $key ( keys %$params ) {
        $ctx->{ __stash }->{ vars }->{ $key } = $params->{ $key };
    }
    if ( is_application( $app ) ) {
        $ctx->{ __stash }->{ vars }->{ magic_token } = $app->current_magic if $app->user;
    }
    my $build = MT::Builder->new;
    my $tokens = $build->compile( $ctx, $tmpl )
        or return $app->error( $app->translate(
            "Parse error: [_1]", $build->errstr ) );
    defined( my $html = $build->build( $ctx, $tokens ) )
        or return $app->error( $app->translate(
            "Build error: [_1]", $build->errstr ) );
    unless ( MT->version_number < 5 ) {
        $html = utf8_on( $html );
    }
    return $html;
}

sub is_application { goto &if_application }

sub if_application {
    my $app = shift || MT->instance();
    return (ref $app) =~ /^MT::App::/ ? 1 : 0;
}

sub utf8_on {
    my $text = shift;
    if (! Encode::is_utf8( $text ) ) {
        Encode::_utf8_on( $text );
    }
    return $text;
}

1;
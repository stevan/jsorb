#!/usr/bin/perl

use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/../lib";

use JSORB;
use JSORB::Dispatcher::Path;
use JSORB::Server::Simple;

use Forest;
use Forest::Tree;
use Forest::Tree::Loader::SimpleUIDLoader;
use Forest::Tree::Indexer::SimpleUIDIndexer;

my $index;
{
    my $data = [
        { node => '1.0',   uid => 1,  parent_uid => 0 },
        { node => '1.1',   uid => 2,  parent_uid => 1 },
        { node => '1.2',   uid => 3,  parent_uid => 1 },
        { node => '1.2.1', uid => 4,  parent_uid => 3 },
        { node => '2.0',   uid => 5,  parent_uid => 0 },
        { node => '2.1',   uid => 6,  parent_uid => 5 },
        { node => '3.0',   uid => 7,  parent_uid => 0 },
        { node => '4.0',   uid => 8,  parent_uid => 0 },
        { node => '4.1',   uid => 9,  parent_uid => 8 },
        { node => '4.1.1', uid => 10, parent_uid => 9 },
    ];
    my $loader = Forest::Tree::Loader::SimpleUIDLoader->new;
    $loader->load($data);
    $index = Forest::Tree::Indexer::SimpleUIDIndexer->new(tree => $loader->tree);
    $index->build_index;
}

my $ns = JSORB::Namespace->new(
    name     => 'Forest',
    elements => [
        JSORB::Interface->new(
            name       => 'Tree',
            procedures => [
                JSORB::Procedure->new(
                    name  => 'get_tree_at',
                    body  => sub {
                        my ($uid) = @_;
                        my $tree = $index->get_tree_at($uid);
                        return +{
                            uid          => $tree->uid,
                            parent       => $tree->parent->uid,
                            node         => $tree->node,
                            has_children => ($tree->child_count ? 1 : 0),
                        };
                    },
                    spec  => [ 'Int' => 'HashRef' ],
                ),
            ]
        )
    ]
);

JSORB::Server::Simple->new(
    dispatcher => JSORB::Dispatcher::Path->new(
        namespace => $ns,
    )
)->run;

1;

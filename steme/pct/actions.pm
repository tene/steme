# $Id$

=begin comments

Steme::Grammar::Actions - ast transspecialations for Steme

This file contains the methods that are used by the parse grammar
to build the PAST representation of an Steme program.
Each method below corresponds to a rule in F<src/parser/grammar.pg>,
and is invoked at the point where C<{*}> appears in the rule,
with the current match object as the first argument.  If the
line containing C<{*}> also has a C<#= key> comment, then the
value of the comment is passed as the second argument to the method.

=end comments

class Steme::Grammar::Actions is HLL::Actions;

our @BLOCK;
our @PACKAGE;

INIT {
    our @BLOCK := Q:PIR { %r = new ['ResizablePMCArray'] };
    our @LIBRARY := Q:PIR { %r = new ['ResizablePMCArray'] };
    my $past := PAST::Block.new(
        :blocktype('declaration'),
        :hll('Steme'),
        :namespace([]),
    );
    @BLOCK.unshift($past);
    @LIBRARY.unshift($past);
}

method TOP($/) {
    our @BLOCK;
    our @LIBRARY;
    my $past := @BLOCK.shift();
    for $<statement> {
        $past.push( $_.ast );
    }
    make $past;
    @LIBRARY.shift();
}


method statement($/) {
    make $<form>.ast
}

method form($/) {
    if $<special> {
        make $<special>.ast;
    }
    else {
        make $<simple>.ast;
    }
}

method special:sym<if>($/) {
    make PAST::Op.new(
        $<cond>.ast,
        $<iftrue>.ast,
        $<iffalse>.ast,
        :pasttype('if'),
        :node($/),
    );
}

method special:sym<define>($/) {
    our @BLOCK;
    our @LIBRARY;
    my $lib := @LIBRARY[0];
    my @ns := $lib.namespace();
    my $var := $<var>.ast;
    $var.scope('package');
    $var.namespace(@ns);
    #$var.isdecl(1);
    my $val := $<val>.ast;
    $lib.symbol( $var.name, :scope('package') );
    make PAST::Op.new( $var, $val, :pasttype('bind'), :node($/) );
}

method special:sym<let>($/, $key?) {
    our @BLOCK;
    my $block;
    if $key eq 'begin' {
        $block := PAST::Block.new( :blocktype('immediate'), :node($/) );
        my $init := PAST::Stmts.new();
        for $<var> {
            my $var := $_.ast;
            my $val := $<val>.shift.ast;
            $var.scope('lexical');
            $var.isdecl(1);
            $block.symbol($var.name(), :scope('lexical'));
            $init.push( PAST::Op.new( $var, $val, :pasttype('bind')));
        }
        $block.unshift($init);
        @BLOCK.unshift($block);
    }
    else {
        my $stmts := PAST::Stmts.new();
        for $<statement> {
            $stmts.push( $_.ast );
        }
        $block := @BLOCK.shift();
        $block.push($stmts);
        make $block;
    }
}

method special:sym<lambda>($/, $key?) {
    our @BLOCK;
    my $block;
    if $key eq 'begin' {
        $block := PAST::Block.new( :blocktype('declaration'), :node($/) );
        my $init := PAST::Stmts.new();
        for $<var> {
            my $var := $_.ast;
            $var.scope('parameter');
            $var.isdecl(1);
            $block.symbol($var.name(), :scope('lexical'));
            $init.push($var);
        }
        $block.unshift($init);
        @BLOCK.unshift($block);
    }
    else {
        my $stmts := PAST::Stmts.new();
        for $<statement> {
            $stmts.push( $_.ast );
        }
        $block := @BLOCK.shift();
        $block.push($stmts);
        make $block;
    }
}

method special:sym<library>($/, $key?) {
    our @BLOCK;
    our @LIBRARY;
    my $block;
    my @ns := $<ns>;
    if $key eq 'begin' {
        $block := PAST::Block.new( :blocktype('immediate'), :namespace(@ns), :node($/) );
        @BLOCK.unshift($block);
        @LIBRARY.unshift($block);
    }
    else {
        my $stmts := PAST::Stmts.new();
        for $<statement> {
            $stmts.push( $_.ast );
        }
        $block := @BLOCK.shift();
        $block.push($stmts);
        make $block;
        @LIBRARY.shift();
    }
}

method special:sym<export>($/) {
    my $past := PAST::Op.new(
        :pasttype('call'),
        :name('export'),
        :node( $/ ),
        PAST::Val.new(:value(~$<ident>), :returns('String')),
    );
    make $past;
}

method special:sym<import>($/) {
    my $past := PAST::Stmts.new();
    for $<libs> {
        my $import := PAST::Op.new(
            :pasttype('call'),
            :name('import'),
            :node( $/ ),
        );
        for $_<ns> {
            $import.push(PAST::Val.new(:value(~$_), :returns('String'))),
        }
        $past.push($import);
    }
    make $past;
}

method special:sym<hllimport>($/) {
    my $past := PAST::Stmts.new();
    for $<libs> {
        my $ns := $_;
        my $import := PAST::Op.new(
            :pasttype('call'),
            :name('import'),
            :node( $/ ),
        );
        for $_<ns> {
            $import.push(PAST::Val.new(:value(~$_), :returns('String'))),
        }
        $import.push(PAST::Val.new(:value(~$_<hll>), :returns('String'), :named('hll')));
        $past.push($import);
    }
    make $past;
}

method simple($/) {
    my $cmd := $<cmd>.ast;
    my $past := PAST::Op.new(
        :pasttype('call'),
        :node( $/ ),
    );
    if ~$cmd.WHAT() eq 'PAST::Var()' && $cmd.scope() eq 'package' {
        $cmd := $cmd.name();
        $past.name($cmd);
    }
    else {
        $past.push($cmd);
    }
    for $<item> {
        $past.push( $_.ast );
    }
    make $past;
}

##  item:
method item:sym<symbol>($/) { make $<symbol>.ast; }
method item:sym<statement>($/) { make $<statement>.ast; }
method item:sym<integer>($/) { make $<integer>.ast; }
method item:sym<quote>($/) { make $<quote>.ast; }

method symbol($/) {
    our @BLOCK;
    my $scope := 'package';
    my $name := ~$<symbol>;
    for @BLOCK {
        if $_.symbol($name) && $scope eq 'package' {
            $scope := $_.symbol($name)<scope>;
        }
    }
    make PAST::Var.new(
        :name( $name ),
        :scope( $scope ),
        :node( $/ ),
    );
}


method integer($/) {
    make PAST::Val.new(
        :value( ~$/ ),
        :returns('Integer'),
        :node($/),
    );
}


method quote:sym<apos>($/) {
    make $<quote_EXPR>.ast;
}

method quote:sym<dblq>($/) {
    my $past := $<quote_EXPR>.ast;
    make $past;
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


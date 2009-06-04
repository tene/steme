# $Id$

=begin comments

Steme::Grammar::Actions - ast transformations for Steme

This file contains the methods that are used by the parse grammar
to build the PAST representation of an Steme program.
Each method below corresponds to a rule in F<src/parser/grammar.pg>,
and is invoked at the point where C<{*}> appears in the rule,
with the current match object as the first argument.  If the
line containing C<{*}> also has a C<#= key> comment, then the
value of the comment is passed as the second argument to the method.

=end comments

class Steme::Grammar::Actions;

method TOP($/, $key) {
    our @?BLOCK;
    our @?LIBRARY;
    my $past;
    if $key eq 'begin' {
        my @empty;
        $past:= PAST::Block.new(
            :blocktype('declaration'),
            :node( $/ ),
            :hll('Steme'),
            :namespace(@empty),
        );
        @?BLOCK.unshift($past);
        @?LIBRARY.unshift($past);
    }
    else {
        $past := @?BLOCK.shift();
        for $<statement> {
            $past.push( $_.ast );
        }
        make $past;
        @?LIBRARY.shift();
    }
}


method statement($/, $key) {
    make $/{$key}.ast
}

method special($/, $key) {
    make $/{$key}.ast
}

method if($/) {
    make PAST::Op.new(
        $<cond>.ast,
        $<iftrue>.ast,
        $<iffalse>.ast,
        :pasttype('if'),
        :node($/),
    );
}

method define($/) {
    our @?BLOCK;
    our @?LIBRARY;
    my $lib := @?LIBRARY[0];
    my @ns := $lib.namespace();
    my $var := $<var>.ast;
    $var.scope('package');
    $var.namespace(@ns);
    #$var.isdecl(1);
    my $val := $<val>.ast;
    $lib.symbol( $var.name, :scope('package') );
    make PAST::Op.new( $var, $val, :pasttype('bind'), :node($/) );
}

method let($/, $key) {
    our @?BLOCK;
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
        @?BLOCK.unshift($block);
    }
    else {
        my $stmts := PAST::Stmts.new();
        for $<statement> {
            $stmts.push( $_.ast );
        }
        $block := @?BLOCK.shift();
        $block.push($stmts);
        make $block;
    }
}

method lambda($/, $key) {
    our @?BLOCK;
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
        @?BLOCK.unshift($block);
    }
    else {
        my $stmts := PAST::Stmts.new();
        for $<statement> {
            $stmts.push( $_.ast );
        }
        $block := @?BLOCK.shift();
        $block.push($stmts);
        make $block;
    }
}

method library($/, $key) {
    our @?BLOCK;
    our @?LIBRARY;
    my $block;
    my @ns := $<ns>;
    if $key eq 'begin' {
        $block := PAST::Block.new( :blocktype('immediate'), :namespace(@ns), :node($/) );
        @?BLOCK.unshift($block);
        @?LIBRARY.unshift($block);
    }
    else {
        my $stmts := PAST::Stmts.new();
        for $<statement> {
            $stmts.push( $_.ast );
        }
        $block := @?BLOCK.shift();
        $block.push($stmts);
        make $block;
        @?LIBRARY.shift();
    }
}

method export($/) {
    my $past := PAST::Op.new(
        :pasttype('call'),
        :name('export'),
        :node( $/ ),
        PAST::Val.new(:value(~$<sym>), :returns('String')),
    );
    make $past;
}

method import($/) {
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
        $past.push($import);
    }
    make $past;
}

method hllimport($/) {
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
    for $<term> {
        $past.push( $_.ast );
    }
    make $past;
}

##  term:
##    Like 'statement' above, the $key has been set to let us know
##    which term subrule was matched.
method term($/, $key) {
    make $/{$key}.ast;
}


method value($/, $key) {
    make $/{$key}.ast;
}

method symbol($/) {
    our @?BLOCK;
    my $scope := 'package';
    my $name := ~$<symbol>;
    for @?BLOCK {
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


method quote($/) {
    make PAST::Val.new(
        :value( $<string_literal>.ast ),
        :node($/),
    );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:


#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Encode;
use LWP::UserAgent;
use HTML::TreeBuilder;

use constant{
    ITEM_ELEMENT_NUMBER => 8,
    MAX_PRICE => '540',
    MIN_SIZE => '19',
    MIN_OLD => '1984',
};

use Data::Dumper;
print Dumper "--------------------------------------------------------------";
print Dumper "yahoo tokyo city.";
print Dumper "--------------------------------------------------------------";


#東京都23区の物件
my @urls     = (
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&lc=&md=area&frm_rsrch=1&pf=13&search=1&geo=13101&geo=13102&geo=13103&geo=13104&geo=13105&from=0&to=10000000&lo=1&lo=2&year=15&yearto=0&spfrom=0&spto=4000&wlk=15&cd=6&cd=10&cd=2&key=',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&md=area&to=10000000&spfrom=0&spto=4000&wlk=15&cd=6%2C+10%2C+2&geo=13113%2C+13116%2C+13117%2C+13119%2C+13106&lo=1%2C+2&year=15&yearto=0&search=1',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&geo=13113%2C%2013116%2C%2013117%2C%2013119%2C%2013106&md=area&to=10000000&lo=1%2C%202&spfrom=0&spto=4000&wlk=15&year=15&yearto=0&cd=6%2C%2010%2C%202&search=1&pagenum=20',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&geo=13113%2C%2013116%2C%2013117%2C%2013119%2C%2013106&md=area&to=10000000&lo=1%2C%202&spfrom=0&spto=4000&wlk=15&year=15&yearto=0&cd=6%2C%2010%2C%202&search=1&pagenum=40',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&md=area&to=10000000&spfrom=0&spto=4000&wlk=15&cd=6%2C+10%2C+2&geo=13107%2C+13108%2C+13118%2C+13121%2C+13122&lo=1%2C+2&year=15&yearto=0&search=1',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&geo=13107%2C%2013108%2C%2013118%2C%2013121%2C%2013122&md=area&to=10000000&lo=1%2C%202&spfrom=0&spto=4000&wlk=15&year=15&yearto=0&cd=6%2C%2010%2C%202&search=1&pagenum=20',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&md=area&to=10000000&spfrom=0&spto=4000&wlk=15&cd=6%2C+10%2C+2&geo=13123%2C+13114%2C+13115%2C+13120%2C+13109&lo=1%2C+2&year=15&yearto=0&search=1',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&geo=13123%2C%2013114%2C%2013115%2C%2013120%2C%2013109&md=area&to=10000000&lo=1%2C%202&spfrom=0&spto=4000&wlk=15&year=15&yearto=0&cd=6%2C%2010%2C%202&search=1&pagenum=20',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&md=area&to=10000000&spfrom=0&spto=4000&wlk=15&cd=6%2C+10%2C+2&geo=13110%2C+13111%2C+13112%2C+13229&lo=1%2C+2&year=15&yearto=0&search=1',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&md=area&to=10000000&spfrom=0&spto=4000&wlk=15&cd=6%2C+10%2C+2&geo=13110%2C+13111%2C+13112&lo=1%2C+2&year=15&yearto=0&search=1',
    'http://used.realestate.yahoo.co.jp/bin/csearch?rps=4&pf=13&geo=13110%2C%2013111%2C%2013112&md=area&to=10000000&lo=1%2C%202&spfrom=0&spto=4000&wlk=15&year=15&yearto=0&cd=6%2C%2010%2C%202&search=1&pagenum=20',

);

foreach(@urls){
    my $url = $_;
    my $ua      = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)';
    my $timeout = '10';
    
    my $lwp = LWP::UserAgent->new( agent => $ua, timeout => $timeout );
    
    ## Cookie を保存する場合
    #my $cookie = time();
    #$lwp->cookie_jar({ file =>$cookie, autosave=>1 });
    
    ## コンテンツの取得
    my $res = $lwp->get( $url );
    
    ## コンテンツの取得成功時
    if ( $res->is_success ) {
	
	## TreeBuilder でコンテンツを解析
	my $tree = HTML::TreeBuilder->new;
	$tree->parse( $res->content );
	$tree->eof();
	
	my @items;
	my @tbody = $tree->find("tbody");
	foreach(@tbody){
	    my @td = $_->find("td");
	    push @items, @td
	}
	my $item_objects_ref = __create_item_object(@items);
	my @item_objects = @$item_objects_ref;
	if(scalar(@item_objects) == 0){
#	    print Dumper "nothing!!!!!!!!!!!!!!!!!!!";
	}else{
	    print Dumper @item_objects;
	}
	
	## 解析が終わったらデータをクリア
	$tree = $tree->delete;
	
	## コンテンツの取得失敗時
    } else {
	print "get error\n";
    }
}


sub __create_item_object{
    my @items = @_;

    my $items_number = @items; # 配列の長さ
    my $loop_number = $items_number / ITEM_ELEMENT_NUMBER;
    my $count = 0;
    my @item_objects;
    print Dumper @items;#####################################################################################
    while ($count < $loop_number && $count < 20){
	my $item = {};
	shift @items;
	my $a =  shift(@items)->find('a');
	unless($a){last;}
	$item->{url} = $a->attr('href');
	$item->{apart_name} = __encode_utf8(shift(@items)->as_text);
	$item->{station_name} = __encode_utf8(shift(@items)->as_text);
	$item->{price} = __encode_utf8(shift(@items)->as_text);
	$item->{size} = __encode_utf8(shift(@items)->as_text);
	$item->{old} = __encode_utf8(shift(@items)->as_text);
	shift @items;
	push @item_objects, $item;
	$count ++;
    }

    # 値段の高い物件を除く
    my $safe_price_items = __reject_high_price(\@item_objects);

    # 19平米以下の物件を除く
    my $safe_price_and_size_items = __reject_low_size($safe_price_items);

    # 1984年以前の物件を除く
    my $safe_items = __reject_old($safe_price_and_size_items);
    return $safe_items;
}

sub __reject_high_price{
    my $items = shift;
    my @safe_price_items = grep{
	my $decoded_price_text = Encode::decode('utf8', $_->{price});
	$decoded_price_text =~ s/,//g;
	$decoded_price_text =~ s/万円//g;

	$decoded_price_text < MAX_PRICE;
    }@$items;
    return \@safe_price_items;
}

sub __reject_low_size{
    my $items = shift;
    my @safe_size_items = grep{
	my $size_text = $_->{size};
	my $decoded_size_text = Encode::decode('utf8', $size_text);
	$decoded_size_text =~ s/ワンルーム//g;
	$decoded_size_text =~ s/1K//g;
	$decoded_size_text =~ s/1DK//g;
	$decoded_size_text =~ s/m2//g;

	$decoded_size_text > MIN_SIZE;
    }@$items;
    return \@safe_size_items;
}

sub __reject_old{
    my $items = shift;
    my @safe_old_items = grep{
	my $num = index($_->{old}, Encode::encode('utf8', '/'));
	my $old = substr($_->{old}, 0, $num);

	$old > MIN_OLD;
    }@$items;
    return \@safe_old_items;
}

sub __encode_utf8{
    my $text = shift;
    Encode::from_to($text, 'euc-jp', 'utf8');
    return $text;
}

exit;

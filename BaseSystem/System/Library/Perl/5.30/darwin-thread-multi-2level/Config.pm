# This file was created by configpm when Perl was built. Any changes
# made to this file will be lost the next time perl is built.

# for a description of the variables, please have a look at the
# Glossary file, as written in the Porting folder, or use the url:
# https://github.com/Perl/perl5/blob/blead/Porting/Glossary

package Config;
use strict;
use warnings;
our ( %Config, $VERSION );

$VERSION = "5.030002";

# Skip @Config::EXPORT because it only contains %Config, which we special
# case below as it's not a function. @Config::EXPORT won't change in the
# lifetime of Perl 5.
my %Export_Cache = (myconfig => 1, config_sh => 1, config_vars => 1,
		    config_re => 1, compile_date => 1, local_patches => 1,
		    bincompat_options => 1, non_bincompat_options => 1,
		    header_files => 1);

@Config::EXPORT = qw(%Config);
@Config::EXPORT_OK = keys %Export_Cache;

# Need to stub all the functions to make code such as print Config::config_sh
# keep working

sub bincompat_options;
sub compile_date;
sub config_re;
sub config_sh;
sub config_vars;
sub header_files;
sub local_patches;
sub myconfig;
sub non_bincompat_options;

# Define our own import method to avoid pulling in the full Exporter:
sub import {
    shift;
    @_ = @Config::EXPORT unless @_;

    my @funcs = grep $_ ne '%Config', @_;
    my $export_Config = @funcs < @_ ? 1 : 0;

    no strict 'refs';
    my $callpkg = caller(0);
    foreach my $func (@funcs) {
	die qq{"$func" is not exported by the Config module\n}
	    unless $Export_Cache{$func};
	*{$callpkg.'::'.$func} = \&{$func};
    }

    *{"$callpkg\::Config"} = \%Config if $export_Config;
    return;
}

die "$0: Perl lib version (5.30.2) doesn't match executable '$^X' version ($])"
    unless $^V;

$^V eq 5.30.2
    or die sprintf "%s: Perl lib version (5.30.2) doesn't match executable '$^X' version (%vd)", $0, $^V;


sub FETCH {
    my($self, $key) = @_;

    # check for cached value (which may be undef so we use exists not defined)
    return exists $self->{$key} ? $self->{$key} : $self->fetch_string($key);
}

sub TIEHASH {
    bless $_[1], $_[0];
}

sub DESTROY { }

sub AUTOLOAD {
    require 'Config_heavy.pl';
    goto \&launcher unless $Config::AUTOLOAD =~ /launcher$/;
    die "&Config::AUTOLOAD failed on $Config::AUTOLOAD";
}

# tie returns the object, so the value returned to require will be true.
tie %Config, 'Config', {
    archlibexp => '/System/Library/Perl/5.30/darwin-thread-multi-2level',
    archname => 'darwin-thread-multi-2level',
    cc => 'cc',
    d_readlink => 'define',
    d_symlink => 'define',
    dlext => 'bundle',
    dlsrc => 'dl_dlopen.xs',
    dont_use_nlink => undef,
    exe_ext => '',
    inc_version_list => ' ',
    intsize => '4',
    ldlibpthname => 'DYLD_LIBRARY_PATH',
    libpth => '/System/Volumes/Data/SWE/macOS/BuildRoots/38cf1d983f/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.6.Internal.sdk/usr/local/lib /System/Volumes/Data/SWE/macOS/BuildRoots/38cf1d983f/Applications/Xcode.app/Contents/Developer/Toolchains/OSX11.6.xctoolchain/usr/lib/clang/12.0.5/lib /System/Volumes/Data/SWE/macOS/BuildRoots/38cf1d983f/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.6.Internal.sdk/usr/lib /System/Volumes/Data/SWE/macOS/BuildRoots/38cf1d983f/Applications/Xcode.app/Contents/Developer/Toolchains/OSX11.6.xctoolchain/usr/lib /System/Volumes/Data/SWE/macOS/BuildRoots/38cf1d983f/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib /usr/lib /usr/local/lib',
    osname => 'darwin',
    osvers => '20.0',
    path_sep => ':',
    privlibexp => '/System/Library/Perl/5.30',
    scriptdir => '/usr/bin',
    sitearchexp => '/Library/Perl/5.30/darwin-thread-multi-2level',
    sitelibexp => '/Library/Perl/5.30',
    so => 'dylib',
    useithreads => 'define',
    usevendorprefix => 'define',
    version => '5.30.2',
};

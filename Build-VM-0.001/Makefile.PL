
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "turns baubles into trinkets",
  "AUTHOR" => "Jon A <three18ti\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "File::ShareDir::Install" => "0.03"
  },
  "DISTNAME" => "Build-VM",
  "EXE_FILES" => [
    "bin/vm-gen.pl"
  ],
  "LICENSE" => "perl",
  "NAME" => "Build::VM",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Ceph::RBD::CLI" => 0,
    "Data::Dump" => 0,
    "File::ShareDir" => 0,
    "File::ShareDir::Install" => 0,
    "Getopt::Long::Descriptive" => 0,
    "List::MoreUtils" => 0,
    "Moose" => 0,
    "MooseX::HasDefaults::RO" => 0,
    "Sys::Guestfs" => 0,
    "Sys::Virt" => 0,
    "Template" => 0,
    "lib" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Test::More" => "0.88",
    "Test::Output" => 0
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "Ceph::RBD::CLI" => 0,
  "Data::Dump" => 0,
  "File::ShareDir" => 0,
  "File::ShareDir::Install" => 0,
  "Getopt::Long::Descriptive" => 0,
  "List::MoreUtils" => 0,
  "Moose" => 0,
  "MooseX::HasDefaults::RO" => 0,
  "Sys::Guestfs" => 0,
  "Sys::Virt" => 0,
  "Template" => 0,
  "Test::More" => "0.88",
  "Test::Output" => 0,
  "lib" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}



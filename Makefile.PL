
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Runs multiple LWP Client connections in parallel",
  "AUTHOR" => "joshr <joshr\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "LWP-Concurrent",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "LWP::Concurrent",
  "PREREQ_PM" => {
    "Data::Dumper" => 0,
    "HTTP::Async" => "0.11",
    "HTTP::Request" => "6.00",
    "Moo" => "1.000006",
    "Time::HiRes" => 0,
    "URI" => "1.60"
  },
  "VERSION" => "0.001_001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);




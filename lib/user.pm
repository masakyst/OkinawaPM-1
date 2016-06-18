package user;

use Rex::Commands;
use Rex::Commands::Fs;
use Rex::Commands::File;
use Rex::Commands::User;
use Rex::Commands::Run;

task "rollout_account", sub {
   my $param = shift;
   my $user     = $param->{user};
   my $group    = $param->{group};
   my $password = $param->{password};

   create_group $group;

   create_user $user => {
      groups   => [$group],
      password => $password,
   };

   mkdir "/home/$user/.ssh",
      owner => $user,
      group => $group,
      mode  => 700;

   file "/home/$user/.ssh/authorized_keys",
      source => "etc/.ssh/$user.pub",
      owner  => $user,
      group  => $group,
      mode   => 600;
   
   # sudo
   run "echo '".$user." ALL=(ALL) ALL' >> /etc/sudoers";
};

1;

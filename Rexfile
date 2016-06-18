
use strict;
use warnings;
use YAML;
use Data::Dumper;

my $conf = YAML::LoadFile("conf.yml");

# key auth
if ($conf->{private_key}) {
    user $conf->{user};
    private_key $conf->{private_key};
    public_key $conf->{public_key};
    key_auth;
}
else {
    user $conf->{user};
    password $conf->{password};
}

desc "Show Unix version";
task "uname", sub {
   say run "uname -a";
};

desc "Show Unix version";
task "ls", sub {
   my $output = run "ls -la";
   say Dumper($output);
};

desc "Initialize Setup";
task "init", sub {
    # add epel repository
    run "rpm --upgrade --verbose --hash http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm";
    file "/etc/yum.repos.d/epel.repo", source => "etc/yum.repos.d/epel.repo";
    install [ qw/gcc make patch git wget zip unzip openssh-clients openssl openssl-devel logwatch/ ];
    # make webadmin user
    require user;
    user::rollout_account({
        user      => $conf->{webadmin}->{user},
        group     => $conf->{webadmin}->{group},
        password  => $conf->{webadmin}->{password},
    });
    # exclude=kernel*を適用
    file "/etc/yum.conf", content => template("etc/yum.conf");
};

desc "End Setup";
task "end", sub {
    # rootログイン無し、パスワードログイン無し、鍵認証のみ
    file "/etc/ssh/sshd_config", 
        content => template("etc/ssh/sshd_config"),
        on_change => sub {
            service sshd => "restart"; 
        };
};


desc "Update Packages";
task "update_packages", sub {
    update_package_db;
};
 
desc "Install Apache";
task "apache", sub {
    install [ qw/httpd httpd-devel mod_ssl/ ];
    file "/etc/httpd/conf/httpd.conf",
        #source    => "etc/httpd/conf/httpd.conf",
        content    => template("etc/httpd/conf/httpd.conf.tpl", conf => $conf),
        on_change => sub {
            service httpd => "restart";
            run "chkconfig httpd on";
        };
    run "chown -R ".$conf->{webadmin}->{user}.": /var/www/html";
    run q{mkdir -p /etc/httpd/certs};
    run q{openssl md5 /usr/bin/* > /etc/httpd/certs/rand.dat};
    run q{openssl genrsa -rand /etc/httpd/certs/rand.dat -out /etc/httpd/certs/server.key 2048};
    run q{openssl req -new -batch -key /etc/httpd/certs/server.key -out /etc/httpd/certs/server.csr};
    run q{openssl x509 -in /etc/httpd/certs/server.csr -days 3650 -req -signkey /etc/httpd/certs/server.key > /etc/httpd/certs/server.crt};
};

desc "Install PHP";
task "php", sub {
    install [ qw/php php-cli php-mbstring php-pdo php-mysql php-pear/ ];
    service httpd => "restart";
};

desc "Install MySQL";
task "mysql", sub {
    install [ qw/mysql mysql-server mysql-devel/ ];
    file "/etc/my.cnf",
        source    => "etc/my.cnf",
        on_change => sub {
            service mysqld => "restart";
            run "chkconfig mysqld on";
        };
};

desc "Install ModernPerl";
# v5.20
task "modernperl", sub {
     run "mkdir -p /opt/local/bin";
     run "curl https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build | perl - 5.20.1 /opt/perl-5.20/";
     run "curl -o /opt/perl-5.20/bin/cpanm -L http://xrl.us/cpanm";
     run "chmod +x /opt/perl-5.20/bin/cpanm";
     run "/opt/perl-5.20/bin/cpanm Carton";
     run 'echo "export PATH=/opt/perl-5.20/bin:$PATH" >> /home/'.$conf->{webadmin}->{user}.'/.bashrc';
};
 
desc "Install WordPress";
task "wordpress", sub {
    run "cd /var/www/html; wget http://wordpress.org/latest.tar.gz";
    run "cd /var/www/html; tar zxvf latest.tar.gz";
    run "chown -R ".$conf->{webadmin}->{user}.": /var/www/html/wordpress";
};

 

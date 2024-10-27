#!/usr/bin/env perl
use strict;
use warnings;
use v5.10;

my $packages = {
    deb => [
        "python3-venv",
        "libtext-template-perl",
        "libssh-dev",
        "curl",
        "git",
        "openssl",
        "jq",
    ],
    rpm => [
        "python3-virtualenv",
        "perl-Text-Template",
        "libssh-devel",
        "curl",
        "git",
        "openssl",
        "jq",
    ]
};

my @supported_distributives = qw(
    debian
    ubuntu
    redhat
    centos
    rocky
    alma
);

my $package_manager = {
    deb => "apt",
    rpm => "dnf"
};

if ($^O ne "linux") {
    say "Unsupported OS detected. Only Linux distributions can be used.";
    say "Supported distributions are: " . join(", ", @supported_distributives);
    exit -1;
}

chomp (my $work_dir = qx(pwd));
my $bin_dir = '/usr/local/bin';
chomp(my $temp_dir = qx(mktemp -d -p /tmp temp-XXXXXX));
my $venv_name = "venv";
my $ansibe_collections_path = "$work_dir/$venv_name/collections";
my $venv_bin_path = "$work_dir/$venv_name/bin";
my $activate_path = "$venv_bin_path/activate";
my $pip_path = "$venv_bin_path/pip";
my $python3_path = "$venv_bin_path/python3";
my $ansible_playbook_path = "$venv_bin_path/ansible-playbook";
my $ansible_galaxy_path = "$venv_bin_path/ansible-galaxy";
my $vars = {
    activate_path => \$activate_path,
    ansibe_collections_path => \$ansibe_collections_path,
    ansible_playbook_path => \$ansible_playbook_path,
    venv_bin_path => \$venv_bin_path
};

#######################################################################################################################
#######################################################################################################################
# MAIN PART
#######################################################################################################################
#######################################################################################################################

END {
    say "Cleaning up temporary files...";
    &run_cmd("rm -rf $temp_dir");
}

&is_root();

&refresh_repositories();
&install_packages();
say "Packages successfully installed.";

&create_python_venv();
&install_python_dependcies();
&install_ansible_dependcies();
&evaluate_template("$work_dir/run_playbook.sh.tmpl", "$work_dir/run_playbook.sh", $vars);
&run_cmd("chmod +x $work_dir/run_playbook.sh");
&evaluate_template("$work_dir/run_venv_cmd.sh.tmpl", "$work_dir/run_venv_cmd.sh", $vars);
&run_cmd("chmod +x $work_dir/run_venv_cmd.sh");
say "Virtual environment successfully prepeared.";


#######################################################################################################################
#######################################################################################################################
# Functions
#######################################################################################################################
#######################################################################################################################

sub create_python_venv {
    &run_cmd("python3 -m venv $venv_name");
}

sub install_python_dependcies {
    &run_cmd(". $activate_path && $pip_path install -r requirements.txt");
}

sub install_ansible_dependcies {
    &run_cmd("mkdir -p $ansibe_collections_path");
    &run_cmd(". $activate_path && $ansible_galaxy_path collection install -r requirements.yml -p $ansibe_collections_path");
}

sub evaluate_template() {
    require Text::Template;
    my $src_path = shift;
    my $dst_path = shift;
    my $vars = shift;
    my $template = Text::Template->new(SOURCE => $src_path) || die("Couldn't construct template: $Text::Template::ERROR");

    my $result = $template->fill_in(HASH => $vars);
    if ($result) { 
        open(my $fh, "> $dst_path") || die ("Couldn't open destination file.");
        foreach (split("\n", $result)) {
            print $fh "$_\n";
        }
        close $fh;
    } else { 
        die ("Couldn't fill in template: $Text::Template::ERROR");
    }
}

sub refresh_repositories {
    my $distro = &check_distributive_base();
    my $pkg_mg = $package_manager->{$distro};
    if ( $distro eq "deb" ) {
        &run_cmd_with_sudo("$pkg_mg update");
        &run_cmd_with_sudo("DEBIAN_FRONTEND=noninteractive $pkg_mg upgrade -y");
    } else {
        &run_cmd_with_sudo("$pkg_mg update -y");
    }
}

sub install_packages {
    my $distro = &check_distributive_base();
    my $pkg_mg = $package_manager->{$distro};
    foreach my $pkg (@{$packages->{$distro}}) {
        &run_cmd_with_sudo("$pkg_mg install -y $pkg");
    }
}

sub check_distributive_base {
    chomp (my $distro = qx(awk -F'=' '/^ID=/ {print tolower(\$2)}' /etc/*-release 2> /dev/null));
    die "Cannot determine Linux distributive" unless $distro;
    die "Unsupported distributive" unless grep {$_ eq $distro} @supported_distributives;
    if ( $distro eq "debian" || $distro eq "ubuntu" ) {
        return "deb";
    } else {
        return "rpm";
    }
}

sub is_root {
    if ( getpwuid $> eq 'root') {
        say "This script must be used with normal user and SUDO privileges";
        exit 1;
    }
}

sub has_sudo {
    my $prompt = `sudo -ln 2>&1`;
    if ($? eq 0) {
        return "no_pass";
    } elsif ( $prompt =~ /^sudo:/) {
        return "need_pass";
    } else {
        die "SUDO privileges not found.";
    }
}

sub run_cmd_with_sudo {
    my $cmd = "sudo ";
    $cmd .= shift;
    my $has_sudo = &has_sudo();
    if ($has_sudo eq "need_pass" ) {
        say "Please supply sudo password for the following command: '$cmd'";
    }
    &run_cmd($cmd);
}

sub run_cmd {
    my $cmd = shift;
    system($cmd);
    if ($?){
        say "an error occurred while executing: $cmd";
        exit 1;
    };
}


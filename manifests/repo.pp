################################################################################
#
#    filename: repo.pp
# description: manifest for configuring cloudmin repository
#      author: Andre Mattie
#       email: devel@introsec.ca
#         GPG: 5620 A200 6534 B779 08A8  B22B 0FA6 CD54 93EA 430D
#     bitcoin: 1LHsfZrES8DksJ41JAXULimLJjUZJf7Qns
#        date: 03/16/2017
#
################################################################################
class cloudmin::repo (
  $version         = $cloudmin::params::ver,
  ) inherits cloudmin {

# create directory to store gpg signing key
    file { '/tmp/cloudmin': 
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    apt::key { 'cloudmin':
        key        => 'CB9262B0',
        key_source => 'http://software.virtualmin.com/lib/RPM-GPG-KEY-virtualmin',
    }

    apt::key { 'webmin':
        key        => '1B24BE83',
        key_source => 'http://software.virtualmin.com/lib/RPM-GPG-KEY-webmin',
    }

# create entry for repository in sources.list

    if ( $version == 'pro' ) {
        apt::source { 'cloudmin-pro':
            location    => 'http://$serial:$key@cloudmin.virtualmin.com',
            release     => 'debian',
            repos       => 'binary',
            key         => 'CB9262B0',
            key_source  => 'http://software.virtualmin.com/lib/RPM-GPG-KEY-virtualmin',
            include_src => false,
            }
            
            
    elsif ( $version == 'gpl' ) {
        apt::source { 'cloudmin-gpl':
            location    => 'http://cloudmin.virtualmin.com/gpl',
            release     => 'debian',
            repos       => 'binary',
            key         => 'CB9262B0',
            key_source  => 'http://software.virtualmin.com/lib/RPM-GPG-KEY-virtualmin',
            include_src => false,   
        }
    } else {}
}

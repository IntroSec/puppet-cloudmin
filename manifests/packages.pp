################################################################################
#
#    filename: packages.pp
# description: manifest for installing all needed packages
#      author: Andre Mattie
#       email: devel@introsec.ca
#         GPG: 5620 A200 6534 B779 08A8  B22B 0FA6 CD54 93EA 430D
#     bitcoin: 1LHsfZrES8DksJ41JAXULimLJjUZJf7Qns
#        date: 03/16/2017
#
################################################################################
class cloudmin::packages {
    $packages   = ['perl','openssl','libio-pty-perl','libio-stty-perl','libnet-ssleay-perl','libwww-perl','libdigest-hmac-perl','libxml-simple-perl','libcrypt-ssleay-perl','libauthen-pam-perl','cron','bind9','openssh-server','openssh-client','lsof','libjson-perl','bind9utils','dhcp3-server','libdigest-sha1-perl']

    package { $packages:
        ensure => present,
        }
}
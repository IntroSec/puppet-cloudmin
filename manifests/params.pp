################################################################################
#
#    filename: params.pp
# description: manifest for all parameter variables
#      author: Andre Mattie
#       email: devel@introsec.ca
#         GPG: 5620 A200 6534 B779 08A8  B22B 0FA6 CD54 93EA 430D
#     bitcoin: 1LHsfZrES8DksJ41JAXULimLJjUZJf7Qns
#        date: 03/16/2017
#
################################################################################
class cloudmin::params {
    $ver    = 'pro'
    $serial = undef
    $key    = undef
    $gpgkey = 'CB9262B0'
    
    
}
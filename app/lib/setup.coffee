require('json2ify')
require('es5-shimify')
require('jqueryify')

require('crypto/sha1') # hack for hem/slug/spine being a pain in the ass
require('bloomfilters')

require('spine')
require('spine/lib/local')
require('spine/lib/ajax')
require('spine/lib/manager')
require('spine/lib/relation')
require('spine/lib/route')
require('spine/lib/tmpl')

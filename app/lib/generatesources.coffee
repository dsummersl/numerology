#BloomFilter = require('bloomjs')

max = 100
range = [1..max]

# http://en.wikibooks.org/wiki/Efficient_Prime_Number_Generating_Algorithms# {{{
primeBuilder = (max) ->
  primes = [3]
  potential = 3
  while potential < max
    potential += 2
    sqrt_potential = Math.sqrt(potential)
    isprime = true
    for a in primes
      break if a>sqrt_potential
      if potential % a == 0
        isprime = false
        break
    primes.push(potential) if isprime
  primes.unshift(1)
  return primes
# }}}
# http://mathworld.wolfram.com/ZeiselNumber.html# {{{
zeiselBuilder = (primes,max) ->
  p_i = (i,a,b) -> a*i + b
  zeisels = []
  for a in [-10..10]
    for b in [-10..10]
      p1 = p_i(1,a,b)
      p2 = p_i(p1,a,b)
      p3 = p_i(p2,a,b)
      if (p1 in primes) && (p2 in primes) && (p3 in primes) && (p1 != p2) && (p2 != p3) && (p1 != p3)
        #console.log "zeisel #{p1}*#{p2}*#{p3} = #{p1*p2*p3} for #{a} and #{b}"
        zeisels.push(p1*p2*p3)
  return zeisels
# }}}
# figurative numbers: http://en.wikipedia.org/wiki/Figurate_number {{{
# http://en.wikipedia.org/wiki/Triangular_number
triangularBuilder = (max) ->
  nums = []
  n = 1
  while n < max
    nums.push(n*(n+1)/2)
    n++
  return nums

# http://en.wikipedia.org/wiki/Pentagonal_number
pentagonalBuilder = (max) ->
  nums = []
  n = 1
  while n < max
    nums.push((3*n*n-n)/2)
    n++
  return nums

# http://en.wikipedia.org/wiki/Hexagonal_number
hexagonalBuilder = (max) ->
  nums = []
  n = 1
  while n < max
    nums.push((2*n*(2*n-1))/2)
    n++
  return nums

# TODO there are a whole variety of r-tropic numbers that go mutidimensional that I could build up to.
# }}}

# TODO polite and impolite numbers
# TODO euler numbers
# TODO carmichael number
# TODO psueo primes
# TODO telephone book number
# TODO Hardy–Ramanujan number (1729)
# TODO taxicab number
# TODO sphenic number
# TODO automorphic number
# TODO square triangular number
# TODO natural numbers (or am I doing that anyway?)

primes = primeBuilder(max*max)
zeisels = zeiselBuilder(primes,max)
triangulars = triangularBuilder(max)
pentagonals = pentagonalBuilder(max)
hexagonals = hexagonalBuilder(max)
#console.log zeisels

tests =
  even:
    name: 'Even'
    description: 'Divisible by 2.'
    link: 'http://en.wikipedia.org/wiki/Even_and_odd_numbers'
    computed: false
    test: "result = n % 2 == 0"
  singlyeven:
    name: 'Singly Even'
    description: 'Evenly divisble by 2, but not 4.'
    link: 'http://en.wikipedia.org/wiki/Singly_even_number'
    computed: false
    test: "result = n % 2 == 0 && n % 4 != 0"
  odd:
    name: 'Odd'
    description: 'Not divisible by 2.'
    link: 'http://en.wikipedia.org/wiki/Even_and_odd_numbers'
    computed: false
    test: "result = n % 2 != 0"
  square:
    name: 'Perfect Square'
    description: 'A product of some integer <i>k</i> squared.'
    link: 'http://en.wikipedia.org/wiki/Square_number'
    computed: false
    test: """
      root = Math.sqrt(n)
      result = (root - Math.floor(root)) == 0
    """
  nonsquare:
    name: 'Square Free'
    description: 'Indivisible by a perfect square.'
    link: 'http://en.wikipedia.org/wiki/Square-free_integer'
    computed: false
    test: """
      root = Math.sqrt(n)
      square = (root - Math.floor(root)) == 0
      result = !square || n == 1
    """
  prime:
    name: 'prime'
    description: 'Has no divisor other than itself and 1.'
    link: 'http://en.wikipedia.org/wiki/Prime_number'
    computed: true
    test: (n) -> n in primes
  zeisel:
    name: 'zeisel'
    description: 'A square free number that has at least three prime factors of the form <i>p</i><sub>x</sub> = <i>ap</i><sub>x-1</sub> + <i>b</i>.'
    link: 'http://en.wikipedia.org/wiki/Zeisel_number'
    computed: true
    test: (n) -> n in zeisels
  triangular:
    # TODO this wiki page has a pretty diagram - can I embed diagrams somehow?
    name: 'triangular'
    description: 'TODO Can form an equilateral triangle in cannon ball formation.'
    link: 'http://en.wikipedia.org/wiki/Triangular_number'
    computed: true
    test: (n) -> n in triangulars
  pentagonal:
    name: 'pentagonal'
    description: 'TODO A number that can form pentagonal shapes when evenly spaced.'
    link: 'http://en.wikipedia.org/wiki/Pentagonal_number'
    computed: true
    test: (n) -> n in pentagonals
  hexagonal:
    name: 'hexagonal'
    description: 'TODO A number that form hexagonal shapes when evenly spaced.'
    link: 'http://en.wikipedia.org/wiki/Hexagonal_number'
    computed: true
    test: (n) -> n in hexagonals

#generateTags = (n,tests,bf) ->
generateTags = (n,tests) ->
  for k,v of tests
    if tests[k].computed && tests[k].test(n)
      tests[k].numbers.push(n)
      #bf.add("#{k}-#{n}")

# TODO an optimization: I could use a bloom filter for each computed value...insert it into the bloom filter
# and then after all the computations retest all the integers up to the max and see if there are any false->positives
# and include with the bloom filter an 'exception list': numbers that say they are true, but aren't.

tests[k].numbers = [] for k,v of tests

#bf = new BloomFilter()
#generateTags(n,tests,bf) for n in range
generateTags(n,tests) for n in range

###
#console.log("Review...")
for k,v of tests
  #console.log("looking at #{k}")
  for n in range
    if n in tests[k].numbers
      inHash = bf.hasKey("#{k}-#{n}")
      #console.log(" has #{n} - and #{inHash}")
      if not inHash
        console.log("ERROR: false positive for #{n}")
  tests[k].numbers = [] # after verification, we can ditch it.

console.log(" six is prime? #{tests.prime.bf.hasKey(6)}")
console.log(" five is prime? #{tests.prime.bf.hasKey(5)}")
data = ["0","0","0","1","0","0","0","0","0","0","0","0","0","0","0","0","1","1","1","0","0","0","1","1","1","1","1"]
console.log(" rle: '#{JSON.stringify(BloomFilter.rle(data))}'")
decoded = BloomFilter.unrle(BloomFilter.rle(data))
console.log(" unrle = #{decoded}")
console.log("  data = #{data}")
i = 0
while i < data.length
  console.log ("bit #{i} #{data[i]} vs #{decoded[i]} is not the same") if data[i] != decoded[i]
  i++

bf = new BloomFilter({ filter: BloomFilter.rle(tests.prime.bf.filter)})
#console.log(" rle = "+BloomFilter.rle(tests.prime.bf.filter))
console.log(" six is prime? #{bf.hasKey(6)}")
console.log(" five is prime? #{bf.hasKey(5)}")

console.log "A: "+ BloomFilter.rle(tests.prime.bf.filter)
console.log "B: "+ BloomFilter.rle(bf.filter)
###
#i = 0
#while i < tests.prime.bf.filter.length
#  console.log ("bit #{i} #{data[i]} vs #{decoded[i]} is not the same") if tests.prime.bf.filter[i] != bf.filter[i]
#  i++


console.log JSON.stringify({
  tests: tests
  #filter: BloomFilter.rle(bf.filter)
})

# set vim: fdm=marker:


max = 100
range = [1..max]

# http://en.wikibooks.org/wiki/Efficient_Prime_Number_Generating_Algorithms
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

# http://mathworld.wolfram.com/ZeiselNumber.html
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

primes = primeBuilder(max*max)
zeisels = zeiselBuilder(primes,max)
triangulars = triangularBuilder(max)
pentagonals = pentagonalBuilder(max)
hexagonals = hexagonalBuilder(max)
#console.log zeisels

tests =
  square: (n) ->
    root = Math.sqrt(n)
    #console.log (root - Math.floor(root))
    return (root - Math.floor(root)) == 0
  nonsquare: (n) -> !tests.square(n) || n == 1
  prime: (n) -> n in primes
  zeisel: (n) -> n in zeisels
  triangular: (n) -> n in triangulars
  pentagonal: (n) -> n in pentagonals
  hexagonal: (n) -> n in hexagonals

generateTags = (n) =>
  applicableTags = []
  for k,v of tests
    applicableTags.push(k) if v(n)
  return applicableTags

for n in range
  console.log "#{n},#{generateTags(n)}"

# dump out the extra numbers I may have computed
###
for p in primes
  console.log "#{p},prime" if p > max
for z in zeisels
  console.log "#{z},zeisel" if z > max
###
# set vim: fdm=marker:

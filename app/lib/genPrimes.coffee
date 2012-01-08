### Generate primes up to 'max', and nontify the callback function 'listener' of the 
# primes as they are discovered.
# Return the total number found.
###
primeBuilder = (max,listener) ->
  maxRoot = Math.sqrt(max)+1
  primes = [3]
  potential = 3
  listener(1)
  listener(2)
  listener(3)
  cnt = 3
  while potential < max
    potential += 2
    sqrt_potential = Math.sqrt(potential)
    isprime = true
    for a in primes
      break if a>sqrt_potential
      if potential % a == 0
        isprime = false
        break
    if isprime
      listener(potential)
      cnt++
      primes.push(potential) if potential < maxRoot
  return cnt

module.exports = primeBuilder

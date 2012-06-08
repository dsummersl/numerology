###
# An interface for generating numbers that belong to a property.
###
class PropertyGenerator
	###
	# Generate the next number not in the set. Use the previous set of numbers if need be.
  # Add the number to the set.
	#
	# Return true/false if there is a next one.
	###
	getNext: (set)->

	###
	# Generate the all the next number up to and including 'n'. Use the previous set of numbers if need be.
  # Add the numbers to the set.
	#
	# Return true/false if there is a next one.
	###
	getUpTo: (n,set)->

class PrimeGenerator extends PropertyGenerator
	getNext: (set)->
		@set = set
		# TODO fix up.
		primeBuilder(n,primeListener)

	getUpTo: (n,set)->
		@set = set
		primeBuilder(n,primeListener)

  primeListener: (n) -> @set.add(n)

	### Generate primes up to 'max', and nontify the callback function 'listener' of the 
	# primes as they are discovered.
	# Return the total number found.
	###
	primeBuilder: (max,listener,min=1) ->
		maxRoot = Math.sqrt(max)+1
		primes = [3]
		potential = 3
		listener(1) if min <=1
		listener(2) if min <=2
		listener(3) if min <=3
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

module.exports = {
	PrimeGenerator: PrimeGenerator
}

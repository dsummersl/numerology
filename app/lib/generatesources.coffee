Filters = require('lib/BloomFilter')

#max = 10000
max = 1000
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
#http://en.wikipedia.org/wiki/Fibonacci_number# {{{
fibonacciBuilder = (max) ->
  f_0 = 0
  f_1 = 1
  f_n = (n) =>
    return f_0 if n == 0
    return f_1 if n == 1
    return f_n(n-1) + f_n(n-2)
  nums = [0,1]
  n = 2
  last = 1
  while last < max
    last = f_n(n++)
    nums.push(last)
  return nums
# }}}
# http://en.wikipedia.org/wiki/Mersenne_prime# {{{
mersenneBuilder = (max) ->
  m_p = (n) -> Math.pow(2,n)-1
  results = []
  n=1
  last = 1
  while last < max
    last = m_p(n++)
    results.push(last)
  return results
# }}}
# automorphics {{{
automorphicBuilder = (max) ->
  results = []
  n=0
  while n++ < max
    square = Math.pow(n,2)
    en = ""+n
    en2 = ""+square
    allmatch = true
    allmatch = false for d,i in en when en[i] != en2[en2.length-en.length+i]
    results.push(n) if allmatch
  return results
# }}}
# palindromes {{{
palindromeBuilder = (max) ->
  results = []
  n=0
  while n++ < max
    en = ""+n
    allmatch = true
    allmatch = false for d,i in en when en[en.length-i-1] != en[i]
    results.push(n) if allmatch
  return results
# }}}
# factorial {{{
factorialBuilder = (max) ->
  results = []
  n=1
  last = 1
  while last < max
    last = last*n++
    results.push(last)
  return results
# }}}

# TODO There are over 181 thousand unique sequences of numbers as defined at: oeis.org
# So...I'm just showcasing a tiny sequence of them.

# TODO polite and impolite numbers
#   polite number is a positive integer that can be written as the sum of two or more consecutive positive integers
#   impolite: the powers of two.
#   polite: everything else.
# TODO euler numbers
# TODO carmichael number
#
# TODO psueo primes
# TODO telephone book number

primes = primeBuilder(max*max)
zeisels = zeiselBuilder(primes,max)
triangulars = triangularBuilder(max)
pentagonals = pentagonalBuilder(max)
hexagonals = hexagonalBuilder(max)
fibonaccis = fibonacciBuilder(max)
mersennes = mersenneBuilder(max)
automorphics = automorphicBuilder(max)
palindromes = palindromeBuilder(max)
factorials = factorialBuilder(max)

tests = #{{{
  ###
  even:
    name: 'Even'
    description: 'Divisible by 2.'
    link: 'http://en.wikipedia.org/wiki/Even_and_odd_numbers'
    computed: false
    test: "result = n % 2 == 0"
  ###
  singlyeven:
    name: 'Singly Even'
    description: 'Evenly divisible by 2, but not 4.'
    link: 'http://en.wikipedia.org/wiki/Singly_even_number'
    computed: false
    test: "result = n % 2 == 0 && n % 4 != 0"
  ###
  odd:
    name: 'Odd'
    description: 'Not divisible by 2.'
    link: 'http://en.wikipedia.org/wiki/Even_and_odd_numbers'
    computed: false
    test: "result = n % 2 != 0"
  ###
  square:
    name: 'Perfect Square'
    description: 'A product of some integer <i>k</i> squared.'
    link: 'http://en.wikipedia.org/wiki/Square_number'
    computed: false
    test: """
      root = Math.sqrt(n)
      result = (root - Math.floor(root)) == 0
    """
  ###
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
  ###
  prime:
    name: 'Prime'
    description: 'Has no divisor other than itself and 1.'
    link: 'http://en.wikipedia.org/wiki/Prime_number'
    computed: true
    test: (n) -> n in primes
  zeisel:
    name: 'Zeisel'
    description: 'A square free number that has at least three prime factors of the form <i>p</i><sub>x</sub> = <i>ap</i><sub>x-1</sub> + <i>b</i>.'
    link: 'http://en.wikipedia.org/wiki/Zeisel_number'
    computed: true
    test: (n) -> n in zeisels
  triangular:
    # TODO this wiki page has a pretty diagram - can I embed diagrams somehow?
    name: 'Triangular'
    description: 'TODO Can form an equilateral triangle in cannon ball formation.'
    link: 'http://en.wikipedia.org/wiki/Triangular_number'
    computed: true
    test: (n) -> n in triangulars
  pentagonal:
    name: 'Pentagonal'
    description: 'A number that can form pentagonal shapes when evenly spaced.'
    link: 'http://en.wikipedia.org/wiki/Pentagonal_number'
    computed: true
    test: (n) -> n in pentagonals
  hexagonal:
    name: 'Hexagonal'
    description: 'A number that form hexagonal shapes when evenly spaced.'
    link: 'http://en.wikipedia.org/wiki/Hexagonal_number'
    computed: true
    test: (n) -> n in hexagonals
  fibonacci:
    name: 'Fibonacci'
    description: 'Defined by recurrence relation <i>F</i><sub>n</sub>=<i>F</i><sub>n-1</sub>+<i>F</i><sub>n-2</sub>.'
    link: 'http://en.wikipedia.org/wiki/Fibonacci_number'
    computed: true
    test: (n) -> n in fibonaccis
  mersenne:
    name: "Mersenne"
    description: 'A positive prime that is one less than the power of 2.'
    link: 'http://en.wikipedia.org/wiki/Mersenne_prime'
    computed: true
    test: (n) -> n in mersennes
  catalan:
    name: 'Catalan'
    description: 'Number of ways to insert n pairs of parentheses in a word of n+1 letters.'
    link: 'ttp://en.wikipedia.org/wiki/Catalan_numbers'
    oeis: 'http://oeis.org/A000108'
    computed: true
    test: (n) -> n in [ 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796, 58786, 208012, 742900, 2674440, 9694845, 35357670, 129644790, 477638700, 1767263190]
  ramanujan:
    name: 'Hardy-Ramanujan'
    description: 'The smallest number expressible as the sum of two cubes in two different ways (1729=1<sup>3</sup>+12<sup>3</sup>=9<sup>3</sup>+10<sup>3</sup>).'
    link: 'http://en.wikipedia.org/wiki/Ramanujan_number'
    oeis: 'http://oeis.org/A050794'
    computed: true
    test: (n) -> n in [1729]
  taxicab:
    name: 'Taxicab'
    description: 'The smallest number that can be expressed as a sum of two cubes in <i>n</i> ways.'
    link: 'http://en.wikipedia.org/wiki/Taxicab_number'
    oeis: 'http://oeis.org/A011541'
    computed: true
    test: (n) -> n in [ 2,1729,87539319 ]
  cabtaxi:
    name: 'Cabtaxi'
    description: ''
    link: 'http://en.wikipedia.org/wiki/Cabtaxi_number'
    description: 'The smallest positive integer that can be written as the sum of two positive or negative or 0 cubes in <i>n</i> ways.'
    computed: true
    test: (n) -> n in [ 1, 91, 728, 2741256, 6017193, 1412774811 ]
  sphenic:
    name: 'Sphenic'
    description: 'The product of three distinct prime numbers.'
    link: 'http://en.wikipedia.org/wiki/Sphenic_number'
    oeis: 'http://oeis.org/A007304'
    computed: true
    test: (n) -> n in  [30, 42, 66, 70, 78, 102, 105, 110, 114, 130, 138, 154, 165, 170, 174, 182, 186, 190, 195, 222, 230, 231, 238, 246, 255, 258, 266, 273, 282, 285, 286, 290, 310, 318, 322, 345, 354, 357, 366, 370, 374, 385, 399, 402, 406, 410, 418, 426, 429, 430, 434, 435, 438, 442, 455, 465, 470, 474, 483, 494, 498, 506, 518, 530, 534, 555, 561]
    #test: (n) -> n in [30, 42, 66, 70, 78, 102, 105, 110, 114, 130, 138, 154, 165, 170, 174, 182, 186, 190, 195, 222, 230, 231, 238, 246, 255, 258, 266, 273, 282, 285, 286, 290, 310, 318, 322, 345, 354, 357, 366, 370, 374, 385, 399, 402, 406, 410, 418, 426, 429, 430, 434, 435, 438, 442, 455, 465, 470, 474, 483, 494, 498, 506, 518, 530, 534, 555, 561, 574, 582, 590, 595, 598, 602, 606, 609, 610, 615, 618, 627, 638, 642, 645, 646, 651, 654, 658, 663, 665, 670, 678, 682, 705, 710, 715, 730, 741, 742, 754, 759, 762, 777, 782, 786, 790, 795, 805, 806, 814, 822, 826, 830, 834, 854, 861, 874, 885, 890, 894, 897, 902, 903, 906, 915, 935, 938, 942, 946, 957, 962, 969, 970, 978, 986, 987, 994, 1001, 1002, 1005, 1010, 1015, 1022, 1023, 1030, 1034, 1038, 1045, 1054, 1065, 1066, 1070, 1074, 1085, 1086, 1090, 1095, 1102, 1105, 1106, 1113, 1118, 1130, 1131, 1146, 1158, 1162, 1166, 1173, 1178, 1182, 1185, 1194, 1209, 1221, 1222, 1235, 1239, 1245, 1246, 1258, 1265, 1266, 1270, 1281, 1295, 1298, 1309, 1310, 1311, 1334, 1335, 1338, 1342, 1353, 1358, 1362, 1370, 1374, 1378, 1390, 1394, 1398, 1406, 1407, 1414, 1419, 1426, 1434, 1435, 1442, 1443, 1446, 1455, 1462, 1463, 1474, 1479, 1490, 1491, 1495, 1498, 1505, 1506, 1510, 1515, 1526, 1533, 1534, 1542, 1545, 1547, 1551, 1558, 1562, 1570, 1578, 1581, 1582, 1586, 1595, 1598, 1599, 1605, 1606, 1614, 1615, 1626, 1630, 1634, 1635, 1645, 1653, 1659, 1662, 1670, 1677, 1686, 1695, 1698, 1702, 1705, 1729, 1730, 1738, 1742, 1743, 1749, 1758, 1767, 1771, 1778, 1786, 1790, 1798, 1802, 1810, 1826, 1833, 1834, 1842, 1846, 1855, 1866, 1869, 1878, 1885, 1886, 1887, 1898, 1902, 1905, 1910, 1918, 1930, 1946, 1947, 1955, 1958, 1965, 1970, 1978, 1986, 1990, 2001, 2006, 2013, 2014, 2015, 2022, 2035, 2037, 2054, 2055, 2065, 2067, 2074, 2082, 2085, 2086, 2091, 2093, 2094, 2109, 2110, 2114, 2118, 2121, 2134, 2135, 2139, 2146, 2154, 2158, 2162, 2163, 2185, 2193, 2198, 2202, 2211, 2222, 2230, 2233, 2235, 2238, 2242, 2247, 2255, 2261, 2265, 2266, 2270, 2274, 2278, 2282, 2289, 2290, 2294, 2298, 2301, 2314, 2318, 2330, 2334, 2337, 2338, 2343, 2345, 2354, 2355, 2365, 2373, 2378, 2379, 2382, 2387, 2390, 2397, 2398, 2405, 2406, 2409, 2410, 2414, 2422, 2431, 2438, 2445, 2451, 2454, 2465, 2482, 2485, 2486, 2494, 2505, 2506, 2510, 2514, 2522, 2526, 2534, 2542, 2546, 2553, 2555, 2570, 2585, 2586, 2595, 2598, 2607, 2613, 2626, 2630, 2634, 2635, 2639, 2658, 2665, 2666, 2667, 2674, 2678, 2679, 2685, 2686, 2690, 2694, 2697, 2698, 2702, 2703, 2710, 2714, 2715, 2717, 2726, 2737, 2739, 2742, 2751, 2755, 2758, 2765, 2766, 2769, 2770, 2774, 2778, 2782, 2786, 2794, 2795, 2802, 2806, 2810, 2821, 2822, 2829, 2830, 2834, 2847, 2849, 2865, 2874, 2877, 2882, 2895, 2905, 2914, 2915, 2919, 2922, 2930, 2937, 2938, 2945, 2946, 2954, 2955, 2967, 2985, 2994, 3002, 3009, 3014, 3018, 3021, 3026, 3034, 3054, 3055, 3058, 3059, 3070, 3074, 3081, 3082, 3110, 3111, 3115, 3122, 3126, 3129, 3130, 3138, 3145, 3154, 3157, 3165, 3170, 3171, 3178, 3182, 3201, 3206, 3219, 3237, 3243, 3245, 3246, 3262, 3266, 3278, 3282, 3286, 3289, 3297, 3298, 3302, 3310, 3311, 3322, 3333, 3335, 3342, 3345, 3346, 3355, 3358, 3363, 3367, 3370, 3374, 3378, 3382, 3395, 3399, 3405, 3406, 3414, 3417, 3422, 3423, 3426, 3434, 3435, 3441, 3445, 3451, 3454, 3462, 3470, 3471, 3477, 3478, 3485, 3490, 3495, 3502, 3507, 3514, 3515, 3522, 3526, 3530, 3531, 3535, 3538, 3553, 3558, 3562, 3565, 3567, 3585, 3586, 3590, 3594, 3597, 3598, 3605, 3606, 3614, 3615, 3619, 3621, 3633, 3634, 3638, 3642, 3655, 3657, 3658, 3670, 3674, 3678, 3682, 3685, 3686, 3689, 3702, 3706, 3714, 3723, 3729, 3730, 3731, 3741, 3745, 3759, 3765, 3766, 3782, 3783, 3786, 3790, 3794, 3801, 3806, 3813, 3815, 3818, 3819, 3830, 3835, 3838, 3842, 3846, 3854, 3855, 3857, 3858, 3874, 3878, 3882, 3886, 3890, 3895, 3905, 3913, 3914, 3918, 3922, 3926, 3934, 3938, 3939, 3945, 3954, 3955, 3962, 3965, 3966, 3970, 3982, 3995, 3999, 4010, 4011, 4015, 4017, 4029, 4035, 4038, 4042, 4047, 4053, 4062, 4065, 4066, 4071, 4081, 4082, 4085, 4089, 4090, 4094, 4098, 4102, 4118, 4123, 4137, 4142, 4146, 4147, 4154, 4155, 4161, 4173, 4179, 4190, 4191, 4199, 4202, 4206, 4209, 4210, 4215, 4233, 4234, 4238, 4245, 4246, 4251, 4254, 4255, 4277, 4294, 4298, 4301, 4310, 4314, 4318, 4323, 4330, 4334, 4342, 4345, 4346, 4354, 4355, 4362, 4366, 4371, 4378, 4382, 4390, 4395, 4398, 4402, 4403, 4407, 4430, 4431, 4433, 4434, 4438, 4445, 4454, 4458, 4462, 4465, 4490, 4495, 4498, 4503, 4505, 4506, 4514, 4521, 4526, 4539, 4542, 4543, 4551, 4558, 4565, 4566, 4570, 4582, 4585, 4587, 4605, 4610, 4611, 4614, 4615, 4623, 4630, 4634, 4638, 4642, 4646, 4654, 4658, 4665, 4669, 4670, 4683, 4695, 4697, 4706, 4715, 4718, 4722, 4726, 4731, 4738, 4745, 4755, 4767, 4773, 4782, 4790, 4795, 4807, 4809, 4814, 4823, 4826, 4838, 4854, 4858, 4865, 4866, 4870, 4879, 4886, 4893, 4895, 4898, 4899, 4906, 4910, 4917, 4921, 4922, 4926, 4929, 4938, 4942, 4945, 4947, 4953, 4958, 4962, 4965, 4966, 4974, 4978, 4982, 4983, 4990, 4991, 4994, 5002, 5014, 5015, 5018, 5019, 5026, 5030, 5034, 5035, 5037, 5038, 5055, 5061, 5066, 5073, 5074, 5083, 5090, 5109, 5117, 5118, 5122, 5126, 5133, 5134, 5135, 5138, 5142, 5146, 5151, 5154, 5159, 5162, 5174, 5178, 5181, 5185, 5198, 5205, 5206, 5210, 5215, 5217, 5222, 5230, 5235, 5246, 5253, 5254, 5258, 5262, 5271, 5282, 5285, 5286, 5289, 5291, 5295, 5298, 5302, 5306, 5307, 5322, 5335, 5338, 5343, 5362, 5365, 5369, 5379, 5385, 5395, 5397, 5402, 5405, 5410, 5421, 5423, 5442, 5446, 5451, 5453, 5457, 5466, 5467, 5470, 5486, 5487, 5494, 5495, 5505, 5511, 5514, 5518, 5522, 5523, 5529, 5542, 5546, 5551, 5555, 5558, 5559, 5570, 5574, 5593, 5595, 5605, 5614, 5621, 5622, 5626, 5630, 5646, 5649, 5654, 5662, 5665, 5673, 5678, 5681, 5682, 5685, 5690, 5691, 5695, 5705, 5709, 5710, 5718, 5719, 5726, 5727, 5734, 5735, 5738, 5745, 5757, 5762, 5763, 5770, 5781, 5785, 5786, 5795, 5797, 5798, 5802, 5811, 5817, 5822, 5826, 5829, 5835, 5842, 5845, 5846, 5858, 5862, 5863, 5866, 5870, 5871, 5882, 5883, 5885, 5889, 5894, 5898, 5901, 5902, 5907, 5918, 5930, 5943, 5945, 5946, 5954, 5955, 5957, 5962, 5966, 5973, 5974, 5982, 5986, 5990, 5995, 6010, 6014, 6015, 6026, 6034, 6035, 6054, 6055, 6058, 6061, 6062, 6063, 6070, 6078, 6083, 6086, 6094, 6095, 6097, 6099, 6106, 6114, 6123, 6126, 6130, 6135, 6141, 6142, 6146, 6149, 6153, 6154, 6170, 6177, 6182, 6186, 6190, 6194, 6198, 6202, 6205, 6206, 6213, 6214, 6215, 6226, 6231, 6234, 6235, 6251, 6254, 6262, 6265, 6266, 6278, 6285, 6286, 6293, 6294, 6298, 6302, 6303, 6305, 6306, 6307, 6310, 6315, 6322, 6335, 6346, 6351, 6355, 6357, 6365, 6366, 6369, 6378, 6386, 6391, 6394, 6398, 6409, 6410, 6414, 6430, 6441, 6446, 6447, 6454, 6461, 6465, 6466, 6470, 6477, 6478, 6479, 6482, 6494, 6495, 6501, 6513, 6519, 6522, 6526, 6530, 6531, 6538, 6546, 6549, 6554, 6558, 6562, 6565, 6567, 6573, 6574, 6582, 6585, 6586, 6590, 6601, 6603, 6610, 6618, 6634, 6643, 6645, 6654, 6657, 6665, 6674, 6681, 6682, 6685, 6693, 6695, 6698, 6702, 6706, 6715, 6721, 6730, 6735, 6738, 6745, 6747, 6754, 6755, 6758, 6766, 6770, 6771, 6774, 6785, 6789, 6794, 6802, 6806, 6815, 6818, 6830, 6837, 6838, 6842, 6851, 6853, 6854, 6855, 6862, 6873, 6874, 6878, 6886, 6895, 6906, 6910, 6915, 6918, 6919, 6923, 6935, 6945, 6946, 6951, 6955, 6963, 6965, 6969, 6974, 6978, 6981, 6985, 6986, 6987, 6994, 7005, 7006, 7010, 7015, 7021, 7026, 7042, 7046, 7049, 7055, 7059, 7077, 7085, 7086, 7089, 7090, 7102, 7107, 7122, 7126, 7138, 7158, 7163, 7174, 7178, 7185, 7189, 7190, 7198, 7202, 7205, 7206, 7221, 7222, 7239, 7257, 7258, 7259, 7270, 7278, 7282, 7285, 7287, 7294, 7298, 7302, 7305, 7306, 7322, 7329, 7330, 7334, 7337, 7338, 7345, 7347, 7358, 7359, 7365, 7366, 7374, 7383, 7385, 7386, 7390, 7413, 7414, 7422, 7426, 7429, 7430, 7437, 7449, 7467, 7469, 7473, 7474, 7485, 7486, 7491, 7494, 7498, 7503, 7505, 7510, 7511, 7521, 7526, 7527, 7535, 7539, 7545, 7553, 7554, 7557, 7562, 7565, 7567, 7570, 7574, 7579, 7582, 7585, 7598, 7599, 7610, 7611, 7618, 7622, 7634, 7635, 7645, 7654, 7657, 7658, 7662, 7667, 7674, 7678, 7682, 7683, 7685, 7689, 7690, 7698, 7701, 7705, 7707, 7718, 7719, 7730, 7733, 7734, 7738, 7743, 7746, 7761, 7766, 7777, 7782, 7786, 7797, 7798, 7802, 7805, 7806, 7809, 7815, 7818, 7833, 7842, 7843, 7845, 7847, 7869, 7870, 7874, 7881, 7882, 7885, 7887, 7898, 7906, 7914, 7918, 7922, 7923, 7926, 7931, 7945, 7946, 7953, 7954, 7955, 7958, 7959, 7962, 7966, 7970, 7973, 7982, 7994, 8007, 8015, 8018, 8029, 8041, 8043, 8062, 8066, 8074, 8078, 8086, 8090, 8099, 8103, 8110, 8113, 8115, 8122, 8126, 8138, 8155, 8165, 8166, 8169, 8174, 8177, 8194, 8195, 8202, 8205, 8206, 8210, 8215, 8218, 8229, 8230, 8234, 8238, 8239, 8241, 8242, 8245, 8255, 8270, 8277, 8282, 8283, 8286, 8290, 8302, 8305, 8313, 8319, 8323, 8326, 8337, 8338, 8342, 8355, 8362, 8365, 8366, 8374, 8378, 8386, 8390, 8393, 8394, 8395, 8414, 8421, 8426, 8435, 8437, 8439, 8445, 8446, 8449, 8454, 8455, 8474, 8481, 8493, 8494, 8498, 8515, 8517, 8530, 8533, 8534, 8535, 8538, 8555, 8558, 8562, 8565, 8569, 8570, 8574, 8582, 8585, 8589, 8590, 8598, 8601, 8606, 8607, 8614, 8618, 8626, 8630, 8634, 8635, 8638, 8642, 8643, 8655, 8662, 8666, 8671, 8679, 8682, 8686, 8687, 8695, 8697, 8701, 8702, 8706, 8718, 8723, 8729, 8733, 8734, 8738, 8754, 8755, 8758, 8762, 8763, 8769, 8770, 8774, 8785, 8786, 8787, 8789, 8798, 8799, 8805, 8810, 8815, 8822, 8823, 8826, 8827, 8830, 8834, 8841, 8845, 8853, 8854, 8858, 8870, 8877, 8878, 8886, 8895, 8897, 8898, 8905, 8906, 8911, 8922, 8931, 8934, 8938, 8942, 8943, 8949, 8958, 8961, 8965, 8974, 8979, 8985, 8987, 8994, 8995, 8998, 9002, 9015, 9021, 9022, 9035, 9039, 9051, 9058, 9061, 9062, 9066, 9070, 9074, 9082, 9085, 9087, 9093, 9095, 9105, 9106, 9110, 9118, 9129, 9138, 9139, 9141, 9142, 9145, 9146, 9154, 9158, 9159, 9178, 9185, 9186, 9190, 9191, 9195, 9202, 9205, 9213, 9214, 9215, 9218, 9219, 9226, 9231, 9238, 9254, 9255, 9258, 9262, 9265, 9266, 9269, 9273, 9285, 9290, 9291, 9294, 9303, 9309, 9318, 9321, 9322, 9331, 9334, 9339, 9354, 9361, 9362, 9367, 9370, 9373, 9374, 9381, 9393, 9398, 9399, 9401, 9402, 9410, 9415, 9417, 9418, 9422, 9426, 9429, 9434, 9443, 9447, 9453, 9454, 9455, 9465, 9470, 9474, 9478, 9482, 9483, 9485, 9494, 9498, 9499, 9503, 9514, 9515, 9519, 9526, 9530, 9538, 9541, 9542, 9545, 9554, 9562, 9579, 9581, 9582, 9591, 9595, 9597, 9605, 9606, 9615, 9622, 9635, 9638, 9642, 9645, 9654, 9658, 9669, 9670, 9674, 9678, 9681, 9682, 9685, 9686, 9694, 9695, 9698, 9699, 9705, 9706, 9709, 9710, 9714, 9715, 9717, 9718, 9723, 9726, 9734, 9737, 9741, 9746, 9762, 9766, 9770, 9779, 9782, 9785, 9789, 9794, 9795, 9805, 9807, 9814, 9815, 9821, 9822, 9823, 9830, 9831, 9835, 9843, 9845, 9854, 9861, 9877, 9878, 9879, 9885, 9889, 9905, 9910, 9911, 9915, 9919, 9926, 9942, 9951, 9955, 9958, 9962, 9970, 9978, 9994]
  triangularSquare:
    name: 'Triangular Square'
    description: 'Both triangular and a perfect square.'
    computed: true
    test: (n) -> n in [ 1, 36, 1225, 41616, 1413721, 48024900, 1631432881 ]
  automorphic:
    name: 'Automorphic'
    description: 'It\'s square "ends" in itself. Also called Curious.'
    computed: true
    oeis: 'http://oeis.org/A003226'
    test: (n) -> n in automorphics
  palindrome:
    name: 'Palindrome'
    description: 'Reads the same forward and backward'
    computed: true
    test: (n) -> n in palindromes
  factorial:
    name: 'Factorial'
    description: 'The product of all integers less than or equal - n!.'
    computed: true
    test: (n) -> n in factorials
# }}}

generateTags = (n,tests,bf) ->
  for k,v of tests
    if tests[k].computed && tests[k].test(n)
      if bf != null
        bf.add("#{tests[k].name}-#{n}")
      else
        tests[k].numbers.push(n)
checkTags = (n,tests,bf) ->
  for k,v of tests
    if tests[k].computed && tests[k].test(n)
      console.log "ERROR: missing key '#{tests[k].name}-#{n}'" if not bf.has("#{tests[k].name}-#{n}")
      #console.log "NOERR: Key '#{tests[k].name}-#{n}' " if bf.has("#{tests[k].name}-#{n}")
    else
      console.log "ERROR: key '#{tests[k].name}-#{n}' shows up but was never added" if bf.has("#{tests[k].name}-#{n}")

tests[k].numbers = [] for k,v of tests
bf = new Filters.BloomFilter(1000)
generateTags(n,tests,bf) for n in range
checkTags(n,tests,bf) for n in range

console.log JSON.stringify({
  tests: tests
  bloom: bf
})

# set vim: fdm=marker:

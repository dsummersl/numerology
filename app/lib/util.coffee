# adapted from: https://gist.github.com/988005
sign = (x) -> x/Math.abs(x) || 0

range = (start, end, step=1) ->
  cur     = start
  result  = []
  step = Math.abs(step) * sign(end-start)        # Normalize the step direction

  # Step can't be larger than the interval
  return result if Math.abs(step) > Math.abs(end-start)

  until sign(step)*(cur-start) > sign(step)*(end-start)
    result.push(cur)
    cur += step

  if sign(step) == -1 then result.reverse() else result

module.exports = {
  range: range
  sign: sign
}

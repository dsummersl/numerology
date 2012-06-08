Spine = require('spine')
NumberProperty = require('models/NumberProperty')

###
# A specific selection of numbers - a grouping that all belong to the same NumberProperty set.
###
class SubSelect extends Spine.Model
  @configure 'SubSelect', 'numProps'

  constructor: ->
    super
    @numProps = []

  containsProp: (np) -> (n for n in @numProps when n == np.id).length > 0

  @containsNumber: (n,nps=@first().numProps) ->
    return true for np in nps when NumberProperty.find(np).containsNumber(n)
    return false

  @numberOfContains: (n,nps=@first().numProps) ->
    count = 0
    count++ for np in nps when NumberProperty.find(np).containsNumber(n)
    return count

  @selectNoNumberProperties: ->
    f = @first()
    f.numProps = []
    f.save()

  @selectAllNumberProperties: ->
    f = @first()
    f.numProps = (n.id for n in NumberProperty.all())
    f.save()

  @setSelectedNumberProperty: (np) ->
    f = @first()
    f.numProps = [np.id]
    f.save()

  @getNumberProperties: ->
    results = []
    results.push(NumberProperty.find(el)) for el in @first().numProps
    return results

  @toggleSelectedNumberProperty: (np) ->
    f = @first()
    if np.id not in f.numProps
      f.numProps.push np.id
    else
      f.numProps.push np.id
      f.numProps = (npid for npid in f.numProps when npid != np.id)

    f.save()
  
module.exports = SubSelect

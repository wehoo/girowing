clip = (input, min, max)->
  Math.min max, Math.max min, input

lerp = (input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, doClip = true)->
  return outputMin if inputMin is inputMax # Avoids a divide by zero
  input = clip input, inputMin, inputMax if doClip
  input -= inputMin
  input /= inputMax - inputMin
  input *= outputMax - outputMin
  input += outputMin
  return input

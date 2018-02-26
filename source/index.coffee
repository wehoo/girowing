# These global variables will store all our data from the spreadsheet, after we process it to make it nicer to work with.
speciesByName = {}
species = []

# The species data for the current page.
spec = null
# The main element we stuff this page's HTML into.
main = null

# This is a sentinel value for blank fields
BLANK_STRING = "THIS FIELD WAS LEFT BLANK"

# These are columns that we don't need to loop over
ignoreColumns = ["family", "genus", "species", "common_name", "variety"]


# DATA PROCESSING #################################################################################


preprocessData = ()->
  # The top and bottom rows are junk, so we drop them
  dataWithoutEmptyRows = data[2...-3]

  for row in dataWithoutEmptyRows

    # We're going to make a nested data structure for each species
    speciesData = findOrCreateSpeciesData row

    # Within that species data structure, we'll store data from each spreadsheet column
    for columnName, value of row when not (columnName in ignoreColumns)

      # If the value is blank, use a placholder
      value = BLANK_STRING if not value? or value is ""

      # Now, we merge together the values for all rows in this species that share a common_name
      commonNameData = speciesData.fieldsByCommonName[row.common_name] ?= {}
      varietyData = commonNameData[columnName] ?= []

      # We store the data for each variety as a tuple, to make it easier to display
      varietyData.push [row.variety, value]

  # Now that we're done processing all the rows, let's do some aggregation
  for speciesData in species
    for commonName, commonNameData of speciesData.fieldsByCommonName
      for columnName, varietyData of commonNameData

        # Find the first value that's not "n/a" or blank
        defaultValue = getDefaultValue varietyData

        # Apply "n/a" substitutions
        for [variety, value], index in varietyData when value is "n/a"
          varietyData[index] = [variety, defaultValue]

        # When all the varieties have the same value, collapse them into a single value
        commonNameData[columnName] = defaultValue if allValuesAreIdentical varietyData


allValuesAreIdentical = (varietyData)->
  reference = varietyData[0][1]
  for [variety, value] in varietyData
    return false if value isnt reference
  return true


getDefaultValue = (varietyData)->
  for [variety, value] in varietyData
    if value isnt BLANK_STRING and value isnt "n/a"
      return value
  return BLANK_STRING


findOrCreateSpeciesData = (row)->
  fullName = "#{row.family} | #{row.genus} | #{row.species}"
  return speciesByName[fullName] ?= species[species.length] =
    fullName: fullName
    index: species.length
    slug: "#{row.family}-#{row.genus}-#{row.species}".toLowerCase()
    family: row.family
    genus: row.genus
    species: row.species
    fieldsByCommonName: {}


# GUI #############################################################################################
flipSelect = null

setCurrentSpecies = (s)->
  spec = s
  flipSelect.value = spec.fullName
  window.location.hash = spec.slug
  render()


buildUI = ()->
  flipper = DOOM.create "div", document.body, class: "flipper"

  flipLeft = DOOM.create "button", flipper, class: "flip left", textContent: "-"
  flipLeft.addEventListener "click", ()->
    index = (spec.index - 1) % species.length
    setCurrentSpecies species[index]

  flipRight = DOOM.create "button", flipper, class: "flip right", textContent: "+"
  flipRight.addEventListener "click", ()->
    index = (spec.index + 1 + species.length) % species.length
    setCurrentSpecies species[index]

  flipSelect = DOOM.create "select", flipper
  flipSelect.addEventListener "change", ()->
    setCurrentSpecies speciesByName[flipSelect.value]

  for name, s of speciesByName
    DOOM.create "option", flipSelect, textContent: s.fullName

  main = DOOM.create "main", document.body


# RENDERING #######################################################################################


makeField = (parent, labelName, valueName, attrs = {})->
  field = DOOM.create "field", parent, attrs
  label = DOOM.create "label", field, textContent: labelName
  value = DOOM.create "value", field, textContent: valueName


render = ()->
  DOOM.empty main
  renderSpecies main, spec


renderSpecies = (parent, spec)->
  renderTaxonomy parent, spec
  renderCommonNames parent, spec


renderTaxonomy = (parent, spec)->
  elm = DOOM.create "row", main, class: "taxonomy"
  makeField elm, "Family", spec.family
  makeField elm, "Genus", spec.genus
  makeField elm, "Species", spec.species


renderCommonNames = (parent, spec)->
  elm = DOOM.create "div", parent, class: "commonNames"
  for commonName, commonNameData of spec.fieldsByCommonName
    makeField elm, "Common Name", commonName
    renderFields elm, commonNameData


renderFields = (parent, commonNameData)->
  for columnName, varietyData of commonNameData
    elm = DOOM.create "row", parent, class: "fields"
    DOOM.create "h4", elm, class: "field-name", textContent: columnName
    if typeof varietyData is "array"
      for [varietyName, value] in varietyData
        makeField elm, varietyName, varietyName
    else
      makeField elm, "", varietyData



# INIT ############################################################################################


setCurrentSpec = ()->
  h = window.location.hash.replace "#", ""
  if h?
    for s in species when s.slug is h
      return spec = s
  spec = species[0] unless spec?


ready ()->
  preprocessData()
  buildUI()
  setCurrentSpec()
  render()

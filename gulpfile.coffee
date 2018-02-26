browser_sync = require("browser-sync").create()
del = require "del"
gulp = require "gulp"
gulp_autoprefixer = require "gulp-autoprefixer"
gulp_coffee = require "gulp-coffee"
gulp_concat = require "gulp-concat"
gulp_csvtojson = require "gulp-csvtojson"
gulp_insert = require "gulp-insert"
gulp_notify = require "gulp-notify"
gulp_rename = require "gulp-rename"
gulp_replace = require "gulp-replace"
gulp_sass = require "gulp-sass"


# CONFIG ##########################################################################################


paths =
  csv: "source/data/*.csv"
  coffee: ["source/lib/**/*.coffee", "source/**/*.coffee"]
  index: "source/index.html"
  scss: "source/**/*.scss"


gulp_notify.logLevel(0)


# HELPER FUNCTIONS ################################################################################


logAndKillError = (err)->
  console.log "\n## Error ##"
  console.log err.toString() + "\n"
  gulp_notify.onError(
    emitError: true
    icon: false
    message: err.message
    title: "👻"
    wait: true
    )(err)
  @emit "end"


# TASKS: APP COMPILATION ##########################################################################


gulp.task "csv", ()->
  gulp.src paths.csv
    .pipe gulp_csvtojson
      headers: [
        "family",
        "genus",
        "species",
        "common_name",
        "variety",
        "heritage",
        "supplier",
        "product_code",
        "servings_in_a_week",
        "plants_per_a_serving",
        "eating_season",
        "total_plants",
        "number_of_successions",
        "grow_room",
        "weeks_in_cold_storage",
        "number_of_frozen_servings",
        "dried_servings",
        "fermented",
        "canned",
        "cooking",
        "life_cycle",
        "germinating",
        "growing",
        "harvest",
        "spring",
        "fall",
        "soil",
        "ph",
        "moisture",
        "light",
        "distance_between_plants",
        "distance_between_rows",
        "seed_depth",
        "irrigation",
        "fertilizer",
        "flat",
        "cold_start",
        "succession_rate",
        "cold_start_date",
        "cubes",
        "indoor_start_date",
        "outdoors_start_date",
        "last_out_door_planting",
        "succession",
        "plants_per_a_succession",
        "january_1",
        "january_2",
        "january_3",
        "january_4",
        "february_1",
        "february_2",
        "february_3",
        "february_4",
        "march_1",
        "march_2",
        "march_3",
        "march_4",
        "april_1",
        "april_2",
        "april_3",
        "april_4",
        "may_1",
        "may_2",
        "may_3",
        "may_4",
        "june_1",
        "june_2",
        "june_3",
        "june_4",
        "july_1",
        "july_2",
        "july_3",
        "july_4",
        "august_1",
        "august_2",
        "august_3",
        "august_4",
        "september_1",
        "september_2",
        "september_3",
        "september_4",
        "october_1",
        "october_2",
        "october_3",
        "october_4",
        "november_1",
        "november_2",
        "november_3",
        "november_4",
        "december_1",
        "december_2",
        "december_3",
        "december_4",
        "empty",
        "indoor_start_weeks",
        "indoor_start_successions",
        "outdoor_start_weeks",
        "outdoor_start_successions",
        "total_succesions",
        "plants_per_a_succesion",
        "transplant_date",
        "cover_period",
        "transplanting",
        "days_to_maturity",
        "weeks_to_maturity",
        "expected_first_harvest_date",
        "expected_last_harvest_date",
        "staggered_growing_time",
        "best_harvest_date"
      ]
    .pipe gulp_insert.prepend "var data = "
    .pipe gulp_insert.append ";"
    .pipe gulp_concat "data.js"
    .pipe gulp.dest "public"


gulp.task "coffee", ()->
  gulp.src paths.coffee
    .pipe gulp_concat "index.coffee"
    .pipe gulp_coffee()
    .on "error", logAndKillError
    .pipe gulp.dest "public"
    .pipe browser_sync.stream
      match: "**/*.js"


gulp.task "del:public", ()->
  del "public"


gulp.task "index", ()->
  gulp.src paths.index
    .pipe gulp.dest "public"
    .pipe browser_sync.stream
      match: "**/*.html"


gulp.task "scss", ()->
  gulp.src paths.scss
    .pipe gulp_concat "index.scss"
    .pipe gulp_sass
      errLogToConsole: true
      outputStyle: "compressed"
      precision: 2
    .on "error", logAndKillError
    .pipe gulp_autoprefixer
      browsers: "last 2 Chrome versions, last 2 ff versions, IE >= 11, Safari >= 10, iOS >= 10"
      cascade: false
      remove: false
    .pipe gulp.dest "public"
    .pipe browser_sync.stream
      match: "**/*.css"


gulp.task "serve", ()->
  browser_sync.init
    ghostMode: false
    online: true
    server:
      baseDir: "public"
    ui: false


gulp.task "watch", (cb)->
  gulp.watch paths.coffee, gulp.series "coffee"
  gulp.watch paths.index, gulp.series "index"
  gulp.watch paths.scss, gulp.series "scss"
  cb()


gulp.task "default", gulp.series "del:public", gulp.parallel("csv", "coffee", "index", "scss"), "watch", "serve"

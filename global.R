getOrUpdatePkg <- function(p, minVer, repo) {
  if (!isFALSE(try(packageVersion(p) < minVer, silent = TRUE) )) {
    if (missing(repo)) repo = c("predictiveecology.r-universe.dev", getOption("repos"))
    install.packages(p, repos = repo)
  }
}

getOrUpdatePkg("Require", "0.3.1.14")
getOrUpdatePkg("SpaDES.project", "0.0.8.9026")
# getOrUpdatePkg("reproducible", "2.0.9")
# getOrUpdatePkg("SpaDES.core", "2.0.3")

################### RUNAME

if (SpaDES.project::user("tmichele")) setwd("~/projects/Edehzhie/")
if (SpaDES.project::user("emcintir")) {
  SpaDES.project::pkgload2("~/GitHub/SpaDES.project")
  setwd("~/GitHub/")
  .fast <- F
}

if (!exists(".mods")) {
  .mods <- listModules("Biomass", "PredictiveEcology")
  .mods <- grep("Biomass_summary|Biomass_validationKNN", .mods, invert = TRUE, value = TRUE)
}
################ SPADES CALL
library(SpaDES.project)
out <- SpaDES.project::setupProject(
  runName = "Yukon3",
  Restart = TRUE,
  updateRprofile = TRUE,
  paths = list(projectPath = runName),
  #             scratchPath = "~/scratch"),
  modules = paste0(.mods, "@development"),
  options = list(spades.allowInitDuringSimInit = TRUE,
                 spades.allowSequentialCaching = F,
                 reproducible.showSimilar = TRUE,
                 reproducible.memoisePersist = TRUE,
                 reproducible.cacheSaveFormat = "qs",
                 reproducible.inputPaths = "~/data",
                 LandR.assertions = FALSE,
                 reproducible.cacheSpeed = "fast",
                 reproducible.gdalwarp = TRUE,
                 reproducible.showSimilarDepth = 7,
                 gargle_oauth_cache = if (machine("W-VIC-A127585")) "~/.secret" else NULL,
                 gargle_oauth_email =
                   if (user("emcintir")) "eliotmcintire@gmail.com" else if (user("tmichele")) "tati.micheletti@gmail.com" else NULL,
                 SpaDES.project.fast = isTRUE(.fast),
                 spades.recoveryMode = FALSE
  ),
  times = list(start = 2011,
               end = 2025),
  params = list(.globals = list(.plots = NA,
                                .plotInitialTime = NA,
                                sppEquivCol = 'Boreal',
                                .useCache = c(".inputObjects", "init", "other"),
                                fireInitialTime = times$start,
                                fireTimestep = 1)),
                                #cohortDefinitionCols = 'c("pixelGroup", "age", "speciesCode")' )),
  studyArea = list(level = 2, NAME_2 = "Yukon"), # NWT Conic Conformal
  studyAreaLarge = studyArea,
  require = c("reproducible", "SpaDES.core", "PredictiveEcology/LandR@development (>= 1.1.0.9073"),
  packages = c("googledrive", 'RCurl', 'XML',
               "PredictiveEcology/reproducible@modsForLargeArchives (>= 2.0.10.9001)"),
  useGit = "sub"
)

if (SpaDES.project::user("emcintir"))
  SpaDES.project::pkgload2(
    list(file.path("~/GitHub", c("reproducible", "SpaDES.core", "SpaDES.tools", "LandR", "climateData", "fireSenseUtils",
                                 "PSPclean")),
         "~/GitHub/SpaDES.project"))

unlink(dir(tempdir(), recursive = TRUE, full.names = TRUE))
snippsim <- do.call(SpaDES.core::simInitAndSpades, out)


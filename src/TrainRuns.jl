#!/usr/bin/env julia
# -*- coding: UTF-8 -*-
# __author__        = "Max Kannenberg, Martin Scheidt"
# __copyright__     = "2020-2022"
# __license__       = "ISC"
__precompile__(true)

module TrainRuns

## loading standard library packages
using UUIDs, Dates, Statistics
## loading external packages
using YAML, JSONSchema, DataFrames

export
## Interface
trainrun, Train, Path, Settings

## global variables
global g      = 9.80665  # acceleration due to gravity (in m/s^2)
global μ      = 0.2      # friction as constant, TODO: implement as function
global μ_braking  = 0.12     # 0.12 für DB (Stellung G/P) ODER 0.15 für GG-klötze sowie DB in Stellung R ODER 0.18 für el. und hydrody. Bremse
global Δv_air = 15.0/3.6 # coefficient for velocitiy difference between train and outdoor air (in m/s)

## include package files
include("types.jl")
include("constructors.jl")
include("formulary.jl")
include("calc.jl")
include("behavior.jl")
include("output.jl")

## main function
"""
    trainrun(train::Train, path::Path, settings::Settings)

Calculate the running time of a `train` on a `path`.
The `settings` provides the choice of models for the calculation.
`settings` can be omitted. If so, a default is used.
The running time will be return in seconds.

# Examples
```julia-repl
julia> trainrun(train, path)[end,:t]
xxx.xx # in seconds
```
"""
# example train = Train("test/data/trains/freight.yaml")
# example path  = Path("test/data/paths/const.yaml")
# settings = Settings("test/data/settings/points_of_interest.yaml")


function trainrun(train::Train, path::Path, settings=Settings()::Settings)
    # prepare the input data
    (characteristicSections, pointsOfInterest) = determineCharacteristics(path, train, settings)
        # TODO settings.outputDetail == :verbose && println("The characteristics haven been determined.")

    # calculate the train run with the minimum running time
    drivingCourse = calculateMinimumRunningTime(characteristicSections, settings, train)
        # TODO settings.outputDetail == :verbose && println("The driving course for the shortest running time has been calculated.")

    # accumulate data and create an output dictionary
    output = createOutput(settings, drivingCourse, pointsOfInterest)

    return output
end # function trainrun

end # module TrainRuns

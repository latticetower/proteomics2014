require("ArgParse")

using ArgParse

push!(LOAD_PATH, dirname(@__FILE__()))

importall Clustering
importall ProfileAligner
importall DataReader
importall DataWriter

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--score-matrix", "-s"
            help = "an option with an argument"
            arg_type = String
            #required = true
        "--clustering", "-c"
            help = "clustering type: N for neighbour joining, U for UPGMA, W for WPGMA"
            arg_type = String
            default = "N"
            #required = false
        "fasta-file"
            help = "file in .fasta format with a set of protein strings"
            required = true
        "output-file"
            help = "file in .fasta format for saving results"
            required = true
    end

    return parse_args(s)
end

function scoreFunc(p1 :: Profile{Float64}, p2 :: Profile{Float64})
  scoreprofiles(p1, p2)
end

function mergeFunc(p1 :: Profile{Float64}, p2 :: Profile{Float64})
  align(p1, p2)
end

strToProfiles(strings :: Vector{String}) = [Profile{Float64}(str) :: Profile{Float64} for str in strings]

function main()
    parsed_args = parse_commandline()

    input_file = parsed_args["fasta-file"]
    output_file = parsed_args["output-file"]
    clustering = parsed_args["clustering"]
    score_matrix_file = parsed_args["score-matrix"]
    ProfileAligner.setScoringMatrix(readMatrix(score_matrix_file))
    fasta_sequences = readSequences(input_file)
    seq = strToProfiles([x.sequence for x in fasta_sequences])
    result = (clustering == "N" ? NeighbourJoining(seq, scoreFunc, mergeFunc) :
      clustering == "W" ? WPGMA(seq, scoreFunc, mergeFunc) : UPGMA(seq, scoreFunc, mergeFunc) )
    writeSequences(output_file, getstrings(result))
end

main()
#!/usr/bin/env Rscript

# Wrapper for the biotool package

suppressPackageStartupMessages({
  library(optparse, quietly = TRUE)
  library(biotool, quietly = TRUE)
})

VERSION <- packageVersion("biotool")
DEFAULT_MIN_LEN <- 0
DEFAULT_VERBOSE <- FALSE

option_list <- list(
  make_option("--minlen",
              help = paste("Minimum length sequence to include in stats",
                           "[default: %default]"),
              type = "integer",
              default = DEFAULT_MIN_LEN),
  make_option("--verbose",
              help = "Print more stuff about what's happening",
              action = "store_true",
              default = DEFAULT_VERBOSE),
  make_option("--version",
              help = "Print version and exit",
              action = "store_true",
              default = FALSE)
)

parser <- OptionParser(                                             # nolint
  usage = paste("%prog [OPTIONS] [FASTA_FILE [FASTA_FILE ...]]",
                "Print FASTA stats.\n",
                "Positional arguments:",
                "\tFASTA_FILE: Input FASTA files. Use - to read from stdin.",
                sep = "\n"),
  option_list = option_list
)

# Parse command line arguments
INVALID_MESSAGE <- "Invalid command line arguments. Use --help for help."
tryCatch({
    suppressWarnings(
      arguments <- parse_args(parser, positional_arguments = TRUE)
    )},
  error = function(e) {
    message(INVALID_MESSAGE)
    quit(status = 2)
  }
)
opts <- arguments$options
args <- arguments$args

# Check options are valid
invalid_options <- sapply(args, function(x) {
  substr(x, 1, 2) == "--"
})
if (any(is.na(opts)) | any(invalid_options)) {
  message(INVALID_MESSAGE)
  quit(status = 2)
}

# Print version
if (opts$version) {
  cat(basename(commandArgs()[4]), as.character(VERSION), "\n")
  quit(save = "no")
}

# Read from stdin if argument is '-' or empty
args[args == "-"] <- "stdin"
if (length(args) == 0) {
  args <- "stdin"
}
fasta_files <- args

# Process each FASTA file
results <- run_biotool(fasta_files = fasta_files, min_len = opts$minlen,
                       verbose = opts$verbose)
colnames(results) <- toupper(colnames(results))

# Write to stdout
write.table(results, stdout(), sep = "\t", row.names = FALSE, quote = FALSE)

#' Consolidate (sound) files into a single folder
#' 
#' \code{consolidate} copies (sound) files scattered in several directories into a single folder.
#' @export consolidate
#' @usage consolidate(files = NULL, path = NULL, dest.path = NULL, pb = TRUE, file.ext = ".wav$", 
#' parallel = 1, save.csv = TRUE, ...)
#' @param files character vector or factor indicating the subset of files that will be analyzed. The files names
#' should include the full file path. Optional.
#' @param path Character string containing the directory path where the sound files are located. 
#' 'wav.path' set by \code{\link{warbleR_options}} is ignored. 
#' If \code{NULL} (default) then the current working directory is used. 
#' @param dest.path Character string containing the directory path where the cut sound files will be saved.
#' If \code{NULL} (default) then the current working directory is used.
#' @param pb Logical argument to control progress bar. Default is \code{TRUE}.
#' @param file.ext Character string defining the file extension for the files to be consolidated. Default is \code{'.wav$'} ignoring case.
#' @param parallel Numeric. Controls whether parallel computing is applied.
#' It specifies the number of cores to be used. Default is 1 (i.e. no parallel computing).
#' @param save.csv Logical. Controls whether a data frame containing sound file information is saved in the new folder.
#' @param ... Additional arguments to be passed to the internal \code{\link[base]{file.copy}} function for customizing file copyin. 
#' @return All (sound) files are consolidated (copied) to a single folder ("consolidated_files"). If  \code{csv = TRUE} (default)
#' a '.csv' file with the information about file location, old and new names (if any renaming happen) is also saved in the same folder. This data frame is also return as an object in the R environment.  
#' @family selection manipulation, sound file manipulation
#' @seealso \code{\link{fixwavs}} for making sound files readable in R 
#' @name consolidate
#' @details This function allow users to put files scattered in several folders in a 
#' single folder. By default it works on sound files in '.wav' format but can work with
#' other type of files (for instance '.txt' selection files).
#' @examples{ 
#' # First set empty folder
#' # setwd(tempdir())
#' 
#' # save wav file examples
#' data(list = c("Phae.long1", "Phae.long2", "Phae.long3", "Phae.long4", "lbh_selec_table"))
#' 
#' # create first folder
#' dir.create("folder1")
#' writeWave(Phae.long1, file.path("folder1","Phae.long1.wav"))
#' writeWave(Phae.long2, file.path("folder1","Phae.long2.wav"))
#' 
#' # create second folder
#' dir.create("folder2")
#' writeWave(Phae.long3, file.path("folder2","Phae.long3.wav"))
#' writeWave(Phae.long4, file.path("folder2","Phae.long4.wav"))
#' 
#' # consolidate in a single folder
#' consolidate()
#' 
#' # or if tempdir wa used
#' # consolidate(path = tempdir())
#' }
#' 
#' @references {Araya-Salas, M., & Smith-Vidaurre, G. (2017). warbleR: An R package to streamline analysis of animal acoustic signals. Methods in Ecology and Evolution, 8(2), 184-191.}
#' @author Marcelo Araya-Salas (\email{araya-salas@@cornell.edu})
#last modification on jan-29-2018 (MAS)

consolidate <- function(files = NULL, path = NULL, dest.path = NULL, pb = TRUE, file.ext = ".wav$", 
                        parallel = 1, save.csv = TRUE, ...){
  
  # reset working directory 
  wd <- getwd()
  on.exit(setwd(wd))
  on.exit(pbapply::pboptions(type = .Options$pboptions$type), add = TRUE)
  
  #### set arguments from options
  # get function arguments
  argms <- methods::formalArgs(consolidate)
  
  # get warbleR options
  opt.argms <- if(!is.null(getOption("warbleR"))) getOption("warbleR") else SILLYNAME <- 0
  
  # remove options not as default in call and not in function arguments
  opt.argms <- opt.argms[!sapply(opt.argms, is.null) & names(opt.argms) %in% argms]
  
  # get arguments set in the call
  call.argms <- as.list(base::match.call())[-1]
  
  # remove arguments in options that are in call
  opt.argms <- opt.argms[!names(opt.argms) %in% names(call.argms)]
  
  # set options left
  if (length(opt.argms) > 0)
    for (q in 1:length(opt.argms))
      assign(names(opt.argms)[q], opt.argms[[q]])
  
  # check path to working directory
  if (is.null(path)) path <- getwd() else {if (!dir.exists(path)) stop("'path' provided does not exist") else
    setwd(path)
  }  
  
  # check path to working directory
  if (!is.null(dest.path))
  {if (class(try(setwd(dest.path), silent = TRUE)) == "try-error") stop("'dest.path' provided does not exist")} else 
    dir.create(dest.path <- file.path(getwd(), "consolidated_files"), showWarnings = FALSE)
  
  # list files
  if (!is.null(files)){
    
    fe <- file.exists(as.character(files))
    
    # stop if files are not in working directory
    if (length(fe) == 0) stop("files were not found") 
    
    if (length(fe) < length(files)) cat("some files were not found")

    files <- files[fe]
  } else 
    files <- list.files(path = path, pattern = file.ext, ignore.case = TRUE, recursive = TRUE, full.names = TRUE) 
  
  # stop if files are not in working directory
  if (length(files) == 0) stop("no .wav files in working directory and/or subdirectories")
  
  # create new names for duplicated songs
  old_name <- basename(files)
  files <- files[order(old_name)]
  old_name <- old_name[order(old_name)]
  file_size_bytes <- file.size(files)
  
  # rename if any duplicated names
    new_name <- unlist(lapply(unique(old_name), 
      function(x) { 
        on <- old_name[old_name == x]
        if (length(on) > 1) return(paste0(gsub(file.ext, "", on, ignore.case = TRUE), "-", seq_len(length(on)), gsub("$","", file.ext, fixed = TRUE))) else return(x)})) 
  
    new_name <- gsub("\\", "", new_name, fixed = TRUE)
    
  # create data frame with info from old and new names
  X <- data.frame(original_dir = gsub("\\.", path, dirname(files), fixed = TRUE), old_name, new_name, file_size_bytes, stringsAsFactors = FALSE)
  
  # label possible duplicates
  X$duplicate <- sapply(paste0(X$old_name, X$file_size_bytes), function(y) if (length(which(paste0(X$old_name, X$file_size_bytes) == y)) > 1) return("possible.dupl") else return(NA))
  
  # If parallel is not numeric
  if (!is.numeric(parallel)) stop("'parallel' must be a numeric vector of length 1") 
  if (any(!(parallel %% 1 == 0),parallel < 1)) stop("'parallel' should be a positive integer")
  
  
  #create function to run within Xapply functions downstream     
  copyFUN <- function(i, dp, df) file.copy(from = file.path(df$original_dir[i], df$old_name[i]), to = file.path(dp, df$new_name[i]), ...)

  # set pb options 
  pbapply::pboptions(type = ifelse(pb, "timer", "none"))
  
  # set clusters for windows OS
  if (Sys.info()[1] == "Windows" & parallel > 1)
    cl <- parallel::makePSOCKcluster(getOption("cl.cores", parallel)) else cl <- parallel
  
  # run loop apply function
  a1 <- pbapply::pblapply(X = 1:nrow(X), cl = cl, FUN = function(i) 
  { 
    copyFUN(i, dp = dest.path, df = X)
  })
  
  if (save.csv) write.csv(X, row.names = FALSE, file = file.path(dest.path, "file_names_info.csv"))
return(X)
  
  }

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/song_param.R
\name{song_param}
\alias{song_param}
\title{Calculates acoustic parameters at the song level}
\usage{
song_param(X = NULL, song_colm = "song",mean_indx = NULL, min_indx = NULL, 
max_indx = NULL, sd = FALSE, parallel = 1, pb = TRUE, na.rm = FALSE, 
weight = NULL)
}
\arguments{
\item{X}{'selection_table', 'extended_selection_table' (created 'by.song') or data frame with the following columns: 1) "sound.files": name of the .wav 
files, 2) "selec": number of the selections, 3) "start": start time of selections, 4) "end": 
end time of selections. The ouptut of \code{\link{manualoc}} or \code{\link{autodetec}} can 
be used as the input data frame. Other data frames can be used as input, but must have at least the 4 columns mentioned above.}

\item{song_colm}{Character string with the column name containing song labels. 
It can be used to label any hierarchical level at which parameters need to be calculated (e.g. syllables, phrases).
Note that 
the function assumes that song labels are not repeated within a sound file.}

\item{mean_indx}{Numeric vector with the index of the columns that will be averaged. If \code{NULL} the mean of all numeric columns in 'X' is returned.}

\item{min_indx}{Numeric vector with the index of the columns for which the minimum 
value is needed. Default is \code{NULL}.}

\item{max_indx}{Numeric vector with the index of the columns for which the maximum 
value is needed. Default is \code{NULL}.
If  \code{NULL} the mean of all numeric columns in 'X' is returned.}

\item{sd}{Logical value indicating whether standard deviaton is also returned for
variables in which averages are reported. Default is \code{FALSE}.}

\item{parallel}{Numeric. Controls whether parallel computing is applied.
It specifies the number of cores to be used. Default is 1 (i.e. no parallel computing).}

\item{pb}{Logical argument to control progress bar and messages. Default is \code{TRUE}.}

\item{na.rm}{Logical value indicating whether 'NA' values should be ignored for calculations.}

\item{weight}{Character vector defining 1 or more numeric vectors to weight average
measurements (i.e. song parameters). Names of numeric columns in 'X' can also be used. See \code{\link[stats]{weighted.mean}}. 
 for more details.  Default is \code{NULL} (unweighted average).}
}
\value{
A data frame similar to the input 'X' data frame, but in this case each row corresponds to a single song. The data frame contains the mean
 values for numeric columns for each song. Columns that will be averaged can be defined with
 'mean_indx' (otherwhise all numeric columns are used). Columns can be 
 weighted by other columns in the data set (e.g. duration, frequency range). In addition, the function returns the following song level parameters: 
\itemize{
   \item \code{duration}: length of song (in s)
   \item \code{num.elements}: number of elements (or song units)
   \item \code{start}: start time of song (in s)
   \item \code{end}: end time of song (in s)
   \item \code{bottom.freq}: lowest 'bottom.freq' from all song elements (in kHz)
   \item \code{top.freq}: highest 'top.freq' from all song elements (in kHz)
   \item \code{freq.range}: difference between song's 'top.freq' and 'bottom.freq' (in kHz)
   \item \code{note.rate}: number of elements per second
   }
 This function assumes that song labels are not repeated within a sound file.
}
\description{
\code{song_param} calculates average or extreme values of acoustic parameters of
elements in a song or other level of organization in the signals
}
\details{
The function removes silence segments (i.e. segments with very low amplitude values) from wave files.
}
\examples{
{
# Set temporary working directory

# get warbleR sound file examples
data(list = c("Phae.long1", "Phae.long2", "Phae.long3", "Phae.long4", "selec.table"))
writeWave(Phae.long1,"Phae.long1.wav")
writeWave(Phae.long2,"Phae.long2.wav")
writeWave(Phae.long3,"Phae.long3.wav")

# add a 'song' column
selec.table$song <- rep(1:4, each = 3)[1:11]

# measure acoustic parameters
sp <- specan(selec.table[1:8, ], bp = c(1, 11), 300, fast = TRUE)

# add song data
sp <- merge(sp, selec.table[1:8, ], by = c("sound.files", "selec"))

# caculate song-level parameters for all numeric parameters
song_param(X = sp, song_colm = "song", parallel = 1, pb = TRUE)

# caculate song-level parameters selecting parameters with mean_indx
song_param(X = sp, song_colm = "song",mean_indx = 5:10, parallel = 1, pb = TRUE)

# caculate song-level parameters for selecting parameters with mean_indx, max_indx
# and min_indx and weighted by duration
song_param(X = sp, weight = "duration", song_colm = "song",
mean_indx = 5:6, min_indx = 7:8, max_indx = 9:10, parallel = 1, pb = TRUE)

# with two weights 
song_param(X = sp, weight = c("duration", "dfrange"), song_colm = "song",
mean_indx = 5:9, parallel = 1, pb = TRUE)

# with two weights no progress bar
song_param(X = sp, weight = c("duration", "dfrange"), song_colm = "song",
mean_indx = 5:9, parallel = 1, pb = FALSE)
}

}
\references{
{
Araya-Salas, M., & Smith-Vidaurre, G. (2017). warbleR: An R package to streamline analysis of animal acoustic signals. Methods in Ecology and Evolution, 8(2), 184-191.
}
}
\seealso{
\code{\link{fixwavs}}, \code{\link{autodetec}},
}
\author{
Marcelo Araya-Salas (\email{araya-salas@cornell.edu})
}

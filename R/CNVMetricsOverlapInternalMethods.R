
#' @title Calculate metric using overlapping amplified/deleted regions between 
#' two samples.
#' 
#' @description Calculate a specific metric using overlapping 
#' amplified/deleted regions between two samples. 
#' 
#' @param sample01 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the first sample. 
#' The \code{GRanges} must have a metadata column called '\code{state}' with 
#' amplified regions identified as '\code{AMPLIFICATION}' and 
#' deleted regions identified as '\code{DELETION}'; regions with different 
#' identifications will not be used in the
#' calculation of the metric.  
#' @param sample02 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the second sample.
#' @param method a \code{character} string representing the metric to be
#' used ('\code{sorensen}' or '\code{szymkiewicz}'.
#' @param type a \code{character} string representing the type of 
#' copy number events to be used ('\code{AMPLIFICATION}' or '\code{DELETION}').
#' 
#' @details 
#' 
#' The method calculates a specified metric using overlapping
#' regions between the samples. Only regions corresponding to the type
#' specified by user are used in the calculation of the metric. The strand of 
#' the regions is not taken into account while
#' calculating the metric.
#' 
#' The Sorensen metric is calculated by dividing twice the size of 
#' the intersection by the sum of the size of the two sets. If the sum of
#' the size of the two sets is zero; the value \code{NA} is
#' returned instead. 
#' 
#' The Szymkiewicz-Simpson metric is calculated by dividing the size of 
#' the intersection by the smaller of the size of the two sets. If one sample
#' has a size of zero, the metric is not calculated; the value \code{NA} is
#' returned instead. 
#' 
#' @return a \code{numeric}, the value of the specified metric. If
#' the metric cannot be calculated, \code{NA} is returned.
#' 
#' @references 
#' 
#' Sørensen, Thorvald. n.d. “A Method of Establishing Groups of Equal 
#' Amplitude in Plant Sociology Based on Similarity of Species and Its 
#' Application to Analyses of the Vegetation on Danish Commons.” 
#' Biologiske Skrifter, no. 5: 1–34.
#' 
#' Vijaymeena, M. K, and Kavitha K. 2016. “A Survey on Similarity Measures in 
#' Text Mining.” Machine Learning and Applications: An International 
#' Journal 3 (1): 19–28. doi: \url{https://doi.org/10.5121/mlaij.2016.3103}
#'
#' 
#' @examples
#' 
#' ## Load required package to generate the two samples
#' require(GenomicRanges)
#'
#' ## Generate two samples with identical sequence levels
#' sample01 <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(100, 201, 400), 
#'     end = c(200, 350, 500)), strand =  "*",
#'     state = c("AMPLIFICATION", "AMPLIFICATION", "DELETION"))
#' sample02 <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(150, 200, 450), 
#'     end = c(250, 350, 500)), strand =  "*",
#'     state = c("AMPLIFICATION", "DELETION", "DELETION"))
#' 
#' ## Calculate Sorensen metric for the amplified regions   
#' CNVMetrics:::calculateOverlapMetric(sample01, sample02, method="sorensen",
#'     type="AMPLIFICATION")
#' 
#' ## Calculate Szymkiewicz-Simpson metric for the amplified regions   
#' ## Amplified regions of sample02 are a subset of the amplified 
#' ## regions in sample01
#' CNVMetrics:::calculateOverlapMetric(sample01, sample02, method="szymkiewicz",
#'     type="AMPLIFICATION")
#' 
#' ## Calculate Sorensen metric for the deleted regions   
#' CNVMetrics:::calculateOverlapMetric(sample01, sample02, method="sorensen",
#'     type="DELETION")
#'     
#' ## Calculate Szymkiewicz-Simpson metric for the deleted regions    
#' CNVMetrics:::calculateOverlapMetric(sample01, sample02, method="szymkiewicz",
#'     type="DELETION")
#' 
#' @author Astrid Deschênes
#' @keywords internal
calculateOverlapMetric <- function(sample01, sample02, method, type) {
    
    sample01 <- sample01[sample01$state == type,]
    sample02 <- sample02[sample02$state == type,]
    
    result <- NA
    
    if (length(sample01) > 0 && length(sample02) > 0) { 
        result <- switch(method,
                        sorensen = calculateSorensen(sample01, sample02),
                        szymkiewicz = calculateSzymkiewicz(sample01, sample02))
    }
    
    return(result)
}


#' @title Calculate Sorensen metric
#' 
#' @description Calculate Sorensen metric using overlapping regions between 
#' two samples. 
#' 
#' @param sample01 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the first sample.  
#' @param sample02 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the second sample.
#' 
#' @details 
#' 
#' The method calculates the Sorensen metric using overlapping
#' regions between the samples. All regions present in both samples are used
#' for the calculation of the metric.
#' 
#' The Sorensen metric is calculated by dividing twice the size of 
#' the intersection by the sum of the size of the two sets. If the sum of
#' the size of the two sets is zero; the value \code{NA} is
#' returned instead. The strand of the regions is not taken into account while
#' calculating the intersection.
#' 
#' 
#' @return a \code{numeric}, the value of the Sorensen metric. If
#' the metric cannot be calculated, \code{NA} is returned.
#' 
#' @references 
#' 
#' Sørensen, Thorvald. n.d. “A Method of Establishing Groups of Equal 
#' Amplitude in Plant Sociology Based on Similarity of Species and Its 
#' Application to Analyses of the Vegetation on Danish Commons.” 
#' Biologiske Skrifter, no. 5: 1–34.
#' 
#' @examples
#'
#' ## Load required package to generate the two samples
#' require(GenomicRanges)
#'
#' ## Generate two samples with identical sequence levels
#' sample01 <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1905048, 4554832, 31686841), 
#'     end = c(2004603, 4577608, 31695808)), strand =  "*")
#' sample02 <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1995066, 31611222), 
#'     end = c(2204505, 31689898)), strand =  "*")
#' 
#' ## Calculate Sorensen metric    
#' CNVMetrics:::calculateSorensen(sample01, sample02)
#'     
#' @author Astrid Deschênes
#' @importFrom GenomicRanges intersect width
#' @keywords internal
calculateSorensen <- function(sample01, sample02) {
    
    ## Calculate intersection between the two sets as well as the 
    ## total size of each set
    inter <- sum(width(intersect(sample01, sample02, ignore.strand=TRUE)))
    widthSample01 <- sum(width(sample01))
    widthSample02 <- sum(width(sample02))
    
    ## Calculate Sorensen metric if possible; otherwise NA
    result <- ifelse((widthSample01 + widthSample02) > 0, 
                        (2.0 * inter)/(widthSample01 + widthSample02),
                        NA)
    return(result)
}

#' @title Calculate Szymkiewicz-Simpson metric
#' 
#' @description Calculate Szymkiewicz-Simpson metric using overlapping 
#' regions between two samples. 
#' 
#' @param sample01 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the first sample.  
#' @param sample02 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the second sample.
#' 
#' @details 
#' 
#' The method calculates the Szymkiewicz-Simpson metric using overlapping
#' regions between the samples. All regions present in both samples all used
#' for the calculation of the metric.
#' 
#' The Szymkiewicz-Simpson metric is calculated by dividing the size of 
#' the intersection by the smaller of the size of the two sets. If one sample
#' has a size of zero, the metric is not calculated; the value \code{NA} is
#' returned instead. The strand of the regions is not taken into account while
#' calculating the intersection.
#' 
#' @return a \code{numeric}, the value of the Szymkiewicz-Simpson metric. If
#' the metric cannot be calculated, \code{NA} is returned.
#' 
#' @references 
#' 
#' Vijaymeena, M. K, and Kavitha K. 2016. “A Survey on Similarity Measures in 
#' Text Mining.” Machine Learning and Applications: An International 
#' Journal 3 (1): 19–28. doi: \url{https://doi.org/10.5121/mlaij.2016.3103}
#' 
#' @examples
#'
#' ## Load required package to generate the two samples
#' require(GenomicRanges)
#'
#' ## Generate two samples with identical sequence levels
#' sample01 <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1905048, 4554832, 31686841), 
#'     end = c(2004603, 4577608, 31695808)), strand =  "*")
#' sample02 <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1995066, 31611222), 
#'     end = c(2204505, 31689898)), strand =  c("+", "-"))
#'    
#' ## Calculate Szymkiewicz-Simpson metric
#' CNVMetrics:::calculateSzymkiewicz(sample01, sample02)
#'     
#' @author Astrid Deschênes
#' @importFrom GenomicRanges intersect width
#' @keywords internal
calculateSzymkiewicz <- function(sample01, sample02) {
    
    ## Calculate intersection between the two sets as well as the 
    ## total size of each set
    inter <- sum(width(intersect(sample01, sample02, ignore.strand=TRUE)))
    widthSample01 <- sum(width(sample01))
    widthSample02 <- sum(width(sample02))
    
    ## Calculate Szymkiewicz-Simpson metric if possible; otherwise NA
    result <- ifelse(min(widthSample01,widthSample02) > 0, 
                        inter/min(widthSample01,widthSample02),
                        NA)
    return(result)
}

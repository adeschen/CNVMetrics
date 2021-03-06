
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
#' CNVMetrics:::calculateOneOverlapMetric(sample01, sample02, 
#'     method="sorensen", type="AMPLIFICATION")
#' 
#' ## Calculate Szymkiewicz-Simpson metric for the amplified regions   
#' ## Amplified regions of sample02 are a subset of the amplified 
#' ## regions in sample01
#' CNVMetrics:::calculateOneOverlapMetric(sample01, sample02, 
#'     method="szymkiewicz", type="AMPLIFICATION")
#' 
#' ## Calculate Sorensen metric for the deleted regions   
#' CNVMetrics:::calculateOneOverlapMetric(sample01, sample02, 
#'     method="sorensen", type="DELETION")
#'     
#' ## Calculate Szymkiewicz-Simpson metric for the deleted regions    
#' CNVMetrics:::calculateOneOverlapMetric(sample01, sample02,
#'     method="szymkiewicz", type="DELETION")
#' 
#' @author Astrid Deschênes
#' @encoding UTF-8
#' @keywords internal
calculateOneOverlapMetric <- function(sample01, sample02, method, type) {
    
    sample01 <- sample01[sample01$state == type,]
    sample02 <- sample02[sample02$state == type,]
    
    result <- NA
    
    if (length(sample01) > 0 && length(sample02) > 0) { 
        result <- switch(method,
                        sorensen = calculateSorensen(sample01, sample02),
                        szymkiewicz = calculateSzymkiewicz(sample01, sample02),
                        jaccard = calculateJaccard(sample01, sample02))
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
#' @encoding UTF-8
#' @keywords internal
calculateSorensen <- function(sample01, sample02) {
    
    ## Calculate intersection between the two sets as well as the 
    ## total size of each set
    inter <- sum(as.numeric(width(intersect(sample01, sample02, 
                                                ignore.strand=TRUE))))
    widthSample01 <- sum(as.numeric(width(sample01)))
    widthSample02 <- sum(as.numeric(width(sample02)))
    
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
#' @encoding UTF-8
#' @keywords internal
calculateSzymkiewicz <- function(sample01, sample02) {
    
    ## Calculate intersection between the two sets as well as the 
    ## total size of each set
    inter <- sum(as.numeric(width(intersect(sample01, sample02, 
                                                ignore.strand=TRUE))))
    widthSample01 <- sum(as.numeric(width(sample01)))
    widthSample02 <- sum(as.numeric(width(sample02)))
    
    ## Calculate Szymkiewicz-Simpson metric if possible; otherwise NA
    result <- ifelse(min(widthSample01,widthSample02) > 0, 
                        inter/min(widthSample01,widthSample02),
                        NA)
    return(result)
}



#' @title Calculate Jaccard metric
#' 
#' @description Calculate Jaccard metric using overlapping regions between 
#' two samples. 
#' 
#' @param sample01 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the first sample.  
#' @param sample02 a \code{GRanges} which contains a collection of 
#' genomic ranges representing copy number events for the second sample.
#' 
#' @details 
#' 
#' The method calculates the Jaccard metric using overlapping
#' regions between the samples. All regions present in both samples are used
#' for the calculation of the metric.
#' 
#' The Jaccard metric is calculated by dividing the size of 
#' the intersection by the size of the union of the two sets. If the
#' the size of the union of the two sets is zero; the value \code{NA} is
#' returned instead. The strand of the regions is not taken into account while
#' calculating the intersection.
#' 
#' 
#' @return a \code{numeric}, the value of the Jaccard metric. If
#' the metric cannot be calculated, \code{NA} is returned.
#' 
#' @references 
#' 
#' Jaccard, P. (1912), The Distribution of the Flora in the Alpine Zone.  
#' New Phytologist, 11: 37-50. 
#' DOI: \url{https://doi.org/10.1111/j.1469-8137.1912.tb05611.x}
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
#' CNVMetrics:::calculateJaccard(sample01, sample02)
#'     
#' @author Astrid Deschênes
#' @importFrom GenomicRanges intersect width
#' @encoding UTF-8
#' @keywords internal
calculateJaccard <- function(sample01, sample02) {
    
    ## Calculate intersection between the two sets as well as the 
    ## total size of each set
    inter <- sum(as.numeric(width(intersect(sample01, sample02, 
                                                ignore.strand=TRUE))))
    widthSample01 <- sum(as.numeric(width(sample01)))
    widthSample02 <- sum(as.numeric(width(sample02)))
    
    ## Calculate Jaccard metric if possible; otherwise NA
    result <- ifelse((widthSample01 + widthSample02 - inter) > 0, 
                        (inter)/(widthSample01 + widthSample02 - inter),
                        NA)
    return(result)
}


#' @title Plot one graph related to metrics based on overlapping 
#' amplified/deleted regions
#' 
#' @description Plot one heatmap of the metrics based on overlapping 
#' amplified/deleted regions. 
#' 
#' @param metric a \code{CNVMetric} object containing the metrics calculated
#' by \code{calculateOverlapMetric}.
#' 
#' @param type a \code{character} string indicating which graph to generate. 
#' This should be (an unambiguous abbreviation of) one of  
#' "\code{AMPLIFICATION}" or "\code{DELETION}".
#' 
#' @param show_colnames a \code{boolean} specifying if column names are 
#' be shown.
#' 
#' @param silent a \code{boolean} specifying if the plot should not be drawn. 
#' 
#' @param \ldots further arguments passed to 
#' \code{\link[pheatmap:pheatmap]{pheatmap::pheatmap()}} method.
#' 
#' @return a \code{gtable} object containing the heatmap for the specified 
#' metric.
#' 
#' @seealso 
#' 
#' The default method  \code{\link[pheatmap:pheatmap]{pheatmap::pheatmap()}}.
#' 
#' @examples
#' 
#' #' ## Load required package to generate the samples
#' require(GenomicRanges)
#' 
#' ## Create a GRangesList object with 3 samples
#' ## The stand of the regions doesn't affect the calculation of the metric
#' demo <- GRangesList()
#' demo[["sample01"]] <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1905048, 4554832, 31686841), 
#'     end = c(2004603, 4577608, 31695808)), strand =  "*",
#'     state = c("AMPLIFICATION", "AMPLIFICATION", "DELETION"))
#' 
#' demo[["sample02"]] <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1995066, 31611222, 31690000), 
#'     end = c(2204505, 31689898, 31895666)), strand =  c("-", "+", "+"),
#'     state = c("AMPLIFICATION", "AMPLIFICATION", "DELETION"))
#' 
#' ## The amplified region in sample03 is a subset of the amplified regions 
#' ## in sample01
#' demo[["sample03"]] <- GRanges(seqnames = "chr1", 
#'     ranges =  IRanges(start = c(1906069, 4558838), 
#'     end = c(1909505, 4570601)), strand =  "*",
#'     state = c("AMPLIFICATION", "DELETION"))
#' 
#' ## Calculating Sorensen metric
#' metric <- calculateOverlapMetric(demo, method="sorensen")
#' 
#' ## Plot amplification metrics using darkorange color
#' CNVMetrics:::plotOneOverlapMetric(metric, type="AMPLIFICATION", 
#'     colorRange=c("white", "darkorange"), show_colnames=FALSE, silent=TRUE)
#'
#' @author Astrid Deschênes
#' @importFrom pheatmap pheatmap
#' @importFrom grDevices colorRampPalette
#' @importFrom methods hasArg
#' @importFrom stats as.dist
#' @import GenomicRanges
#' @encoding UTF-8
#' @keywords internal
plotOneOverlapMetric <- function(metric, type, colorRange, show_colnames, 
                                    silent, ...) 
{
    ## Extract matrix with metric values
    metricMat <- metric[[type]]
    
    ## Extract extra arguments
    dots <- list(...) 
    
    ## Prepare matrix by filling upper triangle
    diag(metricMat) <- 1.0
    
    ## If clustering distances are not present in the arguments, 
    ## the distance used is based on the samples distance
    if ((!("clustering_distance_cols" %in% names(dots))) &&
            (!("clustering_distance_rows" %in% names(dots)))) {
        ## Prepare matrix to be able to calculate distance
        metricMat[lower.tri(metricMat) & 
                                    is.na(metricMat)] <- 0.0
        metricDist <- as.dist(1-metricMat)
        
        dots[["clustering_distance_cols"]] <- metricDist
        dots[["clustering_distance_rows"]] <- metricDist
    }
    
    ## Prepare matrix by filling upper triangle
    metricMat[upper.tri(metricMat)] <- t(metricMat)[upper.tri(metricMat)]
    metricMat[is.na(metricMat)] <- 0.0
    
    ## Prepare main title (might not be used if main argument given by user)
    if (!hasArg("main")) {
        metricInfo <- switch(attributes(metric)$metric, 
                            "szymkiewicz"="Szymkiewicz-Simpson", 
                            "sorensen"="Sorensen")
        dots[["main"]] <- paste0(type, " - ", metricInfo, " metric")
    }

    ## Create heatmap
    ## If color information given, that information is used to create graph
    ## If main title given, that information is used to create graph
    if (!hasArg("breaks") && !hasArg("color")) {
        ## Create color palette using colorRange parameter
        colors <- colorRampPalette(colorRange)(255)
        breaks <-  seq(0, 1, length.out=255)
        
        dots[["color"]] <- colors
        dots[["breaks"]] <- breaks
    } 
    
    ## Add arguments
    dots[["mat"]] <- metricMat
    dots[["show_colnames"]] <- show_colnames
    dots[["silent"]] <- silent
    
    ## Create heatmap
    do.call(what="pheatmap", args=dots)[[4]]
}

#!/bin/bash
##
## DESCRIPTION:   Recalibrate variant quality scores using known variant sites
##
## USAGE:         gatk.variantrecalibrator.wes.sh input.vcf [reference]
##
## OUTPUT:        input.vcf.recal input.vcf.tranches
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage_min 1 $# $0

# Process input params
VCFIN=$1
REFER=$2
REFER=${REFER:=$REF}

# Format output
OUTPREFIX=$VCFIN
OUTTRANCH=$OUTPREFIX.tranches
OUT_RECAL=$OUTPREFIX.recal
OUTPUTLOG=$OUT_RECAL.log

# Run tool
$JAVAJAR2G $GATK                                          \
   -T VariantRecalibrator                                 \
   -R $REFER                                              \
   -input $VCFIN                                          \
   -recalFile $OUT_RECAL                                  \
   -tranchesFile $OUTTRANCH                               \
   &> $OUTPUTLOG

 --maxGaussians 6 \
   -resource:hapmap,VCF,known=false,training=true,truth=true,prior=15.0 $HAPMAP_SITES_VCF          \
   -resource:omni,VCF,known=false,training=true,truth=false,prior=12.0 1000G_omni2.5.b37.sites.vcf \
   -resource:dbsnp,VCF,known=true,training=false,truth=false,prior=6.0 dbsnp_135.b37.vcf \
   -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an InbreedingCoeff \
   -mode SNP \


# Arguments for VariantRecalibrator:
#  -input,--input <input>                                  The raw input variants to be recalibrated
#  -recalFile,--recal_file <recal_file>                    The output recal file used by ApplyRecalibration
#  -tranchesFile,--tranches_file <tranches_file>           The output tranches file used by ApplyRecalibration
#  -an,--use_annotation <use_annotation>                   The names of the annotations which should used for calculations
#  -mode,--mode <mode>                                     Recalibration mode to employ: 1.) SNP for recalibrating only
#                                                          snps (emitting indels untouched in the output VCF); 2.) INDEL
#                                                          for indels; and 3.) BOTH for recalibrating both snps and indels
#                                                          simultaneously. (SNP|INDEL|BOTH)
#  -mG,--maxGaussians <maxGaussians>                       The maximum number of Gaussians to try during variational Bayes
#                                                          algorithm
#  -mI,--maxIterations <maxIterations>                     The maximum number of VBEM iterations to be performed in
#                                                          variational Bayes algorithm. Procedure will normally end when
#                                                          convergence is detected.
#  -nKM,--numKMeans <numKMeans>                            The number of k-means iterations to perform in order to
#                                                          initialize the means of the Gaussians in the Gaussian mixture
#                                                          model.
#  -std,--stdThreshold <stdThreshold>                      If a variant has annotations more than -std standard deviations
#                                                          away from mean then don't use it for building the Gaussian
#                                                          mixture model.
#  -qual,--qualThreshold <qualThreshold>                   If a known variant has raw QUAL value less than -qual then
#                                                          don't use it for building the Gaussian mixture model.
#  -shrinkage,--shrinkage <shrinkage>                      The shrinkage parameter in the variational Bayes algorithm.
#  -dirichlet,--dirichlet <dirichlet>                      The dirichlet parameter in the variational Bayes algorithm.
#  -priorCounts,--priorCounts <priorCounts>                The number of prior counts to use in the variational Bayes
#                                                          algorithm.
#  -percentBad,--percentBadVariants <percentBadVariants>   What percentage of the worst scoring variants to use when
#                                                          building the Gaussian mixture model of bad variants. 0.07 means
#                                                          bottom 7 percent.
#  -minNumBad,--minNumBadVariants <minNumBadVariants>      The minimum amount of worst scoring variants to use when
#                                                          building the Gaussian mixture model of bad variants. Will
#                                                          override -percentBad argument if necessary.
#  -resource,--resource <resource>                         A list of sites for which to apply a prior probability of being
#                                                          correct but which aren't used by the algorithm
#  -titv,--target_titv <target_titv>                       The expected novel Ti/Tv ratio to use when calculating FDR
#                                                          tranches and for display on the optimization curve output
#                                                          figures. (approx 2.15 for whole genome experiments). ONLY USED
#                                                          FOR PLOTTING PURPOSES!
#  -tranche,--TStranche <TStranche>                        The levels of novel false discovery rate (FDR, implied by
#                                                          ti/tv) at which to slice the data. (in percent, that is 1.0 for
#                                                          1 percent)
#  -ignoreFilter,--ignore_filter <ignore_filter>           If specified the variant recalibrator will use variants even if
#                                                          the specified filter name is marked in the input VCF file
#  -rscriptFile,--rscript_file <rscript_file>              The output rscript file generated by the VQSR to aid in
#                                                          visualization of the input data and learned model
#  -ts_filter_level,--ts_filter_level <ts_filter_level>    The truth sensitivity level at which to start filtering, used
#                                                          here to indicate filtered variants in the model reporting plots
#  -allPoly,--trustAllPolymorphic                          Trust that all the input training sets' unfiltered records
#                                                          contain only polymorphic sites to drastically speed up the
#                                                          computation.
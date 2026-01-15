#!/usr/bin/env nextflow

process SRATOOLKIT {
    label 'process_medium'
    container 'ghcr.io/bf528/sratools:latest'
    publishDir params.fastqdir, mode:'copy'


    input:
    val(sra)

    output:
    path("*_1.fastq.gz"), emit: read1s

    script:
    """ 
    prefetch $sra
    fasterq-dump $sra -e $task.cpus
    gzip *_1.fastq
    """

    stub:
    """
    touch ${sra}_1.fastq.gz
    """
}


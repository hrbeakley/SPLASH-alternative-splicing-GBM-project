#!/usr/bin/env nextflow

process STAR_INDEX {
    label 'process_high'
    container 'ghcr.io/bf528/star:latest'
    publishDir params.outdir, mode:'copy'

    input:
    path(fasta)
    path(gtf)

    output:
    path("star_index/")

    script:
    """ 
    mkdir -p star_index
    STAR \
        --runThreadN $task.cpus \
        --runMode genomeGenerate \
        --genomeDir star_index \
        --genomeFastaFiles $fasta \
        --sjdbGTFfile $gtf
    """
}

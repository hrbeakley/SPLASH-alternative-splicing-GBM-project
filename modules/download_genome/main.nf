#!/usr/bin/env nextflow

process DOWNLOAD_GENOME {
    label 'process_single'
    container 'ghcr.io/bf528/ncbi_datasets_cli:latest'
    publishDir params.outdir, mode:'copy'

    input:
    val(accession)

    output:
    path("ncbi_dataset/data/${accession}/*genomic.fna"), emit: genome
    path("ncbi_dataset/data/${accession}/*genomic.gff"), emit: gtf

    script:
    """ 
    datasets download genome accession $accession \
        --include gff3,genome
    
    unzip ncbi_dataset.zip
    """

    stub:
    """
    touch ${sra}_1.fastq.gz
    """
}


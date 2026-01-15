include { SRATOOLKIT } from './modules/download_fastqs'
include { SPLASH } from './modules/splash_run'
include { DOWNLOAD_GENOME } from './modules/download_genome'
include { STAR_INDEX } from './modules/star_index'

workflow {

    channel.fromPath(params.sra_acc_list)
        .splitCsv( header: false )
        .map{ row -> row[0]}
        .set { fastq_ch }
    
    SRATOOLKIT(fastq_ch)

    splash_manifest_ch = SRATOOLKIT.out.read1s
        .map { file ->
            def name = file.simpleName.split('_')[0]
            "${name} ${file.toString()}"
        }
        .collectFile(name: "input.txt", newLine: true)

    SPLASH(splash_manifest_ch, params.anchor_len)

    DOWNLOAD_GENOME(params.accession)
    
    STAR_INDEX(DOWNLOAD_GENOME.out.genome, DOWNLOAD_GENOME.out.gtf)

}
#!/usr/bin/env nextflow

process SPLASH {
    label 'process_high'
    container 'ghcr.io/refresh-bio/splash:2.11.6'
    publishDir params.outdir, mode: 'copy'

    input:
    path(input)
    val(len)

    output:
    path("sample_name_to_id.mapping.txt"), emit: id_maps
    path("result_compactors/"), emit: compactors
    path("result_satc/"), emit: result_satc
    path("result.after_correction.all_anchors.tsv"), emit: all_anchors
    path("result.after_correction.scores.top_effect_size_bin.tsv"), emit: top_effect_size_bin
    path("result.after_correction.scores.top_target_entropy.tsv"), emit: top_target_entropy
    path("result.after_correction.scores.tsv"), emit: after_correction_scores


    script:
    """ 
    splash $input \
        --dump_sample_anchor_target_count_binary \
        --n_threads_stage_1 0 \
        --n_threads_stage_1_internal 0 \
        --n_threads_stage_1_internal_boost 1 \
        --n_threads_stage_2 12 \
        --anchor_len $len \
        --target_len $len \
        --gap_len 0 \
    """

}

